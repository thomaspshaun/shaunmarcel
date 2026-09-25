-- Add section column to planner_schedule (run this in Supabase SQL editor)

ALTER TABLE planner_schedule 
ADD COLUMN section text DEFAULT 'Uncategorized';

CREATE INDEX IF NOT EXISTS idx_planner_schedule_section ON planner_schedule(section);

-- Notes:
-- 1) Run this SQL in Supabase -> SQL Editor
-- 2) The section column defaults to 'Uncategorized' for existing items
-- 3) Use section values like: 'Arrival Plan', 'Saturday Morning', 'Saturday Afternoon', 'Saturday Evening', 'Sunday Morning'
