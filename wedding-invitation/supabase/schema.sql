CREATE TABLE IF NOT EXISTS guests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  first_name TEXT NOT NULL,
  whatsapp_number TEXT,
  guest_code TEXT UNIQUE NOT NULL,
  invite_sent_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS guest_partners (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  guest_id UUID NOT NULL REFERENCES guests(id) ON DELETE CASCADE,
  first_name TEXT NOT NULL,
  sort_order SMALLINT NOT NULL CHECK (sort_order BETWEEN 1 AND 3),
  UNIQUE (guest_id, sort_order)
);

CREATE TABLE IF NOT EXISTS rsvps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  guest_id UUID NOT NULL REFERENCES guests(id) ON DELETE CASCADE,
  attending BOOLEAN NOT NULL,
  guest_count INTEGER NOT NULL DEFAULT 0 CHECK (guest_count >= 0),
  dietary_requirements TEXT,
  song_request TEXT,
  notes TEXT,
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  confirmation_email_sent BOOLEAN NOT NULL DEFAULT false,
  UNIQUE (guest_id)
);

CREATE TABLE IF NOT EXISTS rsvp_partner_attendance (
  rsvp_id UUID NOT NULL REFERENCES rsvps(id) ON DELETE CASCADE,
  partner_id UUID NOT NULL REFERENCES guest_partners(id) ON DELETE CASCADE,
  PRIMARY KEY (rsvp_id, partner_id)
);

CREATE INDEX IF NOT EXISTS idx_guest_partners_guest_id ON guest_partners(guest_id, sort_order);
CREATE INDEX IF NOT EXISTS idx_rsvp_partner_attendance_partner_id ON rsvp_partner_attendance(partner_id);

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

-- ---------------------------------------------------------------------------
-- Wedding weekend planner (admin-only operational planning tool)
-- ---------------------------------------------------------------------------
-- Generic checklist rows, grouped by `section` (e.g. 'master_checklist',
-- 'friday_arrival') and optionally `subsection` (e.g. '12 Months Before').
-- The admin UI auto-seeds default items per section from a template in code
-- the first time a section is opened with no rows yet.
CREATE TABLE IF NOT EXISTS planner_checklist_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  section TEXT NOT NULL,
  subsection TEXT,
  label TEXT NOT NULL,
  checked BOOLEAN NOT NULL DEFAULT false,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Vendor tracker (photographer, DJ, florist, etc.).
CREATE TABLE IF NOT EXISTS planner_vendors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  role TEXT NOT NULL,
  name TEXT,
  contact_name TEXT,
  phone TEXT,
  email TEXT,
  cost TEXT,
  notes TEXT,
  contract_signed BOOLEAN NOT NULL DEFAULT false,
  deposit_paid BOOLEAN NOT NULL DEFAULT false,
  final_payment_scheduled BOOLEAN NOT NULL DEFAULT false,
  arrival_confirmed BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS planner_vendor_payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vendor_id UUID NOT NULL REFERENCES planner_vendors(id) ON DELETE CASCADE,
  payment_date DATE,
  amount NUMERIC,
  paid BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Reception seating plan.
CREATE TABLE IF NOT EXISTS planner_seating_tables (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS planner_seating_seats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  table_id UUID NOT NULL REFERENCES planner_seating_tables(id) ON DELETE CASCADE,
  seat_label TEXT,
  guest_name TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0
);

