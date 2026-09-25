<script lang="ts">
  import { onMount } from 'svelte';
  import { supabase, type GuestRecord, type RsvpRecord } from '$lib/supabase';

  let guests: GuestRecord[] = $state([]);
  let rsvps: RsvpRecord[] = $state([]);
  let loading = $state(false);
  let loadError = $state('');

  let summary = $derived.by(() => {
    const totalInvited = guests.length;
    const attending = rsvps.filter((r) => r.attending);
    const declining = rsvps.filter((r) => !r.attending);
    const responded = rsvps.length;
    const pending = totalInvited - responded;
    const totalAttendingGuests = attending.reduce((sum, r) => sum + (r.guest_count ?? 1), 0);
    const withDietary = rsvps.filter((r) => r.dietary_requirements?.trim()).length;

    return {
      totalInvited,
      responded,
      pending: Math.max(pending, 0),
      attendingCount: attending.length,
      decliningCount: declining.length,
      totalAttendingGuests,
      withDietary
    };
  });

  onMount(loadAll);

  async function loadAll() {
    loading = true;
    loadError = '';

    const [guestsRes, rsvpsRes] = await Promise.all([
      supabase.from('guests').select('*'),
      supabase.from('rsvps').select('*, guests(first_name, last_name, guest_type)').order('submitted_at', { ascending: false })
    ]);

    if (guestsRes.error) {
      loadError = guestsRes.error.message;
    } else {
      guests = guestsRes.data as GuestRecord[];
    }

    if (rsvpsRes.error) {
      loadError = rsvpsRes.error.message;
    } else {
      rsvps = rsvpsRes.data as unknown as RsvpRecord[];
    }

    loading = false;
  }
</script>

<!-- RSVP summary -->
<div class="grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-6">
  <div class="rounded-2xl border border-slate-200 bg-white p-4 text-center shadow-sm">
    <p class="text-2xl font-semibold text-slate-900">{summary.totalInvited}</p>
    <p class="mt-1 text-xs tracking-wide text-slate-500 uppercase">Invited</p>
  </div>
  <div class="rounded-2xl border border-slate-200 bg-white p-4 text-center shadow-sm">
    <p class="text-2xl font-semibold text-slate-900">{summary.responded}</p>
    <p class="mt-1 text-xs tracking-wide text-slate-500 uppercase">Responded</p>
  </div>
  <div class="rounded-2xl border border-slate-200 bg-white p-4 text-center shadow-sm">
    <p class="text-2xl font-semibold text-amber-600">{summary.pending}</p>
    <p class="mt-1 text-xs tracking-wide text-slate-500 uppercase">Pending</p>
  </div>
  <div class="rounded-2xl border border-slate-200 bg-white p-4 text-center shadow-sm">
    <p class="text-2xl font-semibold text-green-600">{summary.attendingCount}</p>
    <p class="mt-1 text-xs tracking-wide text-slate-500 uppercase">Attending RSVPs</p>
  </div>
  <div class="rounded-2xl border border-slate-200 bg-white p-4 text-center shadow-sm">
    <p class="text-2xl font-semibold text-rose-600">{summary.totalAttendingGuests}</p>
    <p class="mt-1 text-xs tracking-wide text-slate-500 uppercase">Total Attending</p>
  </div>
  <div class="rounded-2xl border border-slate-200 bg-white p-4 text-center shadow-sm">
    <p class="text-2xl font-semibold text-slate-900">{summary.withDietary}</p>
    <p class="mt-1 text-xs tracking-wide text-slate-500 uppercase">Dietary Needs</p>
  </div>
</div>

<!-- RSVP responses -->
<div class="mt-8">
  <div class="flex items-center justify-between">
    <h2 class="text-lg font-medium text-slate-900">RSVP Responses ({rsvps.length})</h2>
    <button type="button" onclick={loadAll} class="text-sm font-medium text-rose-600 hover:underline">
      Refresh
    </button>
  </div>

  {#if loading}
    <p class="mt-4 text-slate-500">Loading responses...</p>
  {:else if loadError}
    <p class="mt-4 text-red-600">{loadError}</p>
  {:else if rsvps.length === 0}
    <p class="mt-4 text-slate-500">No RSVPs yet.</p>
  {:else}
    <div class="mt-4 overflow-x-auto rounded-2xl border border-slate-200 bg-white shadow-sm">
      <table class="min-w-full divide-y divide-slate-200 text-sm">
        <thead class="bg-slate-50 text-left text-xs font-semibold tracking-wide text-slate-500 uppercase">
          <tr>
            <th class="px-4 py-3">Name</th>
            <th class="px-4 py-3">Response</th>
            <th class="px-4 py-3">Guests</th>
            <th class="px-4 py-3">Plus One</th>
            <th class="px-4 py-3">Dietary</th>
            <th class="px-4 py-3">Song Request</th>
            <th class="px-4 py-3">Notes</th>
            <th class="px-4 py-3">Submitted</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-slate-100">
          {#each rsvps as rsvp (rsvp.id)}
            <tr>
              <td class="px-4 py-3 font-medium whitespace-nowrap text-slate-900">
                {rsvp.guests ? `${rsvp.guests.first_name} ${rsvp.guests.last_name}` : 'Unknown guest'}
              </td>
              <td class="px-4 py-3">
                <span
                  class="rounded-full px-2.5 py-1 text-xs font-medium {rsvp.attending
                    ? 'bg-green-100 text-green-700'
                    : 'bg-red-100 text-red-700'}"
                >
                  {rsvp.attending ? 'Attending' : 'Declined'}
                </span>
              </td>
              <td class="px-4 py-3 text-slate-600">{rsvp.attending ? rsvp.guest_count : '—'}</td>
              <td class="px-4 py-3 text-slate-600">{rsvp.plus_one_name || '—'}</td>
              <td class="px-4 py-3 max-w-[14rem] text-slate-600">{rsvp.dietary_requirements || '—'}</td>
              <td class="px-4 py-3 max-w-[12rem] text-slate-600">{rsvp.song_request || '—'}</td>
              <td class="px-4 py-3 max-w-[14rem] text-slate-600">{rsvp.notes || '—'}</td>
              <td class="px-4 py-3 text-xs whitespace-nowrap text-slate-500">
                {new Date(rsvp.submitted_at).toLocaleString()}
              </td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  {/if}
</div>
