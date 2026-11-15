-- Run once in Supabase SQL editor. Keeps invite codes and existing RSVP records.

CREATE TABLE IF NOT EXISTS guest_partners (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  guest_id UUID NOT NULL REFERENCES guests(id) ON DELETE CASCADE,
  first_name TEXT NOT NULL,
  sort_order SMALLINT NOT NULL CHECK (sort_order BETWEEN 1 AND 3),
  UNIQUE (guest_id, sort_order)
);

INSERT INTO guest_partners (guest_id, first_name, sort_order)
SELECT id, trim(partner_first_name), 1
FROM guests
WHERE NULLIF(trim(partner_first_name), '') IS NOT NULL
ON CONFLICT (guest_id, sort_order) DO NOTHING;

CREATE TABLE IF NOT EXISTS rsvp_partner_attendance (
  rsvp_id UUID NOT NULL REFERENCES rsvps(id) ON DELETE CASCADE,
  partner_id UUID NOT NULL REFERENCES guest_partners(id) ON DELETE CASCADE,
  PRIMARY KEY (rsvp_id, partner_id)
);
CREATE INDEX IF NOT EXISTS idx_guest_partners_guest_id ON guest_partners(guest_id, sort_order);
CREATE INDEX IF NOT EXISTS idx_rsvp_partner_attendance_partner_id ON rsvp_partner_attendance(partner_id);

INSERT INTO rsvp_partner_attendance (rsvp_id, partner_id)
SELECT r.id, p.id
FROM rsvps r
JOIN guests g ON g.id = r.guest_id
JOIN guest_partners p ON p.guest_id = g.id
WHERE r.attending
  AND r.guest_count > 1
  AND lower(trim(r.plus_one_name)) = lower(trim(p.first_name))
ON CONFLICT DO NOTHING;

UPDATE rsvps r
SET dietary_requirements = g.dietary_notes
FROM guests g
WHERE r.guest_id = g.id
  AND NULLIF(trim(r.dietary_requirements), '') IS NULL
  AND NULLIF(trim(g.dietary_notes), '') IS NOT NULL;

ALTER TABLE rsvps ALTER COLUMN guest_count SET DEFAULT 0;
ALTER TABLE rsvps DROP COLUMN IF EXISTS plus_one_name;

ALTER TABLE guests
  DROP COLUMN IF EXISTS last_name,
  DROP COLUMN IF EXISTS email,
  DROP COLUMN IF EXISTS phone,
  DROP COLUMN IF EXISTS guest_type,
  DROP COLUMN IF EXISTS guest_allowance,
  DROP COLUMN IF EXISTS rsvp_status,
  DROP COLUMN IF EXISTS dietary_notes,
  DROP COLUMN IF EXISTS partner_first_name,
  DROP COLUMN IF EXISTS partner_last_name,
  DROP COLUMN IF EXISTS accommodation_type,
  DROP COLUMN IF EXISTS accommodation_name,
  DROP COLUMN IF EXISTS room_nights,
  DROP COLUMN IF EXISTS accommodation_confirmed,
  DROP COLUMN IF EXISTS friday_supper_status,
  DROP COLUMN IF EXISTS sunday_breakfast_status;

DROP FUNCTION IF EXISTS find_guest_by_code(TEXT);
CREATE FUNCTION find_guest_by_code(p_code TEXT)
RETURNS TABLE (id UUID, first_name TEXT, partners JSONB)
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT g.id, g.first_name,
         COALESCE((
           SELECT jsonb_agg(
             jsonb_build_object('id', p.id, 'first_name', p.first_name, 'sort_order', p.sort_order)
             ORDER BY p.sort_order
           )
           FROM guest_partners p
           WHERE p.guest_id = g.id
         ), '[]'::jsonb)
  FROM guests g
  WHERE g.guest_code = upper(trim(p_code))
  LIMIT 1;
