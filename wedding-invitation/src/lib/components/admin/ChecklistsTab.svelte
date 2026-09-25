<script lang="ts">
  import { onMount } from 'svelte';
  import { fetchGroups, addGroup, deleteGroup, renameGroup, type ChecklistGroup } from '$lib/checklists';
  import { fetchSchedule, type PlannerScheduleItem } from '$lib/planner-extras';
  import UnifiedChecklist from './UnifiedChecklist.svelte';

  let groups: ChecklistGroup[] = $state([]);
  let scheduleItems: PlannerScheduleItem[] = $state([]);
  let loading = $state(true);
  let loadError = $state('');

  let selectedScheduleItemId = $state('');
  let customName = $state('');
  let creating = $state(false);
  let createError = $state('');

  async function load() {
    loading = true;
    loadError = '';
    try {
      const [g, s] = await Promise.all([fetchGroups(), fetchSchedule()]);
      groups = g;
      scheduleItems = s;
    } catch (err) {
      loadError = err instanceof Error ? err.message : 'Could not load checklists';
    } finally {
      loading = false;
    }
  }

  onMount(load);

  // Schedule items that don't already have a linked checklist
  const availableScheduleItems = $derived(
    scheduleItems.filter((s) => !groups.some((g) => g.schedule_item_id === s.id))
  );

  async function handleAddFromSchedule(e: Event) {
    e.preventDefault();
    if (!selectedScheduleItemId) return;
    const scheduleItem = scheduleItems.find((s) => s.id === selectedScheduleItemId);
    if (!scheduleItem) return;

    creating = true;
    createError = '';
    try {
      const created = await addGroup(scheduleItem.title, 'schedule', scheduleItem.id);
      groups = [...groups, created];
      selectedScheduleItemId = '';
    } catch (err) {
      createError = err instanceof Error ? err.message : 'Could not create checklist';
    } finally {
      creating = false;
    }
  }

  async function handleAddCustom(e: Event) {
    e.preventDefault();
    if (!customName.trim()) return;

    creating = true;
    createError = '';
    try {
      const created = await addGroup(customName.trim(), 'custom');
      groups = [...groups, created];
      customName = '';
    } catch (err) {
      createError = err instanceof Error ? err.message : 'Could not create checklist';
    } finally {
      creating = false;
    }
  }

  async function handleRemoveGroup(group: ChecklistGroup) {
    if (!confirm(`Delete the "${group.name}" checklist and all its items?`)) return;
    try {
      await deleteGroup(group.id);
      groups = groups.filter((g) => g.id !== group.id);
    } catch (err) {
      loadError = err instanceof Error ? err.message : 'Could not delete checklist';
    }
  }

  function categoryBadge(category: string): string {
    switch (category) {
      case 'schedule':
        return 'bg-rose-100 text-rose-700';
      case 'custom':
        return 'bg-purple-100 text-purple-700';
      default:
        return 'bg-slate-100 text-slate-600';
    }
  }
</script>

<div class="space-y-8">
  <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
    <h2 class="text-lg font-medium text-slate-900">All Checklists</h2>
    <p class="mt-1 text-sm text-slate-500">
      Every checklist block lives here — including static planning checklists and any you create for
      specific schedule items below.
    </p>

    <div class="mt-5 grid gap-4 sm:grid-cols-2">
      <form onsubmit={handleAddFromSchedule} class="flex flex-wrap gap-2">
        <select
          bind:value={selectedScheduleItemId}
          class="min-w-[12rem] flex-1 rounded-xl border border-slate-300 px-4 py-2.5 text-sm focus:border-rose-400 focus:outline-none"
        >
          <option value="">Link checklist to schedule item...</option>
          {#each availableScheduleItems as item (item.id)}
            <option value={item.id}>{item.section} — {item.title}</option>
          {/each}
        </select>
        <button
          type="submit"
          disabled={!selectedScheduleItemId || creating}
          class="rounded-full bg-rose-500 px-5 py-2.5 text-sm font-medium text-white hover:bg-rose-600 disabled:cursor-not-allowed disabled:opacity-60"
        >
          Add
        </button>
      </form>

      <form onsubmit={handleAddCustom} class="flex flex-wrap gap-2">
        <input
          type="text"
          placeholder="New custom checklist name..."
          bind:value={customName}
          class="min-w-[12rem] flex-1 rounded-xl border border-slate-300 px-4 py-2.5 text-sm focus:border-rose-400 focus:outline-none"
        />
        <button
          type="submit"
          disabled={!customName.trim() || creating}
          class="rounded-full bg-slate-800 px-5 py-2.5 text-sm font-medium text-white hover:bg-slate-900 disabled:cursor-not-allowed disabled:opacity-60"
        >
          Add
        </button>
      </form>
    </div>

    {#if createError}
      <p class="mt-3 text-sm text-red-600">{createError}</p>
    {/if}
  </div>

  {#if loadError}
    <p class="rounded-lg bg-amber-50 p-3 text-sm text-amber-700">{loadError}</p>
  {/if}

  {#if loading}
    <p class="text-sm text-slate-500">Loading checklists...</p>
  {:else if groups.length === 0}
    <p class="text-sm text-slate-500">No checklists yet — add one above.</p>
  {:else}
    <div class="grid gap-6 lg:grid-cols-2">
      {#each groups as group (group.id)}
        <div class="relative">
          <div class="absolute right-4 top-4 z-10 flex items-center gap-2">
            <span class="rounded-full px-2.5 py-1 text-xs font-medium {categoryBadge(group.category)}">
              {group.category}
            </span>
            <button
              type="button"
              onclick={() => handleRemoveGroup(group)}
              class="rounded-full bg-white/80 px-2 py-1 text-xs text-slate-400 hover:text-red-500 shadow-sm"
              title="Delete checklist"
            >
              Delete
            </button>
          </div>
          <UnifiedChecklist groupId={group.id} name={group.name} category={group.category} />
        </div>
      {/each}
    </div>
  {/if}
</div>