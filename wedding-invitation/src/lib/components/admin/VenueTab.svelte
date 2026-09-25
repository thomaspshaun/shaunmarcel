<script lang="ts">
  import { onMount } from 'svelte';
  import { fetchVenues, addVenue, updateVenue, deleteVenue } from '$lib/planner-extras';
  import { writable } from 'svelte/store';

  interface VenueLocal {
    id: string | null;
    name: string;
    contact_name?: string;
    phone?: string;
    email?: string;
    address?: string;
    capacity?: number;
    notes?: string;
  }

  const venues = writable<VenueLocal[]>([]);
  let loading = false;

  async function load() {
    loading = true;
    try {
      const data = await fetchVenues();
      venues.set(data.map((d) => ({ ...d })));
    } catch (err) {
      console.error('fetchVenues', err);
      alert('Could not load venues. Run DB migration (planner_venues).');
    } finally {
      loading = false;
    }
  }

  onMount(load);

  async function addNew() {
    const name = prompt('Venue name');
    if (!name) return;
    const created = await addVenue(name);
    venues.update((v) => [...v, created]);
  }

  async function saveVenue(v: VenueLocal) {
    if (!v.id) return;
    await updateVenue(v.id, v);
    alert('Saved');
  }

  async function removeVenue(id: string | null) {
    if (!id) return;
    if (!confirm('Delete this venue?')) return;
    await deleteVenue(id);
    venues.update((v) => v.filter((x) => x.id !== id));
  }
</script>

<div class="space-y-6">
  <div class="flex items-center justify-between">
    <h2 class="text-lg font-medium text-slate-900">Venues</h2>
    <div>
      <button class="rounded-full bg-rose-500 px-4 py-1 text-white" on:click={addNew}>Add Venue</button>
    </div>
  </div>

  {#if loading}
    <p class="text-sm text-slate-500">Loading venues...</p>
  {:else}
    <div class="grid gap-4">
      {#each $venues as v (v.id)}
        <div class="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
          <div class="flex items-start gap-4">
            <div class="flex-1">
              <input class="w-full rounded-md border px-3 py-2 text-sm" bind:value={v.name} />
              <div class="mt-2 grid grid-cols-1 gap-2 sm:grid-cols-2">
                <input placeholder="Contact name" class="rounded-md border px-3 py-2 text-sm" bind:value={v.contact_name} />
                <input placeholder="Phone" class="rounded-md border px-3 py-2 text-sm" bind:value={v.phone} />
                <input placeholder="Email" class="rounded-md border px-3 py-2 text-sm" bind:value={v.email} />
                <input placeholder="Capacity" type="number" class="rounded-md border px-3 py-2 text-sm" bind:value={v.capacity} />
              </div>
              <textarea placeholder="Address / notes" class="mt-2 w-full rounded-md border px-3 py-2 text-sm" bind:value={v.notes}></textarea>
            </div>
            <div class="flex flex-col gap-2">
              <button class="rounded-full border px-3 py-1 text-sm" on:click={() => saveVenue(v)}>Save</button>
              <button class="rounded-full text-rose-600" on:click={() => removeVenue(v.id)}>Delete</button>
            </div>
          </div>
        </div>
      {/each}
    </div>
  {/if}
</div>
