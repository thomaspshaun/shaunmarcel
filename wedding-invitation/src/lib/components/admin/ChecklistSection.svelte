<script lang="ts">
  import { onMount } from 'svelte';
  import {
    fetchChecklistItems,
    toggleChecklistItem,
    addChecklistItem,
    deleteChecklistItem,
    type ChecklistItem
  } from '$lib/planner';

  let { section, title = '' }: { section: string; title?: string } = $props();

  let items: ChecklistItem[] = $state([]);
  let loading = $state(true);
  let loadError = $state('');
  let newLabel = $state('');
  let newSubsection = $state('');

  onMount(load);

  async function load() {
    loading = true;
    loadError = '';
    try {
      items = await fetchChecklistItems(section);
    } catch (err) {
      loadError = err instanceof Error ? err.message : 'Could not load checklist.';
    } finally {
      loading = false;
    }
  }

  const grouped = $derived.by(() => {
    const groups = new Map<string, ChecklistItem[]>();
    for (const item of items) {
      const key = item.subsection ?? '';
      if (!groups.has(key)) groups.set(key, []);
      groups.get(key)!.push(item);
    }
    return Array.from(groups.entries());
  });

  const progress = $derived.by(() => {
    const total = items.length;
    const done = items.filter((i) => i.checked).length;
    return { total, done };
  });

  async function handleToggle(item: ChecklistItem) {
    const next = !item.checked;
    item.checked = next;
    items = [...items];
    try {
      await toggleChecklistItem(item.id, next);
    } catch {
      item.checked = !next;
      items = [...items];
    }
  }

  async function handleAdd(e: Event) {
    e.preventDefault();
    if (!newLabel.trim()) return;
    try {
      const created = await addChecklistItem(
        section,
        newSubsection.trim() || null,
        newLabel.trim(),
        items.length
      );
      items = [...items, created];
      newLabel = '';
    } catch (err) {
      loadError = err instanceof Error ? err.message : 'Could not add item.';
    }
  }

  async function handleDelete(item: ChecklistItem) {
    items = items.filter((i) => i.id !== item.id);
    try {
      await deleteChecklistItem(item.id);
    } catch {
      await load();
    }
  }
</script>

<div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
  {#if title}
    <div class="flex items-center justify-between">
      <h3 class="text-base font-medium text-slate-900">{title}</h3>
      {#if progress.total > 0}
        <span class="text-xs text-slate-500">{progress.done}/{progress.total} done</span>
      {/if}
    </div>
  {/if}

  {#if loading}
    <p class="mt-3 text-sm text-slate-500">Loading...</p>
  {:else if loadError}
    <p class="mt-3 text-sm text-red-600">{loadError}</p>
  {:else}
    <div class="mt-3 space-y-4">
      {#each grouped as [subsection, groupItems] (subsection)}
        <div>
          {#if subsection}
            <p class="text-xs font-semibold tracking-wide text-rose-500 uppercase">{subsection}</p>
          {/if}
          <ul class="mt-2 space-y-1.5">
            {#each groupItems as item (item.id)}
              <li class="group flex items-center gap-2 text-sm">
                <input
                  type="checkbox"
                  checked={item.checked}
                  onchange={() => handleToggle(item)}
                  class="h-4 w-4 shrink-0 rounded border-slate-300 text-rose-500 focus:ring-rose-400"
                />
                <span class={item.checked ? 'flex-1 text-slate-400 line-through' : 'flex-1 text-slate-700'}>
                  {item.label}
                </span>
                <button
                  type="button"
                  onclick={() => handleDelete(item)}
                  class="text-xs text-slate-300 opacity-0 transition hover:text-red-500 group-hover:opacity-100"
                >
                  Remove
                </button>
              </li>
            {/each}
          </ul>
        </div>
      {/each}
    </div>

    <form onsubmit={handleAdd} class="mt-4 flex flex-wrap gap-2 border-t border-slate-100 pt-4">
      <input
        type="text"
        placeholder="Subsection (optional)"
        bind:value={newSubsection}
        class="w-40 rounded-lg border border-slate-300 px-3 py-1.5 text-sm focus:border-rose-400 focus:ring-1 focus:ring-rose-400 focus:outline-none"
      />
      <input
        type="text"
        placeholder="Add an item..."
        bind:value={newLabel}
        class="min-w-[10rem] flex-1 rounded-lg border border-slate-300 px-3 py-1.5 text-sm focus:border-rose-400 focus:ring-1 focus:ring-rose-400 focus:outline-none"
      />
      <button
        type="submit"
        class="rounded-full bg-rose-500 px-4 py-1.5 text-sm font-medium text-white transition hover:bg-rose-600"
      >
        Add
      </button>
    </form>
  {/if}
</div>
