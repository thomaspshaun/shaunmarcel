<script lang="ts">
  import { onMount } from 'svelte';
  import {
    fetchSchedule,
    addScheduleItem,
    updateScheduleItem,
    deleteScheduleItem,
    reorderScheduleItems,
    type PlannerScheduleItem
  } from '$lib/planner-extras';

  interface ItemLocal {
    id: string | null;
    start_ts: string;
    title: string;
    notes: string;
    sort_order: number;
    dirty?: boolean;
  }

  let items: ItemLocal[] = $state([]);
  let loading = $state(true);
  let saving = $state(false);
  let loadError = $state('');
  let saveError = $state('');
  let saveMessage = $state('');

  // Convert a DB timestamptz (ISO string) to the value a
  // <input type="datetime-local"> needs, and back again.
  function toLocalInputValue(iso: string): string {
    const d = new Date(iso);
    if (Number.isNaN(d.getTime())) return '';
    const pad = (n: number) => String(n).padStart(2, '0');
    return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`;
  }

  function fromLocalInputValue(local: string): string {
    const d = new Date(local);
    return Number.isNaN(d.getTime()) ? new Date().toISOString() : d.toISOString();
  }

  async function load() {
    loading = true;
    loadError = '';
    try {
      const data = await fetchSchedule();
      items = data.map((d: PlannerScheduleItem) => ({
        id: d.id,
        start_ts: toLocalInputValue(d.start_ts),
        title: d.title,
        notes: d.notes ?? '',
        sort_order: d.sort_order
      }));
    } catch (err) {
      loadError =
        err instanceof Error
          ? `${err.message} — the "planner_schedule" table may not exist yet. Run supabase/add_schedule_venues.sql in your Supabase SQL editor, then reload this page.`
          : 'Could not load schedule.';
      items = [];
    } finally {
      loading = false;
    }
  }

  onMount(load);

  let dragIndex: number | null = null;

  function handleDragStart(e: DragEvent, idx: number) {
    dragIndex = idx;
    e.dataTransfer?.setData('text/plain', String(idx));
  }

  function handleDragOver(e: DragEvent) {
    e.preventDefault();
  }

  function handleDrop(e: DragEvent, targetIndex: number) {
    e.preventDefault();
    const from = dragIndex;
    dragIndex = null;
    if (from === null || from === targetIndex) return;
    const copy = [...items];
    const [moved] = copy.splice(from, 1);
    copy.splice(targetIndex, 0, moved);
    items = copy.map((it, idx) => ({ ...it, sort_order: idx, dirty: true }));
  }

  function markDirty(idx: number) {
    items[idx].dirty = true;
  }

  function addBlank() {
    items = [
      ...items,
      {
        id: null,
        start_ts: toLocalInputValue(new Date().toISOString()),
        title: 'New item',
        notes: '',
        sort_order: items.length,
        dirty: true
      }
    ];
  }

  async function removeItem(idx: number) {
    const item = items[idx];
    if (!confirm('Delete this schedule item?')) return;
    if (item.id) {
      try {
        await deleteScheduleItem(item.id);
      } catch (err) {
        saveError = err instanceof Error ? err.message : 'Could not delete item.';
        return;
      }
    }
    items = items.filter((_, i) => i !== idx).map((it, i) => ({ ...it, sort_order: i }));
  }

  async function saveAll() {
    saving = true;
    saveError = '';
    saveMessage = '';
    try {
      for (const it of items) {
        const isoStart = fromLocalInputValue(it.start_ts);
        if (!it.id) {
          const created = await addScheduleItem(isoStart, it.title, it.notes, it.sort_order);
          it.id = created.id;
          it.dirty = false;
        } else if (it.dirty) {
          await updateScheduleItem(it.id, {
            title: it.title,
            notes: it.notes,
            start_ts: isoStart,
            sort_order: it.sort_order
          });
          it.dirty = false;
        }
      }
      await reorderScheduleItems(items.filter((i) => i.id).map((i) => ({ id: i.id!, sort_order: i.sort_order })));
      saveMessage = 'Schedule saved.';
      await load();
    } catch (err) {
      saveError = err instanceof Error ? err.message : 'Could not save schedule.';
    } finally {
      saving = false;
    }
  }
</script>

<div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
  <div class="flex flex-wrap items-center justify-between gap-2">
    <h3 class="text-base font-medium text-slate-900">Editable Run Sheet</h3>
    <div class="flex gap-2">
      <button type="button" class="rounded-full border border-slate-300 px-3 py-1 text-sm hover:bg-slate-50" onclick={addBlank}>
        + Add Item
      </button>
      <button
        type="button"
        class="rounded-full bg-rose-500 px-4 py-1 text-sm font-medium text-white hover:bg-rose-600 disabled:cursor-not-allowed disabled:opacity-60"
        onclick={saveAll}
        disabled={saving}
      >
        {saving ? 'Saving...' : 'Save'}
      </button>
    </div>
  </div>

  <p class="mt-2 text-xs text-slate-500">Drag items by their handle to reorder, edit the time/details, then click Save.</p>

  {#if loadError}
    <p class="mt-3 rounded-lg bg-amber-50 p-3 text-sm text-amber-700">{loadError}</p>
  {/if}
  {#if saveError}
    <p class="mt-3 rounded-lg bg-red-50 p-3 text-sm text-red-600">{saveError}</p>
  {/if}
  {#if saveMessage}
    <p class="mt-3 rounded-lg bg-green-50 p-3 text-sm text-green-700">{saveMessage}</p>
  {/if}

  {#if loading}
    <p class="mt-4 text-sm text-slate-500">Loading schedule...</p>
  {:else}
    <ul class="mt-4 space-y-3">
      {#each items as item, idx (item.id ?? idx)}
        <li
          class="flex items-start gap-3 rounded-lg border border-slate-100 p-3"
          draggable={true}
          ondragstart={(e) => handleDragStart(e, idx)}
          ondragover={handleDragOver}
          ondrop={(e) => handleDrop(e, idx)}
        >
          <span class="mt-2 cursor-grab select-none text-slate-300" title="Drag to reorder">⠿</span>
          <div class="w-44 shrink-0">
            <input
              type="datetime-local"
              bind:value={item.start_ts}
              oninput={() => markDirty(idx)}
              class="w-full rounded-md border border-slate-300 px-2 py-1 text-sm focus:border-rose-400 focus:outline-none"
            />
          </div>
          <div class="flex-1">
            <input
              type="text"
              bind:value={item.title}
              oninput={() => markDirty(idx)}
              placeholder="Title (e.g. Ceremony)"
              class="w-full rounded-md border border-slate-300 px-2 py-1 text-sm focus:border-rose-400 focus:outline-none"
            />
            <textarea
              bind:value={item.notes}
              oninput={() => markDirty(idx)}
              rows={2}
              placeholder="Details / notes"
              class="mt-2 w-full rounded-md border border-slate-300 px-2 py-1 text-sm focus:border-rose-400 focus:outline-none"
            ></textarea>
            <div class="mt-2 flex items-center justify-between text-xs text-slate-500">
              <span>Position: {item.sort_order + 1}</span>
              <button type="button" class="text-rose-600 hover:underline" onclick={() => removeItem(idx)}>Delete</button>
            </div>
          </div>
        </li>
      {/each}
    </ul>
    {#if items.length === 0}
      <p class="mt-4 text-sm text-slate-500">No schedule items yet — click "+ Add Item" to start building the run sheet.</p>
    {/if}
  {/if}
</div>

<style>
  textarea {
    resize: vertical;
  }
</style>
