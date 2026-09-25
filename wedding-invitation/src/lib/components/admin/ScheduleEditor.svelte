<script lang="ts">
  import { onMount } from 'svelte';
  import {
    fetchSchedule,
    addScheduleItem,
    updateScheduleItem,
    deleteScheduleItem,
    reorderScheduleItems,
    groupScheduleBySection,
    type PlannerScheduleItem,
    type ScheduleSection
  } from '$lib/planner-extras';

  interface ItemLocal {
    id: string | null;
    start_ts: string;
    title: string;
    notes: string;
    section: string;
    sort_order: number;
    dirty?: boolean;
  }

  const SECTION_OPTIONS = [
    'Arrival Plan',
    'Saturday Morning',
    'Saturday Afternoon',
    'Saturday Evening',
    'Sunday Morning',
    'Uncategorized'
  ];

  let items: ItemLocal[] = $state([]);
  let sections: ScheduleSection[] = $state([]);
  let expandedSections = $state<Record<string, boolean>>({});
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
        section: d.section || 'Uncategorized',
        sort_order: d.sort_order
      }));
      sections = groupScheduleBySection(items as any);
      // Expand all sections by default
      SECTION_OPTIONS.forEach((s) => {
        expandedSections[s] = true;
      });
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

  onMount(() => {
    load();
    
    // Setup dropdown menu for adding items
    const addBtn = document.getElementById('addBtn');
    const addMenu = document.getElementById('addMenu');
    if (addBtn && addMenu) {
      addBtn.addEventListener('click', () => {
        addMenu.classList.toggle('hidden');
      });
      document.addEventListener('click', (e) => {
        if (!addBtn.contains(e.target as Node) && !addMenu.contains(e.target as Node)) {
          addMenu.classList.add('hidden');
        }
      });
    }
  });

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
    sections = groupScheduleBySection(items as any);
  }

  function markDirty(idx: number) {
    items[idx].dirty = true;
  }

  function addBlank(section: string = 'Uncategorized') {
    items = [
      ...items,
      {
        id: null,
        start_ts: toLocalInputValue(new Date().toISOString()),
        title: 'New item',
        notes: '',
        section,
        sort_order: items.length,
        dirty: true
      }
    ];
    sections = groupScheduleBySection(items as any);
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
    sections = groupScheduleBySection(items as any);
  }

  async function saveAll() {
    saving = true;
    saveError = '';
    saveMessage = '';
    try {
      for (const it of items) {
        const isoStart = fromLocalInputValue(it.start_ts);
        if (!it.id) {
          const created = await addScheduleItem(isoStart, it.title, it.notes, it.section, it.sort_order);
          it.id = created.id;
          it.dirty = false;
        } else if (it.dirty) {
          await updateScheduleItem(it.id, {
            title: it.title,
            notes: it.notes,
            start_ts: isoStart,
            section: it.section,
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
      <div class="relative">
        <button
          type="button"
          class="rounded-full border border-slate-300 px-3 py-1 text-sm hover:bg-slate-50"
          id="addBtn"
          title="Add item to a specific section"
        >
          + Add Item ▼
        </button>
        <div
          class="absolute right-0 top-full mt-1 hidden w-40 rounded-lg border border-slate-200 bg-white shadow-lg"
          id="addMenu"
        >
          {#each SECTION_OPTIONS as section}
            <button
              type="button"
              class="w-full px-4 py-2 text-left text-sm hover:bg-slate-100"
              onclick={() => {
                addBlank(section);
                document.getElementById('addMenu')?.classList.add('hidden');
              }}
            >
              {section}
            </button>
          {/each}
        </div>
      </div>
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

  <p class="mt-2 text-xs text-slate-500">Drag items to reorder within their section, edit time/details, then click Save.</p>

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
    <div class="mt-4 space-y-4">
      {#each sections as section (section.name)}
        <div class="rounded-lg border border-slate-200 overflow-hidden">
          <button
            type="button"
            class="w-full flex items-center gap-2 bg-slate-50 px-4 py-3 text-left font-medium text-slate-900 hover:bg-slate-100"
            onclick={() => {
              expandedSections[section.name] = !expandedSections[section.name];
            }}
          >
            <span class="text-slate-400">{expandedSections[section.name] ? '▼' : '▶'}</span>
            <span>{section.name}</span>
            <span class="ml-auto text-xs font-normal text-slate-500">({section.items.length})</span>
          </button>

          {#if expandedSections[section.name]}
            <ul class="divide-y divide-slate-100">
              {#each section.items as item, idx (item.id ?? `${section.name}-${idx}`)}
                {@const globalIdx = items.indexOf(item)}
                <li
                  class="flex items-start gap-3 border-l-4 border-rose-200 p-3"
                  draggable={true}
                  ondragstart={(e) => handleDragStart(e, globalIdx)}
                  ondragover={handleDragOver}
                  ondrop={(e) => handleDrop(e, globalIdx)}
                >
                  <span class="mt-2 cursor-grab select-none text-slate-300" title="Drag to reorder">⠿</span>
                  <div class="flex-1 space-y-2">
                    <div class="flex gap-2">
                      <div class="w-44 shrink-0">
                        <input
                          type="datetime-local"
                          bind:value={item.start_ts}
                          oninput={() => markDirty(globalIdx)}
                          class="w-full rounded-md border border-slate-300 px-2 py-1 text-sm focus:border-rose-400 focus:outline-none"
                        />
                      </div>
                      <div class="w-32 shrink-0">
                        <select
                          bind:value={item.section}
                          oninput={() => markDirty(globalIdx)}
                          class="w-full rounded-md border border-slate-300 px-2 py-1 text-sm focus:border-rose-400 focus:outline-none"
                        >
                          {#each SECTION_OPTIONS as opt}
                            <option value={opt}>{opt}</option>
                          {/each}
                        </select>
                      </div>
                    </div>
                    <input
                      type="text"
                      bind:value={item.title}
                      oninput={() => markDirty(globalIdx)}
                      placeholder="Title (e.g. Ceremony)"
                      class="w-full rounded-md border border-slate-300 px-2 py-1 text-sm focus:border-rose-400 focus:outline-none"
                    />
                    <textarea
                      bind:value={item.notes}
                      oninput={() => markDirty(globalIdx)}
                      rows={2}
                      placeholder="Details / notes"
                      class="w-full rounded-md border border-slate-300 px-2 py-1 text-sm focus:border-rose-400 focus:outline-none"
                    ></textarea>
                    <div class="flex items-center justify-between text-xs text-slate-500">
                      <span></span>
                      <button type="button" class="text-rose-600 hover:underline" onclick={() => removeItem(globalIdx)}>Delete</button>
                    </div>
                  </div>
                </li>
              {/each}
            </ul>
          {/if}
        </div>
      {/each}

      {#if items.length === 0}
        <p class="mt-4 text-sm text-slate-500">No schedule items yet — click "+ Add Item" to start building the run sheet.</p>
      {/if}
    </div>
  {/if}
</div>

<style>
  textarea {
    resize: vertical;
  }
</style>