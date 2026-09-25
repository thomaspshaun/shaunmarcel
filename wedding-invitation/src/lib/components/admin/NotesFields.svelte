<script lang="ts">
  import { onMount } from 'svelte';
  import { fetchNotes, saveNote } from '$lib/planner';

  let { fields }: { fields: { key: string; label: string }[] } = $props();

  let values: Record<string, string> = $state({});
  let loading = $state(true);
  let savingKey = $state('');

  onMount(async () => {
    try {
      values = await fetchNotes(fields.map((f) => f.key));
    } finally {
      loading = false;
    }
  });

  async function handleBlur(key: string) {
    savingKey = key;
    try {
      await saveNote(key, values[key] ?? '');
    } finally {
      savingKey = '';
    }
  }
</script>

{#if loading}
  <p class="text-sm text-slate-500">Loading...</p>
{:else}
  <div class="grid gap-4 sm:grid-cols-2">
    {#each fields as field (field.key)}
      <label class="block text-sm">
        <span class="font-medium text-slate-700">{field.label}</span>
        <input
          type="text"
          bind:value={values[field.key]}
          onblur={() => handleBlur(field.key)}
          class="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-rose-400 focus:ring-1 focus:ring-rose-400 focus:outline-none"
        />
        {#if savingKey === field.key}
          <span class="mt-1 block text-xs text-slate-400">Saving...</span>
        {/if}
      </label>
    {/each}
  </div>
{/if}
