-- Unified Checklist System
-- Replaces: master_wedding_checklist, guest_communications_checklist,
--           venue_checklist, ceremony_checklist, emergency_kit_checklist
-- Adds: ability to create checklist blocks linked to wedding schedule items
-- Run this in Supabase -> SQL Editor
--
-- Safe to run whether or not the old per-checklist tables exist:
-- migration steps use dynamic SQL guarded by to_regclass() checks, so a
-- missing old table is silently skipped instead of raising an error.

-- ============================================================
-- 1. Core tables
-- ============================================================

CREATE TABLE IF NOT EXISTS public.checklist_groups (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text UNIQUE,                 -- stable key for fixed/static checklists (null for dynamic ones)
  name text NOT NULL,
  category text NOT NULL DEFAULT 'general', -- overview | guests | venue | ceremony | emergency | schedule | custom
  schedule_item_id uuid REFERENCES public.planner_schedule(id) ON DELETE CASCADE,
  sort_order integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.checklist_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id uuid NOT NULL REFERENCES public.checklist_groups(id) ON DELETE CASCADE,
  title text NOT NULL,
  completed boolean DEFAULT false,
  sort_order integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_checklist_groups_category ON public.checklist_groups(category);
CREATE INDEX IF NOT EXISTS idx_checklist_groups_schedule_item ON public.checklist_groups(schedule_item_id);
CREATE INDEX IF NOT EXISTS idx_checklist_items_group ON public.checklist_items(group_id, sort_order);

ALTER TABLE public.checklist_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.checklist_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can manage checklist groups" ON public.checklist_groups;
CREATE POLICY "Admins can manage checklist groups" ON public.checklist_groups
  FOR ALL TO authenticated USING (is_admin()) WITH CHECK (is_admin());

DROP POLICY IF EXISTS "Admins can manage checklist items" ON public.checklist_items;
CREATE POLICY "Admins can manage checklist items" ON public.checklist_items
  FOR ALL TO authenticated USING (is_admin()) WITH CHECK (is_admin());

-- ============================================================
-- 2. Seed the 5 fixed checklist groups (always safe, idempotent)
-- ============================================================

INSERT INTO public.checklist_groups (slug, name, category, sort_order) VALUES
  ('master_wedding', 'Master Wedding Countdown Checklist', 'overview', 0),
  ('guest_communications', 'Guest Communications Checklist', 'guests', 0),
  ('venue_general', 'General Venue Checklist', 'venue', 0),
  ('ceremony', 'Ceremony Checklist', 'ceremony', 0),
  ('emergency_kit', 'Wedding Emergency Kit', 'emergency', 0)
ON CONFLICT (slug) DO NOTHING;

-- ============================================================
-- 3. Migrate data from old standalone tables, if they exist
--    (skips silently if a given old table was never created)
-- ============================================================

DO $$
DECLARE
  mapping record;
BEGIN
  FOR mapping IN
    SELECT * FROM (VALUES
      ('public.master_wedding_checklist', 'master_wedding'),
      ('public.guest_communications_checklist', 'guest_communications'),
      ('public.venue_checklist', 'venue_general'),
      ('public.ceremony_checklist', 'ceremony'),
      ('public.emergency_kit_checklist', 'emergency_kit')
    ) AS m(old_table, new_slug)
  LOOP
    IF to_regclass(mapping.old_table) IS NOT NULL THEN
      EXECUTE format(
        'INSERT INTO public.checklist_items (group_id, title, completed, sort_order, created_at, updated_at)
         SELECT g.id, t.title, t.completed, t.sort_order, t.created_at, t.updated_at
         FROM %s t
         JOIN public.checklist_groups g ON g.slug = %L
         WHERE NOT EXISTS (
           SELECT 1 FROM public.checklist_items ci WHERE ci.group_id = g.id AND ci.title = t.title
         )',
        mapping.old_table, mapping.new_slug
      );
      RAISE NOTICE 'Migrated data from % into checklist group %', mapping.old_table, mapping.new_slug;
    ELSE
      RAISE NOTICE 'Skipped % (table does not exist)', mapping.old_table;
    END IF;
  END LOOP;
END $$;

-- ============================================================
-- 4. Once you've confirmed the migration in the app, you can
--    drop any old standalone tables that do exist:
-- ============================================================
-- DROP TABLE IF EXISTS public.master_wedding_checklist;
-- DROP TABLE IF EXISTS public.guest_communications_checklist;
-- DROP TABLE IF EXISTS public.venue_checklist;
-- DROP TABLE IF EXISTS public.ceremony_checklist;
-- DROP TABLE IF EXISTS public.emergency_kit_checklist;