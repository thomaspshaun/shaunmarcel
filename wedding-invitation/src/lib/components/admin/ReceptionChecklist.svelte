<script lang="ts">
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabase';

  interface ChecklistItem {
    id: string;
    title: string;
    completed: boolean;
    sort_order: number;
  }

  let items: ChecklistItem[] = $state([]);
  let loading = $state(true);
  let saving = $state(false);
  let loadError = $state('');
  let saveError = $state('');
  let newItemTitle = $state('');
  let dragIndex: number | null = null;

  async function load() {
    loading = true;
    loadError = '';
    try {
      const { data, error } = await supabase
        .from('reception_checklist_items')
        .select('*')
        .order('sort_order', { ascending: true });

      if (error) throw new Error('Could not load reception checklist');
      items = data || [];
    } catch (err) {
      loadError = err instanceof Error ? err.message : 'Could not load checklist';
      items = [];
    } finally {
      loading = false;
    }
  }

  onMount(load);

  async function addItem() {
    if (!newItemTitle.trim()) return;

    saving = true;
    saveError = '';
    try {
      const { data, error } = await supabase
        .from('reception_checklist_items')
        .insert({
          title: newItemTitle.trim(),
          completed: false,
          sort_order: items.length
        })
        .select('*')
        .single();

      if (error || !data) throw new Error('Could not add item');

      items = [...items, data];
      newItemTitle = '';
    } catch (err) {
      saveError = err instanceof Error ? err.message : 'Could not add item';
    } finally {
      saving = false;
    }
  }

  async function toggleItem(item: ChecklistItem) {
    try {
      const { error } = await supabase
        .from('reception_checklist_items')
        .update({ completed: !item.completed })
        .eq('id', item.id);

      if (error) throw new Error('Could not update item');

      item.completed = !item.completed;
      items = items;
    } catch (err) {
      saveError = err instanceof Error ? err.message : 'Could not update item';
    }
  }

  async function deleteItem(id: string) {
    if (!confirm('Delete this item?')) return;

    try {
      const { error } = await supabase
        .from('reception_checklist_items')
        .delete()
        .eq('id', id);

      if (error) throw new Error('Could not delete item');

      items = items.filter((i) => i.id !== id);
    } catch (err) {
      saveError = err instanceof Error ? err.message : 'Could not delete item';
    }
  }

  async function editItem(item: ChecklistItem, newTitle: string) {
    if (!newTitle.trim()) return;

    try {
      const { error } = await supabase
        .from('reception_checklist_items')
        .update({ title: newTitle.trim() })
        .eq('id', item.id);

      if (error) throw new Error('Could not update item');

      item.title = newTitle.trim();
      items = items;
    } catch (err) {
      saveError = err instanceof Error ? err.message : 'Could not update item';
    }
  }

  function handleDragStart(e: DragEvent, idx: number) {
    dragIndex = idx;
    e.dataTransfer?.setData('text/plain', String(idx));
  }

  function handleDragOver(e: DragEvent) {
    e.preventDefault();
  }

  async function handleDrop(e: DragEvent, targetIndex: number) {
    e.preventDefault();
    const from = dragIndex;
    dragIndex = null;
    if (from === null || from === targetIndex) return;

    const copy = [...items];
    const [moved] = copy.splice(from, 1);
    copy.splice(targetIndex, 0, moved);

    items = copy;

    // Update sort order in database
    try {
      const updates = items.map((item, idx) =>
        supabase
          .from('reception_checklist_items')
          .update({ sort_order: idx })
          .eq('id', item.id)
      );
      await Promise.all(updates);
    } catch (err) {
      saveError = 'Could not reorder items';
    }
  }
</script>

