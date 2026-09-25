// Data layer for the admin-only wedding weekend planner. All access here
// relies on the admin RLS policies in supabase/schema.sql — every table is
// locked to `is_admin()` for authenticated users, never exposed to the anon
// key used by the public site.
import { supabase } from "$lib/supabase";
import { checklistTemplates } from "$lib/planner-templates";

export interface ChecklistItem {
  id: string;
  section: string;
  subsection: string | null;
  label: string;
  checked: boolean;
  sort_order: number;
}

export interface PlannerVendor {
  id: string;
  role: string;
  name: string | null;
  contact_name: string | null;
  phone: string | null;
  email: string | null;
  cost: string | null;
  notes: string | null;
  contract_signed: boolean;
  deposit_paid: boolean;
  final_payment_scheduled: boolean;
  arrival_confirmed: boolean;
  created_at: string;
}

export interface VendorPayment {
  id: string;
  vendor_id: string;
  payment_date: string | null;
  amount: number | null;
  paid: boolean;
}

export interface SeatingTable {
  id: string;
  name: string;
  sort_order: number;
}

export interface SeatingSeat {
  id: string;
  table_id: string;
  seat_label: string | null;
  guest_name: string | null;
  sort_order: number;
}

// ---------------------------------------------------------------------------
// Checklists
// ---------------------------------------------------------------------------

export async function fetchChecklistItems(section: string): Promise<ChecklistItem[]> {
  const { data, error } = await supabase
    .from("planner_checklist_items")
    .select("*")
    .eq("section", section)
    .order("sort_order", { ascending: true });

  if (error) {
    console.error("fetchChecklistItems error", error);
    throw new Error("Could not load checklist.");
  }

  if (data && data.length > 0) {
    return data as ChecklistItem[];
  }

  // Auto-seed defaults the first time this section is opened.
  const template = checklistTemplates[section];
  if (!template || template.length === 0) return [];

  const rows = template.map((item, index) => ({
    section,
    subsection: item.subsection,
    label: item.label,
    sort_order: index,
  }));

  const { data: seeded, error: seedError } = await supabase
    .from("planner_checklist_items")
    .insert(rows)
    .select("*");

  if (seedError) {
    console.error("seed checklist error", seedError);
    return [];
  }

  return (seeded as ChecklistItem[]).sort((a, b) => a.sort_order - b.sort_order);
}

export async function toggleChecklistItem(id: string, checked: boolean): Promise<void> {
  const { error } = await supabase
    .from("planner_checklist_items")
    .update({ checked })
    .eq("id", id);
  if (error) throw new Error("Could not update checklist item.");
}

export async function addChecklistItem(
  section: string,
  subsection: string | null,
  label: string,
  sortOrder: number,
): Promise<ChecklistItem> {
  const { data, error } = await supabase
    .from("planner_checklist_items")
    .insert({ section, subsection, label, sort_order: sortOrder })
    .select("*")
    .single();
  if (error || !data) throw new Error("Could not add checklist item.");
  return data as ChecklistItem;
}

export async function deleteChecklistItem(id: string): Promise<void> {
  const { error } = await supabase.from("planner_checklist_items").delete().eq("id", id);
  if (error) throw new Error("Could not delete checklist item.");
}

// ---------------------------------------------------------------------------
// Vendors
// ---------------------------------------------------------------------------

export async function fetchVendors(): Promise<PlannerVendor[]> {
  const { data, error } = await supabase
    .from("planner_vendors")
    .select("*")
    .order("created_at", { ascending: true });
  if (error) throw new Error("Could not load vendors.");
  return data as PlannerVendor[];
}

export async function addVendor(role: string, name: string): Promise<PlannerVendor> {
  const { data, error } = await supabase
    .from("planner_vendors")
    .insert({ role, name })
    .select("*")
    .single();
  if (error || !data) throw new Error("Could not add vendor.");
  return data as PlannerVendor;
}

export async function updateVendor(id: string, patch: Partial<PlannerVendor>): Promise<void> {
  const { error } = await supabase.from("planner_vendors").update(patch).eq("id", id);
  if (error) throw new Error("Could not update vendor.");
}

