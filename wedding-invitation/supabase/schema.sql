CREATE TABLE IF NOT EXISTS guests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  whatsapp_number TEXT,
  guest_code TEXT UNIQUE,
  guest_type TEXT NOT NULL DEFAULT 'standard' CHECK (guest_type IN ('standard', 'vip', 'family', 'wedding_party')),
  plus_one_allowed BOOLEAN NOT NULL DEFAULT false,
  rsvp_status TEXT DEFAULT 'pending' CHECK (rsvp_status IN ('pending', 'attending', 'declining', 'notified')),
  dietary_notes TEXT,
  invite_sent_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Safe to re-run on an existing database that was created before these columns existed.
ALTER TABLE guests ADD COLUMN IF NOT EXISTS whatsapp_number TEXT;
ALTER TABLE guests ADD COLUMN IF NOT EXISTS invite_sent_at TIMESTAMPTZ;

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

-- Curated pre-wedding photo gallery. Only the admin adds rows here (via the
-- admin panel), everyone can view them.
CREATE TABLE IF NOT EXISTS gallery_photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  storage_path TEXT NOT NULL,
  caption TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Post-wedding guest photo uploads. Anyone (even without an invite code) can
-- add a row here after uploading their file to the "guest-photos" storage
-- bucket; everyone can view approved ones.
CREATE TABLE IF NOT EXISTS guest_photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  storage_path TEXT NOT NULL,
  uploader_name TEXT,
  caption TEXT,
  approved BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_guests_guest_code ON guests(guest_code);