-- Free-text key/value fields used across the planner (restaurant details,
-- important contact numbers, quick-reference notes).
CREATE TABLE IF NOT EXISTS planner_notes (
  key TEXT PRIMARY KEY,
  value TEXT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_guests_guest_code ON guests(guest_code);
CREATE INDEX IF NOT EXISTS idx_rsvps_guest_id ON rsvps(guest_id);
CREATE INDEX IF NOT EXISTS idx_comments_approved ON comments(approved, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_events_start_time ON events(start_time);
CREATE INDEX IF NOT EXISTS idx_gallery_photos_sort ON gallery_photos(sort_order, created_at);
CREATE INDEX IF NOT EXISTS idx_guest_photos_approved ON guest_photos(approved, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_planner_checklist_section ON planner_checklist_items(section, sort_order);
CREATE INDEX IF NOT EXISTS idx_planner_vendor_payments_vendor ON planner_vendor_payments(vendor_id);
CREATE INDEX IF NOT EXISTS idx_planner_seating_seats_table ON planner_seating_seats(table_id, sort_order);

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------
-- The site talks to Supabase directly from the browser using the public
-- "anon" key, so we lock every table down by default and only expose data
-- through SECURITY DEFINER functions below. This prevents anyone from using
-- the anon key to list/scrape the full guest table.

ALTER TABLE guests ENABLE ROW LEVEL SECURITY;
ALTER TABLE rsvps ENABLE ROW LEVEL SECURITY;
ALTER TABLE guest_partners ENABLE ROW LEVEL SECURITY;
ALTER TABLE rsvp_partner_attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE gallery_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE guest_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE planner_checklist_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE planner_vendors ENABLE ROW LEVEL SECURITY;
ALTER TABLE planner_vendor_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE planner_seating_tables ENABLE ROW LEVEL SECURITY;
ALTER TABLE planner_seating_seats ENABLE ROW LEVEL SECURITY;
ALTER TABLE planner_notes ENABLE ROW LEVEL SECURITY;

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

-- The browser can look up only the invitation associated with a code.
DROP FUNCTION IF EXISTS find_guest_by_code(TEXT);
CREATE OR REPLACE FUNCTION find_guest_by_code(p_code TEXT)
RETURNS TABLE (id UUID, first_name TEXT, partners JSONB)
LANGUAGE sql SECURITY DEFINER SET search_path = public
AS $$
  SELECT g.id, g.first_name,
         COALESCE((
           SELECT jsonb_agg(
             jsonb_build_object('id', p.id, 'first_name', p.first_name, 'sort_order', p.sort_order)
             ORDER BY p.sort_order
           )
           FROM guest_partners p WHERE p.guest_id = g.id
         ), '[]'::jsonb)
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
DROP FUNCTION IF EXISTS submit_rsvp(TEXT, BOOLEAN, INTEGER, TEXT, TEXT, TEXT, TEXT);
CREATE OR REPLACE FUNCTION submit_rsvp(
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
       SELECT 1 FROM unnest(v_partner_ids) selected(id)
       WHERE NOT EXISTS (
         SELECT 1 FROM guest_partners p
         WHERE p.id = selected.id AND p.guest_id = v_guest_id
       )
     ) THEN
    RETURN QUERY SELECT false, 'Invalid partner attendance selection';
    RETURN;
  END IF;

  INSERT INTO rsvps (
    guest_id, attending, guest_count,
    dietary_requirements, song_request, notes, submitted_at
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

DROP POLICY IF EXISTS "Admin can manage guest partners" ON guest_partners;
CREATE POLICY "Admin can manage guest partners" ON guest_partners
  FOR ALL TO authenticated USING (is_admin()) WITH CHECK (is_admin());

DROP POLICY IF EXISTS "Admin can read RSVP partner attendance" ON rsvp_partner_attendance;
CREATE POLICY "Admin can read RSVP partner attendance" ON rsvp_partner_attendance
  FOR SELECT TO authenticated USING (is_admin());

GRANT SELECT, INSERT, UPDATE, DELETE ON guest_partners TO authenticated;
GRANT SELECT ON rsvp_partner_attendance TO authenticated;

DROP POLICY IF EXISTS "Admin can read rsvps" ON rsvps;
CREATE POLICY "Admin can read rsvps" ON rsvps
  FOR SELECT TO authenticated USING (is_admin());

-- ---------------------------------------------------------------------------
-- Wedding weekend planner: admin-only, full access on every planner table.
-- ---------------------------------------------------------------------------
DROP POLICY IF EXISTS "Admin can manage checklist items" ON planner_checklist_items;
CREATE POLICY "Admin can manage checklist items" ON planner_checklist_items
  FOR ALL TO authenticated USING (is_admin()) WITH CHECK (is_admin());

DROP POLICY IF EXISTS "Admin can manage vendors" ON planner_vendors;
CREATE POLICY "Admin can manage vendors" ON planner_vendors
  FOR ALL TO authenticated USING (is_admin()) WITH CHECK (is_admin());

DROP POLICY IF EXISTS "Admin can manage vendor payments" ON planner_vendor_payments;
CREATE POLICY "Admin can manage vendor payments" ON planner_vendor_payments
  FOR ALL TO authenticated USING (is_admin()) WITH CHECK (is_admin());

DROP POLICY IF EXISTS "Admin can manage seating tables" ON planner_seating_tables;
CREATE POLICY "Admin can manage seating tables" ON planner_seating_tables
  FOR ALL TO authenticated USING (is_admin()) WITH CHECK (is_admin());

DROP POLICY IF EXISTS "Admin can manage seating seats" ON planner_seating_seats;
CREATE POLICY "Admin can manage seating seats" ON planner_seating_seats
  FOR ALL TO authenticated USING (is_admin()) WITH CHECK (is_admin());

DROP POLICY IF EXISTS "Admin can manage planner notes" ON planner_notes;
CREATE POLICY "Admin can manage planner notes" ON planner_notes
  FOR ALL TO authenticated USING (is_admin()) WITH CHECK (is_admin());

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
