CREATE TABLE IF NOT EXISTS guests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  guest_code TEXT UNIQUE,
  guest_type TEXT NOT NULL DEFAULT 'standard' CHECK (guest_type IN ('standard', 'vip', 'family', 'wedding_party')),
  plus_one_allowed BOOLEAN NOT NULL DEFAULT false,
  rsvp_status TEXT DEFAULT 'pending' CHECK (rsvp_status IN ('pending', 'attending', 'declining', 'notified')),
  dietary_notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS rsvps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  guest_id UUID NOT NULL REFERENCES guests(id) ON DELETE CASCADE,
  attending BOOLEAN NOT NULL,
  guest_count INTEGER NOT NULL DEFAULT 1,
  plus_one_name TEXT,
  dietary_requirements TEXT,
  song_request TEXT,
  notes TEXT,
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  confirmation_email_sent BOOLEAN NOT NULL DEFAULT false,
  UNIQUE (guest_id)
);

CREATE TABLE IF NOT EXISTS comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  guest_id UUID REFERENCES guests(id) ON DELETE SET NULL,
  display_name TEXT NOT NULL,
  message TEXT NOT NULL,
  approved BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ,
  location_name TEXT,
  location_address TEXT,
  description TEXT,
  category TEXT DEFAULT 'wedding' CHECK (category IN ('wedding', 'rehearsal', 'party', 'accommodation')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_guests_guest_code ON guests(guest_code);
CREATE INDEX IF NOT EXISTS idx_rsvps_guest_id ON rsvps(guest_id);
CREATE INDEX IF NOT EXISTS idx_comments_approved ON comments(approved, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_events_start_time ON events(start_time);

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------
-- The site talks to Supabase directly from the browser using the public
-- "anon" key, so we lock every table down by default and only expose data
-- through SECURITY DEFINER functions below. This prevents anyone from using
-- the anon key to list/scrape the full guest table.

ALTER TABLE guests ENABLE ROW LEVEL SECURITY;
ALTER TABLE rsvps ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

-- No direct table policies are created for guests/rsvps: all access goes
-- through the RPC functions below, which run with the table owner's
-- privileges (SECURITY DEFINER) regardless of RLS.

-- Guestbook comments: anyone can read approved comments, anyone can post one.
DROP POLICY IF EXISTS "Public can read approved comments" ON comments;
CREATE POLICY "Public can read approved comments" ON comments
  FOR SELECT USING (approved = true);

DROP POLICY IF EXISTS "Public can post comments" ON comments;
CREATE POLICY "Public can post comments" ON comments
  FOR INSERT WITH CHECK (true);

-- Events: read-only reference data, safe to expose publicly.
DROP POLICY IF EXISTS "Public can read events" ON events;
CREATE POLICY "Public can read events" ON events
  FOR SELECT USING (true);

-- ---------------------------------------------------------------------------
-- RPC: find_guest_by_code
-- ---------------------------------------------------------------------------
-- Looks up a single guest by their unique invite code. Returns only the
-- fields the RSVP form needs — never the full guest list.
CREATE OR REPLACE FUNCTION find_guest_by_code(p_code TEXT)
RETURNS TABLE (
  id UUID,
  first_name TEXT,
  last_name TEXT,
  guest_type TEXT,
  plus_one_allowed BOOLEAN,
  rsvp_status TEXT,
  dietary_notes TEXT
)
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT g.id, g.first_name, g.last_name, g.guest_type, g.plus_one_allowed, g.rsvp_status, g.dietary_notes
  FROM guests g
  WHERE g.guest_code = upper(trim(p_code))
  LIMIT 1;
$$;

REVOKE ALL ON FUNCTION find_guest_by_code(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION find_guest_by_code(TEXT) TO anon, authenticated;

-- ---------------------------------------------------------------------------
-- RPC: submit_rsvp
-- ---------------------------------------------------------------------------
-- Validates the guest code server-side, then upserts the guest's RSVP.
-- The anon key can never write to rsvps/guests directly, only via this path.
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
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_guest_id UUID;
BEGIN
  SELECT id INTO v_guest_id
  FROM guests
  WHERE guest_code = upper(trim(p_guest_code));

  IF v_guest_id IS NULL THEN
    RETURN QUERY SELECT false, 'Guest not found';
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

