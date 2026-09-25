<script lang="ts">
  import { onMount } from 'svelte';
  import { fetchSchedule, addScheduleItem, updateScheduleItem, deleteScheduleItem, reorderScheduleItems } from '$lib/planner-extras';
  import { writable } from 'svelte/store';

  interface ItemLocal {
    id: string | null;
    start_ts: string;
    title: string;
    notes: string;
    sort_order: number;
    _dirty?: boolean;
  }

  const items = writable<ItemLocal[]>([]);
  let loading = false;
  let saving = false;

  async function load() {
    loading = true;
    try {
      const data = await fetchSchedule();
      items.set(
        data.map((d, i) => ({ id: d.id, start_ts: d.start_ts, title: d.title, notes: d.notes ?? '', sort_order: d.sort_order }))
      );
    } catch (err) {
      console.error('load schedule', err);
      alert('Could not load schedule. Check DB migration (planner_schedule).');
    } finally {
      loading = false;
    }
  }

  onMount(load);

  // Drag/drop helpers using native HTML5 dnd
  let dragIndex: number | null = null;

  function handleDragStart(e: DragEvent, idx: number) {
    dragIndex = idx;
    e.dataTransfer?.setData('text/plain', String(idx));
    e.dataTransfer?.setDragImage(document.createElement('div'), 0, 0);
  }

  function handleDragOver(e: DragEvent) {
    e.preventDefault();
  }

  function handleDrop(e: DragEvent, targetIndex: number) {
    e.preventDefault();
    const from = dragIndex;
    if (from === null) return;
    if (from === targetIndex) return;
    items.update((list) => {
      const copy = [...list];
      const [moved] = copy.splice(from, 1);
      copy.splice(targetIndex, 0, moved);
      // reassign sort_order
      return copy.map((it, idx) => ({ ...it, sort_order: idx, _dirty: true }));
    });
  }

  async function saveAll() {
    saving = true;
    try {
      const list = await new Promise<ItemLocal[]>((res) => items.subscribe((v) => res(v)));
      // First, upsert items that are new
      for (const it of list) {
        if (!it.id) {
          const created = await addScheduleItem(it.start_ts, it.title, it.notes, it.sort_order);
          it.id = created.id;
          it._dirty = false;
        } else if (it._dirty) {
          await updateScheduleItem(it.id, { title: it.title, notes: it.notes, start_ts: it.start_ts, sort_order: it.sort_order });
          it._dirty = false;
        }
      }
      // Then ensure ordering persisted
      const ordering = list.map((l) => ({ id: l.id!, sort_order: l.sort_order }));
      await reorderScheduleItems(ordering);
      // refresh
      await load();
      alert('Schedule saved');
    } catch (err) {
      console.error('saveAll', err);
      alert('Could not save schedule. See console.');
    } finally {
      saving = false;
    }
  }

  function addBlank() {
    items.update((list) => [...list, { id: null, start_ts: new Date().toISOString(), title: 'New item', notes: '', sort_order: list.length }]);
  }

  async function removeItem(id: string | null, idx: number) {
    if (!confirm('Delete this schedule item?')) return;
    if (id) {
      await deleteScheduleItem(id);
    }
    items.update((list) => {
      const copy = [...list];
      copy.splice(idx, 1);
      return copy.map((it, i) => ({ ...it, sort_order: i }));
    });
  }
</script>

<div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
  <div class="flex items-center justify-between">
    <h3 class="text-base font-medium text-slate-900">Editable Run Sheet</h3>
    <div class="flex gap-2">
      <button class="rounded-full border px-3 py-1 text-sm" on:click={addBlank}>Add Item</button>
      <button class="rounded-full bg-rose-500 text-white px-4 py-1 text-sm" on:click={saveAll} disabled={saving}>{saving ? 'Saving...' : 'Save'}</button>
    </div>
  </div>

  {#if loading}
    <p class="mt-4 text-sm text-slate-500">Loading schedule...</p>
  {:else}
    <ul class="mt-4 space-y-3">
      {#each $items as item, idx}
        <li
          class="flex items-start gap-3 rounded-lg border border-slate-100 p-3"
          draggable
          on:dragstart={(e) => handleDragStart(e, idx)}
          on:dragover={handleDragOver}
          on:drop={(e) => handleDrop(e, idx)}
        >
          <div class="w-40">
            <input type="datetime-local" bind:value={item.start_ts} on:input={() => (item._dirty = true)} class="w-full rounded-md border px-2 py-1 text-sm" />
          </div>
          <div class="flex-1">
            <input type="text" bind:value={item.title} on:input={() => (item._dirty = true)} class="w-full rounded-md border px-2 py-1 text-sm" />
            <textarea bind:value={item.notes} on:input={() => (item._dirty = true)} rows={2} class="mt-2 w-full rounded-md border px-2 py-1 text-sm"></textarea>
            <div class="mt-2 flex items-center justify-between text-xs text-slate-500">
              <div>Position: {item.sort_order + 1}</div>
              <div>
                <button class="mr-2 text-rose-600" on:click={() => removeItem(item.id, idx)}>Delete</button>
              </div>
            </div>
          </div>
        </li>
      {/each}
    </ul>
  {/if}
</div>

<style>
  /* small helpers */
  textarea { resize: vertical; }
</style>