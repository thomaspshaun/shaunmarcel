-- Sample guests for testing the RSVP flow locally / on dev.
-- Safe to run multiple times (guest_code is unique, so re-running will error
-- on conflict — delete existing test rows first if you need to re-seed).

INSERT INTO guests (first_name, last_name, email, guest_code, guest_type, guest_allowance)
VALUES
  ('Test', 'Guest', 'test.guest@example.com', 'TEST1234', 'standard', 2),
  ('VIP', 'Guest', 'vip.guest@example.com', 'VIP1234', 'vip', 2)
ON CONFLICT (guest_code) DO NOTHING;
