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
    start_time: string; // HH:MM format for time input
    start_ts: string; // ISO for database
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

  const SECTION_COLORS: Record<string, string> = {
    'Arrival Plan': 'from-blue-50 to-transparent',
    'Saturday Morning': 'from-amber-50 to-transparent',
    'Saturday Afternoon': 'from-rose-50 to-transparent',
    'Saturday Evening': 'from-purple-50 to-transparent',
    'Sunday Morning': 'from-green-50 to-transparent',
    'Uncategorized': 'from-slate-50 to-transparent'
  };

  const SECTION_BADGE_COLORS: Record<string, string> = {
    'Arrival Plan': 'bg-blue-100 text-blue-700',
    'Saturday Morning': 'bg-amber-100 text-amber-700',
    'Saturday Afternoon': 'bg-rose-100 text-rose-700',
    'Saturday Evening': 'bg-purple-100 text-purple-700',
    'Sunday Morning': 'bg-green-100 text-green-700',
    'Uncategorized': 'bg-slate-100 text-slate-700'
  };

  let items: ItemLocal[] = $state([]);
  let sections: ScheduleSection[] = $state([]);
  let expandedSections = $state<Record<string, boolean>>({});
  let expandedItems = $state<Record<string, boolean>>({});
  let loading = $state(true);
  let saving = $state(false);
  let loadError = $state('');
  let saveError = $state('');
  let saveMessage = $state('');

  function timeStringToISO(timeStr: string, date: Date = new Date()): string {
    if (!timeStr) return date.toISOString();
    const [hours, minutes] = timeStr.split(':').map(Number);
    date.setHours(hours, minutes, 0, 0);
    return date.toISOString();
  }

  function isoToTimeString(iso: string): string {
    try {
      const d = new Date(iso);
      if (Number.isNaN(d.getTime())) return '';
      const pad = (n: number) => String(n).padStart(2, '0');
      return `${pad(d.getHours())}:${pad(d.getMinutes())}`;
    } catch {
      return '';
    }
  }

  async function load() {
    loading = true;
    loadError = '';
    try {
      const data = await fetchSchedule();
      items = data.map((d: PlannerScheduleItem) => ({
        id: d.id,
        start_ts: d.start_ts,
        start_time: isoToTimeString(d.start_ts),
        title: d.title,
        notes: d.notes ?? '',
        section: d.section || 'Uncategorized',
        sort_order: d.sort_order
      }));
      sections = groupScheduleBySection(items as any);
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

  function addBlank(section: string) {
    const newItem: ItemLocal = {
      id: null,
      start_ts: new Date().toISOString(),
      start_time: '14:00',
      title: 'New item',
      notes: '',
      section,
      sort_order: items.length,
      dirty: true
    };
    items = [...items, newItem];
    sections = groupScheduleBySection(items as any);
    const itemKey = `${section}-${items.length - 1}`;
    expandedItems[itemKey] = true;
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
        const isoStart = timeStringToISO(it.start_time);
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
      
      // Auto-collapse all items after save for cleaner view
      expandedItems = {};
      
      await load();
    } catch (err) {
      saveError = err instanceof Error ? err.message : 'Could not save schedule.';
    } finally {
      saving = false;
    }
  }
</script>

<div class="rounded-2xl border border-slate-200 bg-white shadow-sm overflow-hidden">
  <!-- Header -->
  <div class="bg-gradient-to-r from-slate-50 to-transparent px-6 py-5 border-b border-slate-200">
    <div class="flex flex-wrap items-center justify-between gap-4">
      <div>
        <h2 class="text-2xl font-bold text-slate-900">Wedding Schedule</h2>
        <p class="text-sm text-slate-600 mt-1">Click items to edit, drag to reorder, Save to persist</p>
      </div>
      <div class="flex gap-2">
        <div class="relative">
          <button
            type="button"
            class="rounded-lg border border-slate-300 bg-white px-4 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50 transition-colors"
            id="addBtn"
          >
            + Add Item
          </button>
          <div
            class="absolute right-0 top-full mt-1 hidden w-52 rounded-lg border border-slate-200 bg-white shadow-lg z-10"
            id="addMenu"
          >
            {#each SECTION_OPTIONS as section}
              <button
                type="button"
                class="w-full px-4 py-2.5 text-left text-sm hover:bg-slate-100 first:rounded-t-lg last:rounded-b-lg transition-colors"
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
          class="rounded-lg bg-rose-500 px-5 py-2 text-sm font-semibold text-white hover:bg-rose-600 disabled:cursor-not-allowed disabled:opacity-60 transition-colors"
          onclick={saveAll}
          disabled={saving}
        >
          {saving ? 'Saving...' : 'Save'}
        </button>
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
  {#if saveMessage}
    <div class="bg-green-50 border-b border-green-200 px-6 py-3">
      <p class="text-sm text-green-800">{saveMessage}</p>
    </div>
  {/if}

  <!-- Content -->
  <div class="p-6">
    {#if loading}
      <div class="text-center py-12">
        <p class="text-slate-500">Loading schedule...</p>
      </div>
    {:else}
      <div class="space-y-2">
        {#each sections as section (section.name)}
          <div class="border border-slate-200 rounded-lg overflow-hidden">
            <button
              type="button"
              class="w-full flex items-center justify-between gap-3 bg-gradient-to-r {SECTION_COLORS[section.name]} px-4 py-3 text-left hover:bg-opacity-50 transition-colors"
              onclick={() => {
                expandedSections[section.name] = !expandedSections[section.name];
              }}
            >
              <div class="flex items-center gap-3 flex-1">
                <span class="text-slate-400 text-lg">{expandedSections[section.name] ? '▼' : '▶'}</span>
                <span class="font-bold text-slate-900">{section.name}</span>
                <span class="inline-flex items-center gap-1 {SECTION_BADGE_COLORS[section.name]} text-xs font-semibold px-2.5 py-1 rounded-full ml-auto">
                  {section.items.length}
                </span>
              </div>
            </button>

            {#if expandedSections[section.name]}
              <div class="divide-y divide-slate-100 bg-slate-50">
                {#if section.items.length === 0}
                  <div class="px-4 py-6 text-center text-sm text-slate-500">
                    No items. Click "+ Add Item" to create one.
                  </div>
                {:else}
                  {#each section.items as item, sectionIdx (item.id ?? `${section.name}-${sectionIdx}`)}
                    {@const globalIdx = items.indexOf(item)}
                    {@const itemKey = item.id ?? `${section.name}-${sectionIdx}`}
                    {@const isExpanded = expandedItems[itemKey]}
                    <div
                      class="border-l-4 border-slate-300 hover:bg-white transition-colors"
                      draggable={true}
                      ondragstart={(e) => handleDragStart(e, globalIdx)}
                      ondragover={handleDragOver}
                      ondrop={(e) => handleDrop(e, globalIdx)}
                    >
                      <!-- Summary -->
                      <button
                        type="button"
                        class="w-full text-left px-4 py-3 flex items-start justify-between gap-3 group hover:bg-white"
                        onclick={() => {
                          expandedItems[itemKey] = !expandedItems[itemKey];
                        }}
                      >
                        <div class="flex items-start gap-3 flex-1 min-w-0">
                          <span class="cursor-grab select-none text-slate-300 group-hover:text-slate-400 shrink-0 mt-0.5" title="Drag to reorder">⠿</span>
                          <div class="flex-1 min-w-0">
                            <div class="flex items-baseline gap-3 flex-wrap">
                              <span class="font-mono font-bold text-base text-rose-600">{item.start_time}</span>
                              <span class="font-semibold text-slate-900">{item.title}</span>
                            </div>
                            {#if item.notes}
                              <p class="text-sm text-slate-600 mt-1 line-clamp-1">·  {item.notes}</p>
                            {/if}
                          </div>
                        </div>
                        <span class="text-slate-400 shrink-0 mt-0.5">{isExpanded ? '▼' : '▶'}</span>
                      </button>

                      <!-- Edit Form -->
                      {#if isExpanded}
                        <div class="bg-white px-4 py-4 border-t border-slate-100 space-y-3">
                          <div class="grid grid-cols-1 gap-3 sm:grid-cols-2">
                            <div>
                              <label class="block text-xs font-semibold text-slate-700 mb-2 uppercase tracking-wide">Time</label>
                              <input
                                type="time"
                                bind:value={item.start_time}
                                oninput={() => markDirty(globalIdx)}
                                class="w-full rounded-md border border-slate-300 px-3 py-2 text-sm focus:border-rose-400 focus:ring-1 focus:ring-rose-400 focus:outline-none"
                              />
                            </div>
                            <div>
                              <label class="block text-xs font-semibold text-slate-700 mb-2 uppercase tracking-wide">Section</label>
                              <select
                                bind:value={item.section}
                                oninput={() => markDirty(globalIdx)}
                                class="w-full rounded-md border border-slate-300 px-3 py-2 text-sm focus:border-rose-400 focus:ring-1 focus:ring-rose-400 focus:outline-none"
                              >
                                {#each SECTION_OPTIONS as opt}
                                  <option value={opt}>{opt}</option>
                                {/each}
                              </select>
                            </div>
                          </div>
                          <div>
                            <label class="block text-xs font-semibold text-slate-700 mb-2 uppercase tracking-wide">Title</label>
                            <input
                              type="text"
                              bind:value={item.title}
                              oninput={() => markDirty(globalIdx)}
                              placeholder="e.g., Ceremony, Dinner Service, First Dance"
                              class="w-full rounded-md border border-slate-300 px-3 py-2 text-sm focus:border-rose-400 focus:ring-1 focus:ring-rose-400 focus:outline-none"
                            />
                          </div>
                          <div>
                            <label class="block text-xs font-semibold text-slate-700 mb-2 uppercase tracking-wide">Notes & Details</label>
                            <textarea
                              bind:value={item.notes}
                              oninput={() => markDirty(globalIdx)}
                              rows={2}
                              placeholder="Location, instructions, or details..."
                              class="w-full rounded-md border border-slate-300 px-3 py-2 text-sm focus:border-rose-400 focus:ring-1 focus:ring-rose-400 focus:outline-none resize-none"
                            ></textarea>
                          </div>
                          <div class="flex justify-between items-center pt-2 border-t border-slate-100">
                            <button
                              type="button"
                              class="text-sm font-medium text-red-600 hover:text-red-700 hover:underline"
                              onclick={() => removeItem(globalIdx)}
                            >
                              Delete
                            </button>
                            <button
                              type="button"
                              class="text-sm font-medium text-slate-600 hover:text-slate-700 hover:underline"
                              onclick={() => {
                                expandedItems[itemKey] = false;
                              }}
                            >
                              Collapse
                            </button>
                          </div>
                        </div>
                      {/if}
                    </div>
                  {/each}
                {/if}
              </div>
            {/if}
          </div>
        {/each}

        {#if items.length === 0}
          <div class="text-center py-16 bg-slate-50 rounded-lg border-2 border-dashed border-slate-200">
            <p class="text-slate-600 font-medium mb-2">No schedule items yet</p>
            <p class="text-sm text-slate-500">Click "+ Add Item" to build your wedding timeline</p>
          </div>
        {/if}
      </div>
    {/if}
  </div>
</div>

<style>
  textarea {
    resize: none;
  }
</style>