CREATE INDEX IF NOT EXISTS idx_rsvps_guest_id ON rsvps(guest_id);
CREATE INDEX IF NOT EXISTS idx_comments_approved ON comments(approved, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_events_start_time ON events(start_time);
CREATE INDEX IF NOT EXISTS idx_gallery_photos_sort ON gallery_photos(sort_order, created_at);
CREATE INDEX IF NOT EXISTS idx_guest_photos_approved ON guest_photos(approved, created_at DESC);

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
ALTER TABLE gallery_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE guest_photos ENABLE ROW LEVEL SECURITY;

-- No direct table policies are created for guests/rsvps: all access goes
-- through the RPC functions below, which run with the table owner's
-- privileges (SECURITY DEFINER) regardless of RLS.

-- Defined here (before any policy that uses it) so this file can be re-run
-- top-to-bottom. Only a signed-in Supabase Auth user with this exact email
-- is treated as the admin. Replace with your real admin email if it changes.
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT auth.jwt() ->> 'email' = 'shaun.padachi@gmail.com';
$$;

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

-- Curated pre-wedding gallery: everyone can view; only the admin can manage.
DROP POLICY IF EXISTS "Public can read gallery photos" ON gallery_photos;
CREATE POLICY "Public can read gallery photos" ON gallery_photos
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Admin can insert gallery photos" ON gallery_photos;
CREATE POLICY "Admin can insert gallery photos" ON gallery_photos
  FOR INSERT TO authenticated WITH CHECK (is_admin());

DROP POLICY IF EXISTS "Admin can update gallery photos" ON gallery_photos;
CREATE POLICY "Admin can update gallery photos" ON gallery_photos
  FOR UPDATE TO authenticated USING (is_admin()) WITH CHECK (is_admin());

DROP POLICY IF EXISTS "Admin can delete gallery photos" ON gallery_photos;
CREATE POLICY "Admin can delete gallery photos" ON gallery_photos
  FOR DELETE TO authenticated USING (is_admin());

-- Guest photo uploads: anyone can post one (post-wedding, no invite code
-- needed), anyone can view approved ones, only the admin can moderate/delete.
DROP POLICY IF EXISTS "Public can read approved guest photos" ON guest_photos;
CREATE POLICY "Public can read approved guest photos" ON guest_photos
  FOR SELECT USING (approved = true);

DROP POLICY IF EXISTS "Public can upload guest photos" ON guest_photos;
CREATE POLICY "Public can upload guest photos" ON guest_photos
  FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Admin can read all guest photos" ON guest_photos;
CREATE POLICY "Admin can read all guest photos" ON guest_photos
  FOR SELECT TO authenticated USING (is_admin());

DROP POLICY IF EXISTS "Admin can update guest photos" ON guest_photos;
CREATE POLICY "Admin can update guest photos" ON guest_photos
  FOR UPDATE TO authenticated USING (is_admin()) WITH CHECK (is_admin());

DROP POLICY IF EXISTS "Admin can delete guest photos" ON guest_photos;
CREATE POLICY "Admin can delete guest photos" ON guest_photos
  FOR DELETE TO authenticated USING (is_admin());

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

-- ---------------------------------------------------------------------------
-- Admin access (guest list management + WhatsApp invite sending)
-- ---------------------------------------------------------------------------
-- is_admin() is defined earlier in this file (before it's first used by the
-- gallery/guest_photos policies). IMPORTANT: also disable public sign-ups in
-- Supabase Dashboard -> Authentication -> Settings, and only ever create your
-- own admin user manually from that dashboard.

DROP POLICY IF EXISTS "Admin can read guests" ON guests;
CREATE POLICY "Admin can read guests" ON guests
  FOR SELECT TO authenticated USING (is_admin());

DROP POLICY IF EXISTS "Admin can insert guests" ON guests;
CREATE POLICY "Admin can insert guests" ON guests
  FOR INSERT TO authenticated WITH CHECK (is_admin());

DROP POLICY IF EXISTS "Admin can update guests" ON guests;
CREATE POLICY "Admin can update guests" ON guests
  FOR UPDATE TO authenticated USING (is_admin()) WITH CHECK (is_admin());

DROP POLICY IF EXISTS "Admin can delete guests" ON guests;
CREATE POLICY "Admin can delete guests" ON guests
  FOR DELETE TO authenticated USING (is_admin());

DROP POLICY IF EXISTS "Admin can read rsvps" ON rsvps;
CREATE POLICY "Admin can read rsvps" ON rsvps
  FOR SELECT TO authenticated USING (is_admin());

-- ---------------------------------------------------------------------------
-- Storage buckets (photo gallery + guest uploads)
-- ---------------------------------------------------------------------------
-- Create two PUBLIC buckets in Supabase Dashboard -> Storage before running
-- this section (bucket creation via SQL varies by project, the dashboard is
-- the most reliable way):
--   1. "gallery"       - curated pre-wedding photos, admin uploads only
--   2. "guest-photos"  - post-wedding photos guests upload themselves
-- Both must be marked "Public bucket" so uploaded images can be viewed via a
-- plain URL without needing a signed link.

DROP POLICY IF EXISTS "Public can view gallery bucket" ON storage.objects;
CREATE POLICY "Public can view gallery bucket" ON storage.objects
  FOR SELECT USING (bucket_id = 'gallery');

DROP POLICY IF EXISTS "Admin can upload to gallery bucket" ON storage.objects;
CREATE POLICY "Admin can upload to gallery bucket" ON storage.objects
  FOR INSERT TO authenticated WITH CHECK (bucket_id = 'gallery' AND is_admin());

DROP POLICY IF EXISTS "Admin can delete from gallery bucket" ON storage.objects;
CREATE POLICY "Admin can delete from gallery bucket" ON storage.objects
  FOR DELETE TO authenticated USING (bucket_id = 'gallery' AND is_admin());

DROP POLICY IF EXISTS "Public can view guest-photos bucket" ON storage.objects;
CREATE POLICY "Public can view guest-photos bucket" ON storage.objects
  FOR SELECT USING (bucket_id = 'guest-photos');

DROP POLICY IF EXISTS "Public can upload to guest-photos bucket" ON storage.objects;
CREATE POLICY "Public can upload to guest-photos bucket" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'guest-photos');

DROP POLICY IF EXISTS "Admin can delete from guest-photos bucket" ON storage.objects;
CREATE POLICY "Admin can delete from guest-photos bucket" ON storage.objects
  FOR DELETE TO authenticated USING (bucket_id = 'guest-photos' AND is_admin());
