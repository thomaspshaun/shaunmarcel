import { supabase } from '$lib/supabase';

export interface ChecklistGroup {
  id: string;
  slug: string | null;
  name: string;
  category: string;
  schedule_item_id: string | null;
  sort_order: number;
  created_at: string;
  updated_at?: string;
}

export interface ChecklistItem {
  id: string;
  group_id: string;
  title: string;
  completed: boolean;
  sort_order: number;
  created_at: string;
  updated_at?: string;
}

// -------------------- Group helpers --------------------

/** Fetch a group by its stable slug. Returns null if it doesn't exist yet. */
export async function fetchGroupBySlug(slug: string): Promise<ChecklistGroup | null> {
  const { data, error } = await supabase
    .from('checklist_groups')
    .select('*')
    .eq('slug', slug)
    .maybeSingle();
  if (error) throw new Error('Could not load checklist group');
  return (data as ChecklistGroup) ?? null;
}

/** Fetch or create a group by slug (used by fixed/static checklist blocks). */
export async function getOrCreateGroupBySlug(
  slug: string,
  name: string,
  category: string
): Promise<ChecklistGroup> {
  const existing = await fetchGroupBySlug(slug);
  if (existing) return existing;

  const { data, error } = await supabase
    .from('checklist_groups')
    .insert({ slug, name, category })
    .select('*')
    .single();
  if (error || !data) throw new Error('Could not create checklist group');
  return data as ChecklistGroup;
}

/** Fetch all groups, optionally filtered by category. Schedule-linked groups include schedule item title. */
export async function fetchGroups(category?: string): Promise<ChecklistGroup[]> {
  let query = supabase.from('checklist_groups').select('*').order('sort_order', { ascending: true });
  if (category) query = query.eq('category', category);
  const { data, error } = await query;
  if (error) throw new Error('Could not load checklists');
  return (data as ChecklistGroup[]) || [];
}

/** Create a new custom checklist group, optionally linked to a schedule item. */
export async function addGroup(
  name: string,
  category: string = 'custom',
  scheduleItemId: string | null = null
): Promise<ChecklistGroup> {
  const { data, error } = await supabase
    .from('checklist_groups')
    .insert({ name, category, schedule_item_id: scheduleItemId })
    .select('*')
    .single();
  if (error || !data) throw new Error('Could not create checklist');
  return data as ChecklistGroup;
}

export async function renameGroup(id: string, name: string): Promise<void> {
  const { error } = await supabase.from('checklist_groups').update({ name }).eq('id', id);
  if (error) throw new Error('Could not rename checklist');
}

export async function deleteGroup(id: string): Promise<void> {
  const { error } = await supabase.from('checklist_groups').delete().eq('id', id);
  if (error) throw new Error('Could not delete checklist');
}

// -------------------- Item helpers --------------------

export async function fetchItems(groupId: string): Promise<ChecklistItem[]> {
  const { data, error } = await supabase
    .from('checklist_items')
    .select('*')
    .eq('group_id', groupId)
    .order('sort_order', { ascending: true });
  if (error) throw new Error('Could not load checklist items');
  return (data as ChecklistItem[]) || [];
}

export async function addItem(groupId: string, title: string, sortOrder: number): Promise<ChecklistItem> {
  const { data, error } = await supabase
    .from('checklist_items')
    .insert({ group_id: groupId, title, completed: false, sort_order: sortOrder })
    .select('*')
    .single();
  if (error || !data) throw new Error('Could not add item');
  return data as ChecklistItem;
}

export async function toggleItem(id: string, completed: boolean): Promise<void> {
  const { error } = await supabase.from('checklist_items').update({ completed }).eq('id', id);
  if (error) throw new Error('Could not update item');
}

export async function editItem(id: string, title: string): Promise<void> {
  const { error } = await supabase.from('checklist_items').update({ title }).eq('id', id);
  if (error) throw new Error('Could not update item');
}

export async function deleteItem(id: string): Promise<void> {
  const { error } = await supabase.from('checklist_items').delete().eq('id', id);
  if (error) throw new Error('Could not delete item');
}

export async function reorderItems(items: { id: string; sort_order: number }[]): Promise<void> {
  const updates = items.map((item) =>
    supabase.from('checklist_items').update({ sort_order: item.sort_order }).eq('id', item.id)
  );
  const results = await Promise.all(updates);
  if (results.some((r) => r.error)) throw new Error('Could not reorder items');
}