export async function deleteVendor(id: string): Promise<void> {
  const { error } = await supabase.from("planner_vendors").delete().eq("id", id);
  if (error) throw new Error("Could not delete vendor.");
}

export async function fetchVendorPayments(vendorId: string): Promise<VendorPayment[]> {
  const { data, error } = await supabase
    .from("planner_vendor_payments")
    .select("*")
    .eq("vendor_id", vendorId)
    .order("payment_date", { ascending: true });
  if (error) throw new Error("Could not load payments.");
  return data as VendorPayment[];
}

export async function addVendorPayment(
  vendorId: string,
  paymentDate: string | null,
  amount: number | null,
): Promise<VendorPayment> {
  const { data, error } = await supabase
    .from("planner_vendor_payments")
    .insert({ vendor_id: vendorId, payment_date: paymentDate, amount })
    .select("*")
    .single();
  if (error || !data) throw new Error("Could not add payment.");
  return data as VendorPayment;
}

export async function updateVendorPayment(id: string, patch: Partial<VendorPayment>): Promise<void> {
  const { error } = await supabase.from("planner_vendor_payments").update(patch).eq("id", id);
  if (error) throw new Error("Could not update payment.");
}

export async function deleteVendorPayment(id: string): Promise<void> {
  const { error } = await supabase.from("planner_vendor_payments").delete().eq("id", id);
  if (error) throw new Error("Could not delete payment.");
}

// ---------------------------------------------------------------------------
// Seating plan
// ---------------------------------------------------------------------------

export async function fetchSeatingTables(): Promise<SeatingTable[]> {
  const { data, error } = await supabase
    .from("planner_seating_tables")
    .select("*")
    .order("sort_order", { ascending: true });
  if (error) throw new Error("Could not load seating tables.");
  return data as SeatingTable[];
}

export async function addSeatingTable(name: string, sortOrder: number): Promise<SeatingTable> {
  const { data, error } = await supabase
    .from("planner_seating_tables")
    .insert({ name, sort_order: sortOrder })
    .select("*")
    .single();
  if (error || !data) throw new Error("Could not add table.");
  return data as SeatingTable;
}

export async function deleteSeatingTable(id: string): Promise<void> {
  const { error } = await supabase.from("planner_seating_tables").delete().eq("id", id);
  if (error) throw new Error("Could not delete table.");
}

export async function fetchSeatingSeats(tableId: string): Promise<SeatingSeat[]> {
  const { data, error } = await supabase
    .from("planner_seating_seats")
    .select("*")
    .eq("table_id", tableId)
    .order("sort_order", { ascending: true });
  if (error) throw new Error("Could not load seats.");
  return data as SeatingSeat[];
}

export async function addSeatingSeat(
  tableId: string,
  seatLabel: string,
  guestName: string,
  sortOrder: number,
): Promise<SeatingSeat> {
  const { data, error } = await supabase
    .from("planner_seating_seats")
    .insert({ table_id: tableId, seat_label: seatLabel, guest_name: guestName, sort_order: sortOrder })
    .select("*")
    .single();
  if (error || !data) throw new Error("Could not add seat.");
  return data as SeatingSeat;
}

export async function updateSeatingSeat(id: string, patch: Partial<SeatingSeat>): Promise<void> {
  const { error } = await supabase.from("planner_seating_seats").update(patch).eq("id", id);
  if (error) throw new Error("Could not update seat.");
}

export async function deleteSeatingSeat(id: string): Promise<void> {
  const { error } = await supabase.from("planner_seating_seats").delete().eq("id", id);
  if (error) throw new Error("Could not delete seat.");
}

// ---------------------------------------------------------------------------
// Free-text notes (key/value)
// ---------------------------------------------------------------------------

export async function fetchNotes(keys: string[]): Promise<Record<string, string>> {
  const { data, error } = await supabase.from("planner_notes").select("key, value").in("key", keys);
  if (error) throw new Error("Could not load notes.");
  const out: Record<string, string> = {};
  for (const row of data ?? []) {
    out[row.key] = row.value ?? "";
  }
  return out;
}

export async function saveNote(key: string, value: string): Promise<void> {
  const { error } = await supabase
    .from("planner_notes")
    .upsert({ key, value, updated_at: new Date().toISOString() });
  if (error) throw new Error("Could not save note.");
}
