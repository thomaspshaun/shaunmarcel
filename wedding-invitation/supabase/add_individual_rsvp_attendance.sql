-- Run once in Supabase SQL Editor to record each invited person's attendance.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'rsvps'
      AND column_name = 'guest_attending'
  ) THEN
    ALTER TABLE public.rsvps
      ADD COLUMN guest_attending BOOLEAN NOT NULL DEFAULT true;
    UPDATE public.rsvps SET guest_attending = attending;
  END IF;
END;
$$;

DROP FUNCTION IF EXISTS public.submit_rsvp(TEXT, BOOLEAN, UUID[], INTEGER, TEXT, TEXT, TEXT);
CREATE FUNCTION public.submit_rsvp(
  p_guest_code TEXT,
  p_guest_attending BOOLEAN,
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
  v_guest_count INTEGER;
  v_partner_ids UUID[] := COALESCE(p_attending_partner_ids, ARRAY[]::UUID[]);
BEGIN
  v_guest_count := CASE WHEN p_guest_attending THEN 1 ELSE 0 END + cardinality(v_partner_ids);

  SELECT id INTO v_guest_id
  FROM public.guests
  WHERE guest_code = upper(trim(p_guest_code));

  IF v_guest_id IS NULL THEN
    RETURN QUERY SELECT false, 'Guest not found';
    RETURN;
  END IF;

  IF cardinality(v_partner_ids) > 3
     OR cardinality(v_partner_ids) <> (
       SELECT count(DISTINCT selected.id) FROM unnest(v_partner_ids) selected(id)
     )
     OR p_guest_count IS NULL
     OR p_guest_count < 0
     OR p_guest_count > 4
     OR p_guest_count <> v_guest_count
     OR EXISTS (
       SELECT 1
       FROM unnest(v_partner_ids) selected(id)
       WHERE NOT EXISTS (
         SELECT 1 FROM public.guest_partners p
         WHERE p.id = selected.id AND p.guest_id = v_guest_id
       )
     ) THEN
    RETURN QUERY SELECT false, 'Invalid attendance selection';
    RETURN;
  END IF;

  INSERT INTO public.rsvps (
    guest_id, attending, guest_attending, guest_count,
    dietary_requirements, song_request, notes, submitted_at
  )
  VALUES (
    v_guest_id, v_guest_count > 0, p_guest_attending, v_guest_count,
    p_dietary_requirements, p_song_request, p_notes, NOW()
  )
  ON CONFLICT (guest_id) DO UPDATE SET
    attending = EXCLUDED.attending,
    guest_attending = EXCLUDED.guest_attending,
    guest_count = EXCLUDED.guest_count,
    dietary_requirements = EXCLUDED.dietary_requirements,
    song_request = EXCLUDED.song_request,
    notes = EXCLUDED.notes,
    submitted_at = NOW()
  RETURNING id INTO v_rsvp_id;

  DELETE FROM public.rsvp_partner_attendance WHERE rsvp_id = v_rsvp_id;
  IF cardinality(v_partner_ids) > 0 THEN
    INSERT INTO public.rsvp_partner_attendance (rsvp_id, partner_id)
    SELECT v_rsvp_id, unnest(v_partner_ids);
  END IF;

  RETURN QUERY SELECT true, 'RSVP saved';
END;
$$;

REVOKE ALL ON FUNCTION public.submit_rsvp(TEXT, BOOLEAN, UUID[], INTEGER, TEXT, TEXT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.submit_rsvp(TEXT, BOOLEAN, UUID[], INTEGER, TEXT, TEXT, TEXT) TO anon, authenticated;
