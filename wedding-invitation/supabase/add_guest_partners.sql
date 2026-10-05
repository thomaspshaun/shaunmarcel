-- Run once in the Supabase SQL editor (safe to re-run).

-- Accommodation + weekend attendance columns (used by the invitation lookup and
-- the admin Accommodation table). No-ops if they already exist.
ALTER TABLE guests ADD COLUMN IF NOT EXISTS accommodation_type TEXT CHECK (accommodation_type IN ('estate', 'guesthouse', 'own'));
ALTER TABLE guests ADD COLUMN IF NOT EXISTS accommodation_name TEXT;
ALTER TABLE guests ADD COLUMN IF NOT EXISTS room_nights INTEGER;
ALTER TABLE guests ADD COLUMN IF NOT EXISTS accommodation_confirmed BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE guests ADD COLUMN IF NOT EXISTS friday_supper_status TEXT NOT NULL DEFAULT 'pending' CHECK (friday_supper_status IN ('pending', 'attending', 'declining'));
ALTER TABLE guests ADD COLUMN IF NOT EXISTS sunday_breakfast_status TEXT NOT NULL DEFAULT 'pending' CHECK (sunday_breakfast_status IN ('pending', 'attending', 'declining'));
ALTER TABLE guests ADD COLUMN IF NOT EXISTS whatsapp_number TEXT;
ALTER TABLE guests ADD COLUMN IF NOT EXISTS invite_sent_at TIMESTAMPTZ;
-- Partner (couple invitations): when a partner is set, the guest automatically
-- gets a plus-one and the invitation greets "Guest & Partner".
ALTER TABLE guests ADD COLUMN IF NOT EXISTS partner_first_name TEXT;
ALTER TABLE guests ADD COLUMN IF NOT EXISTS partner_last_name TEXT;
-- Looks up a single guest by their unique invite code. Returns only the
-- fields the invitation/RSVP pages need - never the full guest list.
-- (Return type changed, so the old version must be dropped first.)
DROP FUNCTION IF EXISTS find_guest_by_code(TEXT);
CREATE OR REPLACE FUNCTION find_guest_by_code(p_code TEXT)
RETURNS TABLE (
  id UUID,
  first_name TEXT,
  last_name TEXT,
  guest_type TEXT,
  plus_one_allowed BOOLEAN,
  partner_first_name TEXT,
  partner_last_name TEXT,
  rsvp_status TEXT,
  dietary_notes TEXT,
  accommodation_name TEXT,
  room_nights INTEGER,
  accommodation_confirmed BOOLEAN
)
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT g.id, g.first_name, g.last_name, g.guest_type,
         (g.plus_one_allowed OR NULLIF(trim(g.partner_first_name), '') IS NOT NULL),
         NULLIF(trim(g.partner_first_name), ''), NULLIF(trim(g.partner_last_name), ''),
         g.rsvp_status, g.dietary_notes,
         g.accommodation_name, g.room_nights, g.accommodation_confirmed
  FROM guests g
  WHERE g.guest_code = upper(trim(p_code))
  LIMIT 1;
$$;

REVOKE ALL ON FUNCTION find_guest_by_code(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION find_guest_by_code(TEXT) TO anon, authenticated;
