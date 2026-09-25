-- Add all wedding checklist tables (run this in Supabase SQL editor)

-- Master Wedding Countdown Checklist
CREATE TABLE IF NOT EXISTS public.master_wedding_checklist (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  completed boolean DEFAULT false,
  sort_order integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_master_wedding_checklist_sort ON public.master_wedding_checklist(sort_order);
ALTER TABLE public.master_wedding_checklist ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage master wedding checklist" ON public.master_wedding_checklist;
CREATE POLICY "Admins can manage master wedding checklist" ON public.master_wedding_checklist
  FOR ALL TO authenticated USING (is_admin()) WITH CHECK (is_admin());

-- Guest Communications Checklist
CREATE TABLE IF NOT EXISTS public.guest_communications_checklist (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  completed boolean DEFAULT false,
  sort_order integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_guest_communications_checklist_sort ON public.guest_communications_checklist(sort_order);
ALTER TABLE public.guest_communications_checklist ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage guest communications checklist" ON public.guest_communications_checklist;
CREATE POLICY "Admins can manage guest communications checklist" ON public.guest_communications_checklist
  FOR ALL TO authenticated USING (is_admin()) WITH CHECK (is_admin());

-- Venue Checklist
CREATE TABLE IF NOT EXISTS public.venue_checklist (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  completed boolean DEFAULT false,
  sort_order integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_venue_checklist_sort ON public.venue_checklist(sort_order);
ALTER TABLE public.venue_checklist ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage venue checklist" ON public.venue_checklist;
CREATE POLICY "Admins can manage venue checklist" ON public.venue_checklist
  FOR ALL TO authenticated USING (is_admin()) WITH CHECK (is_admin());

-- Ceremony Checklist
CREATE TABLE IF NOT EXISTS public.ceremony_checklist (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  completed boolean DEFAULT false,
  sort_order integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_ceremony_checklist_sort ON public.ceremony_checklist(sort_order);
ALTER TABLE public.ceremony_checklist ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage ceremony checklist" ON public.ceremony_checklist;
CREATE POLICY "Admins can manage ceremony checklist" ON public.ceremony_checklist
  FOR ALL TO authenticated USING (is_admin()) WITH CHECK (is_admin());

-- Wedding Emergency Kit Checklist
CREATE TABLE IF NOT EXISTS public.emergency_kit_checklist (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  completed boolean DEFAULT false,
  sort_order integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_emergency_kit_checklist_sort ON public.emergency_kit_checklist(sort_order);
ALTER TABLE public.emergency_kit_checklist ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage emergency kit checklist" ON public.emergency_kit_checklist;
CREATE POLICY "Admins can manage emergency kit checklist" ON public.emergency_kit_checklist
  FOR ALL TO authenticated USING (is_admin()) WITH CHECK (is_admin());

-- Notes:
-- 1) Run this SQL in Supabase -> SQL Editor
-- 2) All tables use the same schema: id, title, completed, sort_order, timestamps
-- 3) All tables have RLS policies requiring is_admin() role
-- 4) Refresh admin page after running this migration
