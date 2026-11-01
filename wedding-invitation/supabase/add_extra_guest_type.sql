-- Run in the Supabase SQL editor before assigning guests to the Extra group.
ALTER TABLE guests DROP CONSTRAINT IF EXISTS guests_guest_type_check;
ALTER TABLE guests ADD CONSTRAINT guests_guest_type_check
  CHECK (guest_type IN ('standard', 'vip', 'family', 'wedding_party', 'extra'));
