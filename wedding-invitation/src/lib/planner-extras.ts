import { supabase } from '$lib/supabase';

export interface PlannerScheduleItem {
  id: string;
  start_ts: string; // ISO timestamptz string
  title: string;
  notes: string | null;
  section: string; // e.g., 'Arrival Plan', 'Saturday Morning', etc.
  sort_order: number;
  created_at: string;
  updated_at?: string;
}

export interface ScheduleSection {
  name: string;
  items: PlannerScheduleItem[];
}

export interface PlannerVenue {
  id: string;
  name: string;
  contact_name?: string | null;
  phone?: string | null;
  email?: string | null;
  address?: string | null;
  capacity?: number | null;
  notes?: string | null;
  created_at?: string;
  updated_at?: string;
}

// -------------------- Schedule CRUD --------------------
export async function fetchSchedule(): Promise<PlannerScheduleItem[]> {
  const { data, error } = await supabase
    .from('planner_schedule')
    .select('*')
    .order('sort_order', { ascending: true });
  if (error) {
    console.error('fetchSchedule error', error);
    throw new Error('Could not load schedule');
  }
  return data as PlannerScheduleItem[];
}

export async function addScheduleItem(startTs: string, title: string, notes: string | null, section: string = 'Uncategorized', sortOrder = 0) {
  const { data, error } = await supabase
    .from('planner_schedule')
    .insert({ start_ts: startTs, title, notes, section, sort_order: sortOrder })
    .select('*')
    .single();
  if (error || !data) throw new Error('Could not add schedule item');
  return data as PlannerScheduleItem;
}

export async function updateScheduleItem(id: string, patch: Partial<PlannerScheduleItem>) {
  const patchToSave: any = {};
  if (patch.title !== undefined) patchToSave.title = patch.title;
  if (patch.notes !== undefined) patchToSave.notes = patch.notes;
  if (patch.start_ts !== undefined) patchToSave.start_ts = patch.start_ts;
  if (patch.sort_order !== undefined) patchToSave.sort_order = patch.sort_order;
  if (patch.section !== undefined) patchToSave.section = patch.section;

  const { error } = await supabase.from('planner_schedule').update(patchToSave).eq('id', id);
  if (error) throw new Error('Could not update schedule item');
}

export async function deleteScheduleItem(id: string) {
  const { error } = await supabase.from('planner_schedule').delete().eq('id', id);
  if (error) throw new Error('Could not delete schedule item');
}

export async function reorderScheduleItems(items: { id: string; sort_order: number }[]) {
  // Batch update sort_order for existing items
  const updates = items.map((item) =>
    supabase
      .from('planner_schedule')
      .update({ sort_order: item.sort_order })
      .eq('id', item.id)
  );
  const results = await Promise.all(updates);
  const errors = results.filter((r) => r.error);
  if (errors.length > 0) throw new Error('Could not reorder schedule items');
}

// Helper: Group schedule items by section with logical ordering
export function groupScheduleBySection(items: PlannerScheduleItem[]): ScheduleSection[] {
  // Define default section order
  const sectionOrder = [
    'Arrival Plan',
    'Saturday Morning',
    'Saturday Afternoon',
    'Saturday Evening',
    'Sunday Morning',
    'Uncategorized'
  ];

  const grouped: { [key: string]: PlannerScheduleItem[] } = {};

  // Group items by section
  items.forEach((item) => {
    if (!grouped[item.section]) {
      grouped[item.section] = [];
    }
    grouped[item.section].push(item);
  });

  // Sort items within each section by sort_order
  Object.keys(grouped).forEach((section) => {
    grouped[section].sort((a, b) => a.sort_order - b.sort_order);
  });

  // Return sections in defined order
  return sectionOrder
    .filter((section) => grouped[section])
    .map((name) => ({ name, items: grouped[name] }))
    .concat(
      Object.keys(grouped)
        .filter((section) => !sectionOrder.includes(section))
        .map((name) => ({ name, items: grouped[name] }))
    );
}

// -------------------- Venue CRUD --------------------
export async function fetchVenues(): Promise<PlannerVenue[]> {
  const { data, error } = await supabase.from('planner_venues').select('*').order('created_at', { ascending: true });
  if (error) throw new Error('Could not load venues');
  return data as PlannerVenue[];
}

export async function addVenue(name: string): Promise<PlannerVenue> {
  const { data, error } = await supabase.from('planner_venues').insert({ name }).select('*').single();
  if (error || !data) throw new Error('Could not add venue');
  return data as PlannerVenue;
}

export async function updateVenue(id: string, patch: Partial<PlannerVenue>): Promise<void> {
  const { error } = await supabase.from('planner_venues').update(patch).eq('id', id);
  if (error) throw new Error('Could not update venue');
}

export async function deleteVenue(id: string): Promise<void> {
  const { error } = await supabase.from('planner_venues').delete().eq('id', id);
  if (error) throw new Error('Could not delete venue');
}
