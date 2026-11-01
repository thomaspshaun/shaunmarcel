-- Run once in the Supabase SQL editor. Converts the previous plus-one flag
-- into a total party-size allowance, including the invited guest.
ALTER TABLE guests ADD COLUMN IF NOT EXISTS guest_allowance INTEGER;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'guests' AND column_name = 'plus_one_allowed'
  ) THEN
    EXECUTE 'UPDATE guests SET guest_allowance = CASE WHEN plus_one_allowed THEN 2 ELSE 1 END WHERE guest_allowance IS NULL';
  ELSE
    UPDATE guests SET guest_allowance = 1 WHERE guest_allowance IS NULL;
  END IF;
END;
$$;

UPDATE guests
SET guest_allowance = GREATEST(guest_allowance, 2)
WHERE NULLIF(trim(partner_first_name), '') IS NOT NULL;

ALTER TABLE guests ALTER COLUMN guest_allowance SET DEFAULT 1;
ALTER TABLE guests ALTER COLUMN guest_allowance SET NOT NULL;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'guests_guest_allowance_positive') THEN
    ALTER TABLE guests
      ADD CONSTRAINT guests_guest_allowance_positive CHECK (guest_allowance >= 1);
  END IF;
END;
$$;

DROP FUNCTION IF EXISTS find_guest_by_code(TEXT);
CREATE OR REPLACE FUNCTION find_guest_by_code(p_code TEXT)
RETURNS TABLE (
  id UUID, first_name TEXT, last_name TEXT, guest_type TEXT,
  guest_allowance INTEGER, partner_first_name TEXT, partner_last_name TEXT,
  rsvp_status TEXT, dietary_notes TEXT, accommodation_name TEXT,
  room_nights INTEGER, accommodation_confirmed BOOLEAN
)
LANGUAGE sql SECURITY DEFINER SET search_path = public
AS $$
  SELECT g.id, g.first_name, g.last_name, g.guest_type, g.guest_allowance,
         NULLIF(trim(g.partner_first_name), ''), NULLIF(trim(g.partner_last_name), ''),
         g.rsvp_status, g.dietary_notes, g.accommodation_name, g.room_nights,
         g.accommodation_confirmed
  FROM guests g
  WHERE g.guest_code = upper(trim(p_code))
  LIMIT 1;
$$;

REVOKE ALL ON FUNCTION find_guest_by_code(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION find_guest_by_code(TEXT) TO anon, authenticated;

CREATE OR REPLACE FUNCTION submit_rsvp(
  p_guest_code TEXT,
  p_attending BOOLEAN,
  p_guest_count INTEGER,
  p_plus_one_name TEXT,
  p_dietary_requirements TEXT,
  p_song_request TEXT,
  p_notes TEXT
)
RETURNS TABLE (success BOOLEAN, message TEXT)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  v_guest_id UUID;
  v_guest_allowance INTEGER;
BEGIN
  SELECT id, guest_allowance INTO v_guest_id, v_guest_allowance
  FROM guests
  WHERE guest_code = upper(trim(p_guest_code));

  IF v_guest_id IS NULL THEN
    RETURN QUERY SELECT false, 'Guest not found';
    RETURN;
  END IF;

  IF p_attending AND (p_guest_count IS NULL OR p_guest_count < 1 OR p_guest_count > v_guest_allowance) THEN
    RETURN QUERY SELECT false, 'Attendance count exceeds the invitation allowance';
    RETURN;
  END IF;

  INSERT INTO rsvps (
    guest_id, attending, guest_count, plus_one_name,
    dietary_requirements, song_request, notes, submitted_at
  )
  VALUES (
    v_guest_id, p_attending, GREATEST(COALESCE(p_guest_count, 1), 1), p_plus_one_name,
    p_dietary_requirements, p_song_request, p_notes, NOW()
  )
  ON CONFLICT (guest_id) DO UPDATE SET
    attending = EXCLUDED.attending,
    guest_count = EXCLUDED.guest_count,
    plus_one_name = EXCLUDED.plus_one_name,
    dietary_requirements = EXCLUDED.dietary_requirements,
    song_request = EXCLUDED.song_request,
    notes = EXCLUDED.notes,
    submitted_at = NOW();

  UPDATE guests
  SET rsvp_status = CASE WHEN p_attending THEN 'attending' ELSE 'declining' END,
      updated_at = NOW()
  WHERE id = v_guest_id;

  RETURN QUERY SELECT true, 'RSVP saved';
END;
$$;

REVOKE ALL ON FUNCTION submit_rsvp(TEXT, BOOLEAN, INTEGER, TEXT, TEXT, TEXT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION submit_rsvp(TEXT, BOOLEAN, INTEGER, TEXT, TEXT, TEXT, TEXT) TO anon, authenticated;