$$;
REVOKE ALL ON FUNCTION find_guest_by_code(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION find_guest_by_code(TEXT) TO anon, authenticated;

DROP FUNCTION IF EXISTS submit_rsvp(TEXT, BOOLEAN, INTEGER, TEXT, TEXT, TEXT, TEXT);
CREATE FUNCTION submit_rsvp(
  p_guest_code TEXT,
  p_attending BOOLEAN,
  p_attending_partner_ids UUID[],
  p_guest_count INTEGER,
  p_dietary_requirements TEXT,
  p_song_request TEXT,
  p_notes TEXT
)
RETURNS TABLE (success BOOLEAN, message TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_guest_id UUID;
  v_rsvp_id UUID;
  v_partner_ids UUID[] := COALESCE(p_attending_partner_ids, ARRAY[]::UUID[]);
BEGIN
  SELECT id INTO v_guest_id
  FROM guests
  WHERE guest_code = upper(trim(p_guest_code));

  IF v_guest_id IS NULL THEN
    RETURN QUERY SELECT false, 'Guest not found';
    RETURN;
  END IF;

  IF cardinality(v_partner_ids) > 3
     OR (NOT p_attending AND cardinality(v_partner_ids) > 0)
     OR cardinality(v_partner_ids) <> (
       SELECT count(DISTINCT selected.id) FROM unnest(v_partner_ids) selected(id)
     )
     OR (p_attending AND (
       p_guest_count IS NULL
       OR p_guest_count < 1
       OR p_guest_count > 4
       OR p_guest_count <> 1 + cardinality(v_partner_ids)
     ))
     OR EXISTS (
       SELECT 1
       FROM unnest(v_partner_ids) selected(id)
       WHERE NOT EXISTS (
         SELECT 1 FROM guest_partners p
         WHERE p.id = selected.id AND p.guest_id = v_guest_id
       )
     ) THEN
    RETURN QUERY SELECT false, 'Invalid partner attendance selection';
    RETURN;
  END IF;

  INSERT INTO rsvps (
    guest_id, attending, guest_count, dietary_requirements,
    song_request, notes, submitted_at
  )
  VALUES (
    v_guest_id, p_attending,
    CASE WHEN p_attending THEN p_guest_count ELSE 0 END,
    p_dietary_requirements, p_song_request, p_notes, NOW()
  )
  ON CONFLICT (guest_id) DO UPDATE SET
    attending = EXCLUDED.attending,
    guest_count = EXCLUDED.guest_count,
    dietary_requirements = EXCLUDED.dietary_requirements,
    song_request = EXCLUDED.song_request,
    notes = EXCLUDED.notes,
    submitted_at = NOW()
  RETURNING id INTO v_rsvp_id;

  DELETE FROM rsvp_partner_attendance WHERE rsvp_id = v_rsvp_id;
  IF p_attending AND cardinality(v_partner_ids) > 0 THEN
    INSERT INTO rsvp_partner_attendance (rsvp_id, partner_id)
    SELECT v_rsvp_id, unnest(v_partner_ids);
  END IF;

  RETURN QUERY SELECT true, 'RSVP saved';
END;
$$;
REVOKE ALL ON FUNCTION submit_rsvp(TEXT, BOOLEAN, UUID[], INTEGER, TEXT, TEXT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION submit_rsvp(TEXT, BOOLEAN, UUID[], INTEGER, TEXT, TEXT, TEXT) TO anon, authenticated;

ALTER TABLE guest_partners ENABLE ROW LEVEL SECURITY;
ALTER TABLE rsvp_partner_attendance ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admin can manage guest partners" ON guest_partners
  FOR ALL TO authenticated USING (is_admin()) WITH CHECK (is_admin());
CREATE POLICY "Admin can read RSVP partner attendance" ON rsvp_partner_attendance
  FOR SELECT TO authenticated USING (is_admin());

GRANT SELECT, INSERT, UPDATE, DELETE ON guest_partners TO authenticated;
GRANT SELECT ON rsvp_partner_attendance TO authenticated;
