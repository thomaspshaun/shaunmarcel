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
  let expandedItems = $state<Record<string, boolean>>({});
  let loading = $state(true);
  let saving = $state(false);
  let loadError = $state('');
  let saveError = $state('');
  let saveMessage = $state('');

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

  function formatTime(isoOrLocal: string): string {
    try {
      const d = new Date(isoOrLocal);
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
        start_ts: toLocalInputValue(d.start_ts),
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
      start_ts: toLocalInputValue(new Date().toISOString()),
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

<div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
  <div class="mb-6 flex flex-wrap items-center justify-between gap-4">
    <div>
      <h3 class="text-lg font-semibold text-slate-900">Wedding Schedule</h3>
      <p class="text-sm text-slate-500 mt-1">Click items to edit, drag to reorder, then Save</p>
    </div>
    <div class="flex gap-2">
      <div class="relative">
        <button
          type="button"
          class="rounded-lg border border-slate-300 bg-white px-4 py-2 text-sm font-medium hover:bg-slate-50"
          id="addBtn"
        >
          + Add Item
        </button>
        <div
          class="absolute right-0 top-full mt-1 hidden w-48 rounded-lg border border-slate-200 bg-white shadow-lg z-10"
          id="addMenu"
        >
          {#each SECTION_OPTIONS as section}
            <button
              type="button"
              class="w-full px-4 py-2 text-left text-sm hover:bg-slate-100 first:rounded-t-lg last:rounded-b-lg"
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
        class="rounded-lg bg-rose-500 px-4 py-2 text-sm font-medium text-white hover:bg-rose-600 disabled:cursor-not-allowed disabled:opacity-60"
        onclick={saveAll}
        disabled={saving}
      >
        {saving ? 'Saving...' : 'Save Changes'}
      </button>
    </div>
  </div>

  {#if loadError}
    <p class="mb-4 rounded-lg bg-amber-50 p-3 text-sm text-amber-700">{loadError}</p>
  {/if}
  {#if saveError}
    <p class="mb-4 rounded-lg bg-red-50 p-3 text-sm text-red-600">{saveError}</p>
  {/if}
  {#if saveMessage}
    <p class="mb-4 rounded-lg bg-green-50 p-3 text-sm text-green-700">{saveMessage}</p>
  {/if}

  {#if loading}
    <p class="text-center text-sm text-slate-500 py-8">Loading schedule...</p>
  {:else}
    <div class="space-y-3">
      {#each sections as section (section.name)}
        <div class="border border-slate-200 rounded-lg overflow-hidden">
          <button
            type="button"
            class="w-full flex items-center justify-between gap-3 bg-gradient-to-r from-rose-50 to-transparent px-4 py-3 text-left hover:bg-rose-100 transition-colors"
            onclick={() => {
              expandedSections[section.name] = !expandedSections[section.name];
            }}
          >
            <div class="flex items-center gap-3 flex-1">
              <span class="text-rose-400">{expandedSections[section.name] ? '▼' : '▶'}</span>
              <span class="font-semibold text-slate-900">{section.name}</span>
              <span class="inline-block bg-rose-100 text-rose-700 text-xs font-semibold px-2.5 py-0.5 rounded-full">
                {section.items.length} {section.items.length === 1 ? 'item' : 'items'}
              </span>
            </div>
          </button>

          {#if expandedSections[section.name]}
            <div class="divide-y divide-slate-100 bg-slate-50">
              {#if section.items.length === 0}
                <div class="px-4 py-6 text-center text-sm text-slate-500">
                  No items in this section. Click "+ Add Item" to get started.
                </div>
              {:else}
                {#each section.items as item, sectionIdx (item.id ?? `${section.name}-${sectionIdx}`)}
                  {@const globalIdx = items.indexOf(item)}
                  {@const itemKey = item.id ?? `${section.name}-${sectionIdx}`}
                  {@const isExpanded = expandedItems[itemKey]}
                  <div
                    class="border-l-4 border-rose-200 hover:bg-slate-100 transition-colors"
                    draggable={true}
                    ondragstart={(e) => handleDragStart(e, globalIdx)}
                    ondragover={handleDragOver}
                    ondrop={(e) => handleDrop(e, globalIdx)}
                  >
                    <!-- Summary View -->
                    <button
                      type="button"
                      class="w-full text-left px-4 py-3 flex items-start justify-between gap-3 hover:bg-white"
                      onclick={() => {
                        expandedItems[itemKey] = !expandedItems[itemKey];
                      }}
                    >
                      <div class="flex items-start gap-3 flex-1 min-w-0">
                        <span class="mt-1 cursor-grab select-none text-slate-300 shrink-0" title="Drag to reorder">⠿</span>
                        <div class="flex-1 min-w-0">
                          <div class="flex items-baseline gap-2 flex-wrap">
                            <span class="font-mono text-sm font-semibold text-rose-600">{formatTime(item.start_ts)}</span>
                            <span class="font-medium text-slate-900">{item.title}</span>
                          </div>
                          {#if item.notes}
                            <p class="text-xs text-slate-500 mt-1 line-clamp-1">{item.notes}</p>
                          {/if}
                        </div>
                      </div>
                      <span class="text-slate-400 shrink-0 mt-1">{isExpanded ? '▼' : '▶'}</span>
                    </button>

                    <!-- Edit Form (Expandable) -->
                    {#if isExpanded}
                      <div class="bg-white px-4 py-3 border-t border-slate-100 space-y-3">
                        <div class="grid grid-cols-1 gap-3 sm:grid-cols-2">
                          <div>
                            <label class="block text-xs font-medium text-slate-700 mb-1">Start Time</label>
                            <input
                              type="datetime-local"
                              bind:value={item.start_ts}
                              oninput={() => markDirty(globalIdx)}
                              class="w-full rounded-md border border-slate-300 px-2 py-1 text-sm focus:border-rose-400 focus:outline-none"
                            />
                          </div>
                          <div>
                            <label class="block text-xs font-medium text-slate-700 mb-1">Section</label>
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
                        <div>
                          <label class="block text-xs font-medium text-slate-700 mb-1">Title</label>
                          <input
                            type="text"
                            bind:value={item.title}
                            oninput={() => markDirty(globalIdx)}
                            placeholder="e.g. Ceremony"
                            class="w-full rounded-md border border-slate-300 px-2 py-1 text-sm focus:border-rose-400 focus:outline-none"
                          />
                        </div>
                        <div>
                          <label class="block text-xs font-medium text-slate-700 mb-1">Notes</label>
                          <textarea
                            bind:value={item.notes}
                            oninput={() => markDirty(globalIdx)}
                            rows={2}
                            placeholder="Details, location, instructions..."
                            class="w-full rounded-md border border-slate-300 px-2 py-1 text-sm focus:border-rose-400 focus:outline-none resize-none"
                          ></textarea>
                        </div>
                        <div class="flex justify-end gap-2 pt-2">
                          <button
                            type="button"
                            class="text-sm text-rose-600 hover:text-rose-700 hover:underline"
                            onclick={() => removeItem(globalIdx)}
                          >
                            Delete
                          </button>
                          <button
                            type="button"
                            class="text-sm text-slate-600 hover:text-slate-700"
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
        <div class="text-center py-12">
          <p class="text-sm text-slate-500 mb-3">No schedule items yet</p>
          <p class="text-xs text-slate-400">Click "+ Add Item" to build your wedding day timeline</p>
        </div>
      {/if}
    </div>
  {/if}
</div>

<style>
  textarea {
    resize: none;
  }
</style>
