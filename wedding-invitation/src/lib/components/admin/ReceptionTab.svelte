<script lang="ts">
  import { onMount } from 'svelte';
  import ChecklistSection from './ChecklistSection.svelte';
  import {
    fetchSeatingTables,
    addSeatingTable,
    deleteSeatingTable,
    fetchSeatingSeats,
    addSeatingSeat,
    updateSeatingSeat,
    deleteSeatingSeat,
    type SeatingTable,
    type SeatingSeat
  } from '$lib/planner';

  let tables: SeatingTable[] = $state([]);
  let seatsByTable: Record<string, SeatingSeat[]> = $state({});
  let loading = $state(true);
  let loadError = $state('');
  let newTableName = $state('');

  onMount(load);

  async function load() {
    loading = true;
    loadError = '';
    try {
      tables = await fetchSeatingTables();
      const entries = await Promise.all(
        tables.map(async (t) => [t.id, await fetchSeatingSeats(t.id)] as const)
      );
      seatsByTable = Object.fromEntries(entries);
    } catch (err) {
      loadError = err instanceof Error ? err.message : 'Could not load seating plan.';
    } finally {
      loading = false;
    }
  }

  async function handleAddTable(e: Event) {
    e.preventDefault();
    if (!newTableName.trim()) return;
    const table = await addSeatingTable(newTableName.trim(), tables.length);
    tables = [...tables, table];
    seatsByTable = { ...seatsByTable, [table.id]: [] };
    newTableName = '';
  }

  async function handleDeleteTable(table: SeatingTable) {
    if (!confirm(`Remove table "${table.name}" and all its seats?`)) return;
    tables = tables.filter((t) => t.id !== table.id);
    const { [table.id]: _removed, ...rest } = seatsByTable;
    seatsByTable = rest;
    await deleteSeatingTable(table.id);
  }

  async function handleAddSeat(table: SeatingTable) {
    const seats = seatsByTable[table.id] ?? [];
    const seat = await addSeatingSeat(table.id, `Seat ${seats.length + 1}`, '', seats.length);
    seatsByTable = { ...seatsByTable, [table.id]: [...seats, seat] };
  }

  async function handleSeatChange(seat: SeatingSeat, patch: Partial<SeatingSeat>) {
    Object.assign(seat, patch);
    seatsByTable = { ...seatsByTable };
    await updateSeatingSeat(seat.id, patch);
  }

  async function handleDeleteSeat(table: SeatingTable, seat: SeatingSeat) {
    seatsByTable = { ...seatsByTable, [table.id]: (seatsByTable[table.id] ?? []).filter((s) => s.id !== seat.id) };
    await deleteSeatingSeat(seat.id);
  }
</script>

<div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
  <div class="flex items-center justify-between">
    <h2 class="text-lg font-medium text-slate-900">Seating Plan</h2>
  </div>

  <form onsubmit={handleAddTable} class="mt-4 flex gap-2">
    <input
      type="text"
      placeholder="Table name (e.g. Head Table, Table 1)"
      bind:value={newTableName}
      class="flex-1 rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-rose-400 focus:ring-1 focus:ring-rose-400 focus:outline-none"
    />
    <button type="submit" class="rounded-full bg-rose-500 px-5 py-2 text-sm font-medium text-white hover:bg-rose-600">
      Add Table
    </button>
  </form>

  {#if loading}
    <p class="mt-4 text-slate-500">Loading seating plan...</p>
  {:else if loadError}
    <p class="mt-4 text-red-600">{loadError}</p>
  {:else if tables.length === 0}
    <p class="mt-4 text-slate-500">No tables yet — add your head table or first guest table above.</p>
  {:else}
    <div class="mt-6 grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
      {#each tables as table (table.id)}
        <div class="rounded-xl border border-slate-200 p-4">
          <div class="flex items-center justify-between">
            <h3 class="font-medium text-slate-900">{table.name}</h3>
            <button type="button" onclick={() => handleDeleteTable(table)} class="text-xs text-slate-400 hover:text-red-500">
              Remove
            </button>
          </div>
          <ul class="mt-3 space-y-2">
            {#each seatsByTable[table.id] ?? [] as seat (seat.id)}
              <li class="flex items-center gap-2">
                <input
                  type="text"
                  value={seat.seat_label ?? ''}
                  onblur={(e) => handleSeatChange(seat, { seat_label: e.currentTarget.value })}
                  placeholder="Seat"
                  class="w-20 rounded-lg border border-slate-300 px-2 py-1 text-xs focus:border-rose-400 focus:outline-none"
                />
                <input
                  type="text"
                  value={seat.guest_name ?? ''}
                  onblur={(e) => handleSeatChange(seat, { guest_name: e.currentTarget.value })}
                  placeholder="Guest name"
                  class="flex-1 rounded-lg border border-slate-300 px-2 py-1 text-xs focus:border-rose-400 focus:outline-none"
                />
                <button
                  type="button"
                  onclick={() => handleDeleteSeat(table, seat)}
                  class="text-xs text-slate-300 hover:text-red-500"
                >
                  &times;
                </button>
              </li>
            {/each}
          </ul>
          <button
            type="button"
            onclick={() => handleAddSeat(table)}
            class="mt-3 text-xs font-medium text-rose-600 hover:underline"
          >
            + Add Seat
          </button>
        </div>
      {/each}
    </div>
  {/if}
</div>

<div class="mt-8">
  <h2 class="text-lg font-medium text-slate-900">Reception Checklist</h2>
  <div class="mt-3">
    <ChecklistSection section="reception_checklist" />
  </div>
</div>
