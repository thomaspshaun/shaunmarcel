-- Add planner_schedule and planner_venues (run this in Supabase SQL editor)

CREATE TABLE IF NOT EXISTS planner_schedule (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  start_ts timestamptz NOT NULL,
  title text NOT NULL,
  notes text,
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_planner_schedule_sort ON planner_schedule(sort_order);

CREATE TABLE IF NOT EXISTS planner_venues (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  contact_name text,
  phone text,
  email text,
  address text,
  capacity integer,
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_planner_venues_name ON planner_venues(name);

-- RLS (requires is_admin() to be defined in your schema.sql)
ALTER TABLE planner_schedule ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage schedule" ON planner_schedule;
CREATE POLICY "Admins can manage schedule" ON planner_schedule
  FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

ALTER TABLE planner_venues ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage venues" ON planner_venues;
CREATE POLICY "Admins can manage venues" ON planner_venues
  FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- If you re-run this file and want a trigger for updated_at, create set_updated_at() in schema.sql or reuse existing.

-- Notes:
-- 1) Run this SQL in Supabase -> SQL Editor.
-- 2) After running, open the admin page and sign in as the admin user; the Schedule and Venue tabs will be able to read/write rows.
