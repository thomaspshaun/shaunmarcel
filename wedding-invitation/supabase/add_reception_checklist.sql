-- Add reception_checklist_items table (run this in Supabase SQL editor)

CREATE TABLE IF NOT EXISTS public.reception_checklist_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  completed boolean DEFAULT false,
  sort_order integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_reception_checklist_sort ON public.reception_checklist_items(sort_order);

-- Enable RLS
ALTER TABLE public.reception_checklist_items ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Admins can manage reception checklist" ON public.reception_checklist_items;

-- Create policy: admins can manage all items
CREATE POLICY "Admins can manage reception checklist" ON public.reception_checklist_items
  FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- Notes:
-- 1) Run this SQL in Supabase -> SQL Editor
-- 2) The is_admin() function should check the public.admins table (set up in previous migration)
-- 3) After running, refresh the admin page to test
