<script lang="ts">
  import { onMount } from 'svelte';
  import { fetchVenues, addVenue, updateVenue, deleteVenue, type PlannerVenue } from '$lib/planner-extras';
  import ChecklistSection from './ChecklistSection.svelte';

  interface VenueLocal extends PlannerVenue {
    saving?: boolean;
    saved?: boolean;
  }

  let venues: VenueLocal[] = $state([]);
  let loading = $state(true);
  let loadError = $state('');
  let newName = $state('');
  let addingError = $state('');

  async function load() {
    loading = true;
    loadError = '';
    try {
      venues = (await fetchVenues()) as VenueLocal[];
    } catch (err) {
      loadError =
        err instanceof Error
          ? `${err.message} — the "planner_venues" table may not exist yet. Run supabase/add_schedule_venues.sql in your Supabase SQL editor, then reload this page.`
          : 'Could not load venues.';
      venues = [];
    } finally {
      loading = false;
    }
  }

  onMount(load);

  async function handleAddVenue(e: Event) {
    e.preventDefault();
    if (!newName.trim()) return;
    addingError = '';
    try {
      const created = await addVenue(newName.trim());
      venues = [...venues, created];
      newName = '';
    } catch (err) {
      addingError = err instanceof Error ? err.message : 'Could not add venue.';
    }
  }

  async function saveVenue(v: VenueLocal) {
    if (!v.id) return;
    v.saving = true;
    v.saved = false;
    try {
      await updateVenue(v.id, {
        name: v.name,
        contact_name: v.contact_name,
        phone: v.phone,
        email: v.email,
        address: v.address,
        capacity: v.capacity,
        notes: v.notes
      });
      v.saved = true;
    } catch (err) {
      loadError = err instanceof Error ? err.message : 'Could not save venue.';
    } finally {
      v.saving = false;
      venues = [...venues];
    }
  }

  async function removeVenue(v: VenueLocal) {
    if (!v.id) return;
    if (!confirm(`Remove venue "${v.name}"?`)) return;
    try {
      await deleteVenue(v.id);
      venues = venues.filter((x) => x.id !== v.id);
    } catch (err) {
      loadError = err instanceof Error ? err.message : 'Could not delete venue.';
    }
  }
</script>

<div class="space-y-8">
  <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
    <h2 class="text-lg font-medium text-slate-900">Add a Venue</h2>
    <form onsubmit={handleAddVenue} class="mt-4 flex flex-wrap gap-3">
      <input
        type="text"
        placeholder="Venue / estate name"
        bind:value={newName}
        class="min-w-[12rem] flex-1 rounded-xl border border-slate-300 px-4 py-2.5 text-sm focus:border-rose-400 focus:outline-none"
      />
      <button type="submit" class="rounded-full bg-rose-500 px-6 py-2.5 text-sm font-medium text-white hover:bg-rose-600">
        Add Venue
      </button>
    </form>
    {#if addingError}
      <p class="mt-2 text-sm text-red-600">{addingError}</p>
    {/if}
  </div>

  {#if loadError}
    <p class="rounded-lg bg-amber-50 p-3 text-sm text-amber-700">{loadError}</p>
  {/if}

  {#if loading}
    <p class="text-sm text-slate-500">Loading venues...</p>
  {:else if venues.length === 0 && !loadError}
    <p class="text-sm text-slate-500">No venues yet — add your ceremony/reception venue above.</p>
  {:else}
    <div class="grid gap-5 lg:grid-cols-2">
      {#each venues as v (v.id)}
        <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
          <div class="flex items-start justify-between gap-2">
            <input
              type="text"
              bind:value={v.name}
              class="w-full rounded-lg border-0 p-0 text-base font-medium text-slate-900 focus:ring-0"
            />
            <button type="button" class="text-xs text-slate-300 hover:text-red-500" onclick={() => removeVenue(v)}>
              Remove
            </button>
          </div>

          <div class="mt-3 grid grid-cols-2 gap-3 text-sm">
            <label class="block">
              <span class="text-xs text-slate-500">Contact name</span>
              <input
                type="text"
                bind:value={v.contact_name}
                class="mt-0.5 w-full rounded-lg border border-slate-300 px-2 py-1 text-sm focus:border-rose-400 focus:outline-none"
              />
            </label>
            <label class="block">
              <span class="text-xs text-slate-500">Phone</span>
              <input
                type="text"
                bind:value={v.phone}
                class="mt-0.5 w-full rounded-lg border border-slate-300 px-2 py-1 text-sm focus:border-rose-400 focus:outline-none"
              />
            </label>
            <label class="block">
              <span class="text-xs text-slate-500">Email</span>
              <input
                type="email"
                bind:value={v.email}
                class="mt-0.5 w-full rounded-lg border border-slate-300 px-2 py-1 text-sm focus:border-rose-400 focus:outline-none"
              />
            </label>
            <label class="block">
              <span class="text-xs text-slate-500">Capacity</span>
              <input
                type="number"
                bind:value={v.capacity}
                class="mt-0.5 w-full rounded-lg border border-slate-300 px-2 py-1 text-sm focus:border-rose-400 focus:outline-none"
              />
            </label>
          </div>

          <label class="mt-3 block text-sm">
            <span class="text-xs text-slate-500">Address / layout notes</span>
            <textarea
              bind:value={v.address}
              rows="2"
              class="mt-0.5 w-full rounded-lg border border-slate-300 px-2 py-1 text-sm focus:border-rose-400 focus:outline-none"
            ></textarea>
          </label>

          <label class="mt-3 block text-sm">
            <span class="text-xs text-slate-500">Notes</span>
            <textarea
              bind:value={v.notes}
              rows="2"
              class="mt-0.5 w-full rounded-lg border border-slate-300 px-2 py-1 text-sm focus:border-rose-400 focus:outline-none"
            ></textarea>
          </label>

          <div class="mt-3 flex items-center gap-3">
            <button
              type="button"
              class="rounded-full bg-rose-500 px-4 py-1.5 text-sm font-medium text-white hover:bg-rose-600 disabled:cursor-not-allowed disabled:opacity-60"
              onclick={() => saveVenue(v)}
              disabled={v.saving}
            >
              {v.saving ? 'Saving...' : 'Save'}
            </button>
            {#if v.saved}
              <span class="text-xs text-green-600">Saved</span>
            {/if}
          </div>
        </div>
      {/each}
    </div>
  {/if}

  <div>
    <h2 class="text-lg font-medium text-slate-900">General Venue Checklist</h2>
    <div class="mt-3">
      <ChecklistSection section="venue_checklist" title="Venue Booking & Planning" />
    </div>
  </div>
</div>