<div class="rounded-2xl border border-slate-200 bg-white shadow-sm overflow-hidden">
  <!-- Header -->
  <div class="bg-gradient-to-r from-rose-50 to-transparent px-6 py-5 border-b border-slate-200">
    <div class="flex flex-wrap items-center justify-between gap-4">
      <div>
        <h2 class="text-2xl font-bold text-slate-900">Reception Checklist</h2>
        <p class="text-sm text-slate-600 mt-1">Check off tasks as you complete them</p>
      </div>
    </div>
  </div>

  <!-- Messages -->
  {#if loadError}
    <div class="bg-amber-50 border-b border-amber-200 px-6 py-3">
      <p class="text-sm text-amber-800">{loadError}</p>
    </div>
  {/if}
  {#if saveError}
    <div class="bg-red-50 border-b border-red-200 px-6 py-3">
      <p class="text-sm text-red-800">{saveError}</p>
    </div>
  {/if}

  <!-- Content -->
  <div class="p-6">
    {#if loading}
      <p class="text-slate-500">Loading checklist...</p>
    {:else}
      <!-- Add Item Form -->
      <form
        onsubmit={(e) => {
          e.preventDefault();
          addItem();
        }}
        class="mb-6 flex gap-2"
      >
        <input
          type="text"
          bind:value={newItemTitle}
          placeholder="Add new task (e.g., 'Tables arranged', 'Place cards set')"
          class="flex-1 rounded-lg border border-slate-300 px-4 py-2 text-sm focus:border-rose-400 focus:ring-1 focus:ring-rose-400 focus:outline-none"
        />
        <button
          type="submit"
          disabled={saving}
          class="rounded-lg bg-rose-500 px-5 py-2 text-sm font-semibold text-white hover:bg-rose-600 disabled:opacity-60 disabled:cursor-not-allowed transition-colors"
        >
          {saving ? 'Adding...' : '+ Add'}
        </button>
      </form>

      <!-- Checklist Items -->
      {#if items.length === 0}
        <div class="text-center py-12 bg-slate-50 rounded-lg border-2 border-dashed border-slate-200">
          <p class="text-slate-600 font-medium mb-2">No items yet</p>
          <p class="text-sm text-slate-500">Add a task above to get started</p>
        </div>
      {:else}
        <div class="space-y-2">
          {#each items as item, idx (item.id)}
            <div
              class="flex items-center gap-3 p-3 rounded-lg border border-slate-200 hover:bg-slate-50 transition-colors group"
              draggable={true}
              ondragstart={(e) => handleDragStart(e, idx)}
              ondragover={handleDragOver}
              ondrop={(e) => handleDrop(e, idx)}
            >
              <!-- Drag Handle -->
              <span
                class="cursor-grab select-none text-slate-300 group-hover:text-slate-400 shrink-0"
                title="Drag to reorder"
              >
                ⠿
              </span>

              <!-- Checkbox -->
              <input
                type="checkbox"
                checked={item.completed}
                onchange={() => toggleItem(item)}
                class="w-5 h-5 rounded border-slate-300 text-rose-500 focus:ring-rose-400 cursor-pointer shrink-0"
              />

              <!-- Task Title -->
              <input
                type="text"
                value={item.title}
                onblur={(e) => editItem(item, e.currentTarget.value)}
                class="flex-1 rounded-md border border-slate-200 px-3 py-1 text-sm {item.completed
                  ? 'line-through text-slate-400 bg-slate-50'
                  : 'text-slate-900'} focus:border-rose-400 focus:ring-1 focus:ring-rose-400 focus:outline-none"
              />

              <!-- Delete Button -->
              <button
                type="button"
                onclick={() => deleteItem(item.id)}
                class="text-slate-300 hover:text-red-500 transition-colors shrink-0 font-semibold"
              >
                ×
              </button>
            </div>
          {/each}
        </div>

        <!-- Summary -->
        {#if items.length > 0}
          {@const completed = items.filter((i) => i.completed).length}
          <div class="mt-4 pt-4 border-t border-slate-200">
            <p class="text-sm text-slate-600">
              <span class="font-semibold text-rose-600">{completed}</span>
              of
              <span class="font-semibold">{items.length}</span>
              {items.length === 1 ? 'task' : 'tasks'} completed
            </p>
            <div class="mt-2 h-2 bg-slate-200 rounded-full overflow-hidden">
              <div
                class="h-full bg-rose-500 rounded-full transition-all duration-300"
                style="width: {(completed / items.length) * 100}%"
              ></div>
            </div>
          </div>
        {/if}
      {/if}
    {/if}
  </div>
</div>

<style>
  input[type='checkbox'] {
    cursor: pointer;
  }
</style>
