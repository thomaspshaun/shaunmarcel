CREATE TABLE IF NOT EXISTS public.admin_todo_lists (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL CHECK (char_length(btrim(title)) BETWEEN 1 AND 120),
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.admin_todo_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  list_id uuid NOT NULL REFERENCES public.admin_todo_lists(id) ON DELETE CASCADE,
  title text NOT NULL CHECK (char_length(btrim(title)) BETWEEN 1 AND 240),
  status text NOT NULL DEFAULT 'not_started'
    CHECK (status IN ('not_started', 'in_progress', 'completed')),
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_admin_todo_items_list_order
  ON public.admin_todo_items(list_id, sort_order, created_at);

ALTER TABLE public.admin_todo_lists ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_todo_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can manage to-do lists" ON public.admin_todo_lists;
CREATE POLICY "Admins can manage to-do lists" ON public.admin_todo_lists
  FOR ALL TO authenticated USING (is_admin()) WITH CHECK (is_admin());

DROP POLICY IF EXISTS "Admins can manage to-do items" ON public.admin_todo_items;
CREATE POLICY "Admins can manage to-do items" ON public.admin_todo_items
  FOR ALL TO authenticated USING (is_admin()) WITH CHECK (is_admin());

GRANT SELECT, INSERT, UPDATE, DELETE ON public.admin_todo_lists TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.admin_todo_items TO authenticated;
