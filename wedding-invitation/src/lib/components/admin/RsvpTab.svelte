<script lang="ts">
  import { onMount } from 'svelte';
  import { supabase, type GuestRecord, type RsvpRecord } from '$lib/supabase';

  let guests: GuestRecord[] = $state([]);
  let rsvps: RsvpRecord[] = $state([]);
  let loading = $state(false);
  let loadError = $state('');

  let summary = $derived.by(() => {
    const totalInvited = guests.reduce((sum, guest) => sum + 1 + guest.partners.length, 0);
    const attending = rsvps.filter((r) => r.attending);
    const declining = rsvps.filter((r) => !r.attending);
    const responded = rsvps.reduce((sum, rsvp) => {
      const guest = guests.find((item) => item.id === rsvp.guest_id);
      return sum + (guest ? 1 + guest.partners.length : 0);
    }, 0);
    const pending = totalInvited - responded;
    const totalAttendingGuests = attending.reduce((sum, r) => sum + (r.guest_count ?? 1), 0);
    const decliningCount = declining.reduce((sum, rsvp) => {
      const guest = guests.find((item) => item.id === rsvp.guest_id);
      return sum + (guest ? 1 + guest.partners.length : 0);
    }, 0);
    const withDietary = rsvps.filter((r) => r.dietary_requirements?.trim()).length;

    return {
      totalInvited,
      responded,
      pending: Math.max(pending, 0),
      attendingCount: totalAttendingGuests,
      decliningCount,
      withDietary
    };
  });

  onMount(loadAll);

  async function loadAll() {
    loading = true;
    loadError = '';

    const [guestsRes, rsvpsRes, attendanceRes] = await Promise.all([
      supabase.from('guests').select('*, partners:guest_partners(id, first_name, sort_order)'),
      supabase.from('rsvps').select('*, guests(first_name)').order('submitted_at', { ascending: false }),
      supabase.from('rsvp_partner_attendance').select('rsvp_id, partner:guest_partners(id, first_name)')
    ]);

    if (guestsRes.error) {
      loadError = guestsRes.error.message;
    } else {
      guests = (guestsRes.data as GuestRecord[]).map((guest) => ({
        ...guest,
        partners: [...(guest.partners ?? [])].sort((a, b) => a.sort_order - b.sort_order)
      }));
    }

    if (rsvpsRes.error) {
      loadError = rsvpsRes.error.message;
    } else if (attendanceRes.error) {
      loadError = attendanceRes.error.message;
    } else {
      const attendanceRows = attendanceRes.data as {
        rsvp_id: string;
        partner: { id: string; first_name: string }[];
      }[];
      const partnersByRsvp = new Map<string, { id: string; first_name: string }[]>();
      for (const row of attendanceRows) {
        partnersByRsvp.set(row.rsvp_id, [...(partnersByRsvp.get(row.rsvp_id) ?? []), ...row.partner]);
      }
      rsvps = (rsvpsRes.data as unknown as RsvpRecord[]).map((rsvp) => ({
        ...rsvp,
        attending_partners: partnersByRsvp.get(rsvp.id) ?? []
      }));
    }

    loading = false;
  }
</script>

<!-- RSVP summary -->
<div class="grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-6">
  <div class="rounded-2xl border border-slate-200 bg-white p-4 text-center shadow-sm">
    <p class="text-2xl font-semibold text-slate-900">{summary.totalInvited}</p>
    <p class="mt-1 text-xs tracking-wide text-slate-500 uppercase">People Invited</p>
  </div>
  <div class="rounded-2xl border border-slate-200 bg-white p-4 text-center shadow-sm">
    <p class="text-2xl font-semibold text-slate-900">{summary.responded}</p>
    <p class="mt-1 text-xs tracking-wide text-slate-500 uppercase">People Responded</p>
  </div>
  <div class="rounded-2xl border border-slate-200 bg-white p-4 text-center shadow-sm">
    <p class="text-2xl font-semibold text-amber-600">{summary.pending}</p>
    <p class="mt-1 text-xs tracking-wide text-slate-500 uppercase">People Pending</p>
  </div>
  <div class="rounded-2xl border border-slate-200 bg-white p-4 text-center shadow-sm">
    <p class="text-2xl font-semibold text-green-600">{summary.attendingCount}</p>
    <p class="mt-1 text-xs tracking-wide text-slate-500 uppercase">Attending People</p>
  </div>
  <div class="rounded-2xl border border-slate-200 bg-white p-4 text-center shadow-sm">
    <p class="text-2xl font-semibold text-rose-600">{summary.decliningCount}</p>
    <p class="mt-1 text-xs tracking-wide text-slate-500 uppercase">Declined People</p>
  </div>
  <div class="rounded-2xl border border-slate-200 bg-white p-4 text-center shadow-sm">
    <p class="text-2xl font-semibold text-slate-900">{summary.withDietary}</p>
    <p class="mt-1 text-xs tracking-wide text-slate-500 uppercase">Dietary Responses</p>
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
            <th class="px-4 py-3">Partners attending</th>
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
                {rsvp.guests ? rsvp.guests.first_name : 'Unknown guest'}
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
              <td class="px-4 py-3 text-slate-600">
                {rsvp.attending_partners?.map((partner) => partner.first_name).join(', ') || '—'}
              </td>
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
