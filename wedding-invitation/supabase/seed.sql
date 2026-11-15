-- Sample guests for testing the RSVP flow locally / on dev.
-- Safe to run multiple times (guest_code is unique, so re-running will error
-- on conflict — delete existing test rows first if you need to re-seed).

INSERT INTO guests (first_name, whatsapp_number, guest_code)
VALUES
  ('Test', '0820000000', 'TEST1234'),
  ('VIP', '0820000001', 'VIP1234')
ON CONFLICT (guest_code) DO NOTHING;

INSERT INTO guest_partners (guest_id, first_name, sort_order)
SELECT id, 'Partner', 1 FROM guests WHERE guest_code = 'TEST1234'
ON CONFLICT (guest_id, sort_order) DO NOTHING;
