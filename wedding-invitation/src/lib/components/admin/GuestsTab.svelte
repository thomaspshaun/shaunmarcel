<script lang="ts">
  import { onMount } from 'svelte';
  import { supabase, type GuestRecord } from '$lib/supabase';
  import { buildWhatsappLink } from '$lib/utils/whatsapp';
  import UnifiedChecklist from './UnifiedChecklist.svelte';

  let guests: GuestRecord[] = $state([]);
  let guestsLoading = $state(false);
  let guestsError = $state('');

  // Add-guest form state
  let newFirstName = $state('');
  let newLastName = $state('');
  let newWhatsapp = $state('');
  let newGuestType = $state('standard');
  let newPlusOneAllowed = $state(false);
  let addingGuest = $state(false);
  let addGuestError = $state('');

  onMount(loadGuests);

  async function loadGuests() {
    guestsLoading = true;
    guestsError = '';

    const { data, error } = await supabase
      .from('guests')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) {
      guestsError = error.message;
    } else {
      guests = data as GuestRecord[];
    }
    guestsLoading = false;
  }

  function generateGuestCode(): string {
    // 8-char alphanumeric, uppercase — easy to type, hard to guess.
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    let out = '';
    for (let i = 0; i < 8; i++) {
      out += chars[Math.floor(Math.random() * chars.length)];
    }
    return out;
  }

  async function handleAddGuest(e: Event) {
    e.preventDefault();
    if (!newFirstName.trim() || !newLastName.trim()) return;

    addingGuest = true;
    addGuestError = '';

    const { error } = await supabase.from('guests').insert({
      first_name: newFirstName.trim(),
      last_name: newLastName.trim(),
      whatsapp_number: newWhatsapp.trim() || null,
      guest_type: newGuestType,
      plus_one_allowed: newPlusOneAllowed,
      guest_code: generateGuestCode()
    });

    if (error) {
      addGuestError = error.message;
    } else {
      newFirstName = '';
      newLastName = '';
      newWhatsapp = '';
      newGuestType = 'standard';
      newPlusOneAllowed = false;
      await loadGuests();
    }
    addingGuest = false;
  }

  async function markInviteSent(guest: GuestRecord) {
    await supabase.from('guests').update({ invite_sent_at: new Date().toISOString() }).eq('id', guest.id);
    await loadGuests();
  }

  async function updateGuestField(guest: GuestRecord, patch: Partial<GuestRecord>) {
    Object.assign(guest, patch);
    guests = [...guests];
    await supabase.from('guests').update(patch).eq('id', guest.id);
  }

  function rsvpBadgeClass(status: string): string {
    switch (status) {
      case 'attending':
        return 'bg-green-100 text-green-700';
      case 'declining':
        return 'bg-red-100 text-red-700';
      default:
        return 'bg-slate-100 text-slate-600';
    }
  }
</script>

<!-- Add guest -->
<div class="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
  <h2 class="text-lg font-medium text-slate-900">Add a Guest</h2>
  <form onsubmit={handleAddGuest} class="mt-4 grid gap-4 sm:grid-cols-2 lg:grid-cols-5">
    <input
      type="text"
      placeholder="First name"
      bind:value={newFirstName}
      required
      class="rounded-xl border border-slate-300 px-4 py-2.5 text-sm text-slate-900 focus:border-rose-400 focus:ring-2 focus:ring-rose-200 focus:outline-none"
    />
    <input
      type="text"
      placeholder="Last name"
      bind:value={newLastName}
      required
      class="rounded-xl border border-slate-300 px-4 py-2.5 text-sm text-slate-900 focus:border-rose-400 focus:ring-2 focus:ring-rose-200 focus:outline-none"
    />
    <input
      type="text"
      placeholder="WhatsApp number (e.g. 0821234567)"
      bind:value={newWhatsapp}
      class="rounded-xl border border-slate-300 px-4 py-2.5 text-sm text-slate-900 focus:border-rose-400 focus:ring-2 focus:ring-rose-200 focus:outline-none"
    />
    <select
      bind:value={newGuestType}
      class="rounded-xl border border-slate-300 px-4 py-2.5 text-sm text-slate-900 focus:border-rose-400 focus:ring-2 focus:ring-rose-200 focus:outline-none"
    >
      <option value="standard">Standard</option>
      <option value="vip">VIP</option>
      <option value="family">Family</option>
      <option value="wedding_party">Wedding Party</option>
    </select>
    <label class="flex items-center gap-2 text-sm text-slate-700">
      <input type="checkbox" bind:checked={newPlusOneAllowed} class="h-4 w-4 rounded border-slate-300" />
      Plus-one allowed
    </label>

    <div class="sm:col-span-2 lg:col-span-5">
      {#if addGuestError}
        <p class="mb-2 text-sm text-red-600">{addGuestError}</p>
      {/if}
      <button
        type="submit"
        disabled={addingGuest}
        class="rounded-full bg-rose-500 px-6 py-2.5 text-sm font-medium text-white shadow transition hover:bg-rose-600 disabled:cursor-not-allowed disabled:opacity-60"
      >
        {addingGuest ? 'Adding...' : 'Add Guest'}
      </button>
    </div>
  </form>
</div>

<!-- Guest list -->
<div class="mt-8">
  <div class="flex items-center justify-between">
    <h2 class="text-lg font-medium text-slate-900">Guests ({guests.length})</h2>
    <button type="button" onclick={loadGuests} class="text-sm font-medium text-rose-600 hover:underline">
      Refresh
    </button>
  </div>

  {#if guestsLoading}
    <p class="mt-4 text-slate-500">Loading guests...</p>
  {:else if guestsError}
    <p class="mt-4 text-red-600">{guestsError}</p>
  {:else if guests.length === 0}
    <p class="mt-4 text-slate-500">No guests yet — add your first one above.</p>
  {:else}
    <div class="mt-4 overflow-x-auto rounded-2xl border border-slate-200 bg-white shadow-sm">
      <table class="min-w-full divide-y divide-slate-200 text-sm">
        <thead class="bg-slate-50 text-left text-xs font-semibold tracking-wide text-slate-500 uppercase">
          <tr>
            <th class="px-4 py-3">Name</th>
            <th class="px-4 py-3">Code</th>
            <th class="px-4 py-3">Type</th>
            <th class="px-4 py-3">Wedding RSVP</th>
            <th class="px-4 py-3">Invite Sent</th>
            <th class="px-4 py-3">WhatsApp</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-slate-100">
          {#each guests as guest (guest.id)}
            <tr>
              <td class="px-4 py-3 font-medium text-slate-900">{guest.first_name} {guest.last_name}</td>
              <td class="px-4 py-3 font-mono text-xs text-slate-600">{guest.guest_code}</td>
              <td class="px-4 py-3 text-slate-600 capitalize">{guest.guest_type.replace('_', ' ')}</td>
              <td class="px-4 py-3">
                <span class="rounded-full px-2.5 py-1 text-xs font-medium {rsvpBadgeClass(guest.rsvp_status ?? 'pending')}">
                  {guest.rsvp_status}
                </span>
              </td>
              <td class="px-4 py-3 text-xs text-slate-500">
                {guest.invite_sent_at ? new Date(guest.invite_sent_at).toLocaleDateString() : '—'}
              </td>
              <td class="px-4 py-3">
                {#if guest.whatsapp_number}
                  <a
                    href={buildWhatsappLink(guest.whatsapp_number, guest.first_name, guest.guest_code)}
                    target="_blank"
                    rel="noopener noreferrer"
                    onclick={() => markInviteSent(guest)}
                    class="inline-flex items-center gap-1.5 rounded-full bg-green-500 px-3 py-1.5 text-xs font-medium text-white transition hover:bg-green-600"
                  >
                    Send WhatsApp
                  </a>
                {:else}
                  <span class="text-xs text-slate-400">No number</span>
                {/if}
              </td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  {/if}
</div>

<!-- Accommodation + multi-event attendance tracker -->
<div class="mt-10">
  <h2 class="text-lg font-medium text-slate-900">Accommodation &amp; Weekend Attendance</h2>
  <p class="mt-1 text-sm text-slate-500">
    Track where each guest is staying, and their attendance for the Friday welcome supper and Sunday
    farewell breakfast (separate from the main Saturday wedding RSVP above).
  </p>

  {#if guests.length === 0}
    <p class="mt-4 text-slate-500">No guests yet.</p>
  {:else}
    <div class="mt-4 overflow-x-auto rounded-2xl border border-slate-200 bg-white shadow-sm">
      <table class="min-w-full divide-y divide-slate-200 text-sm">
        <thead class="bg-slate-50 text-left text-xs font-semibold tracking-wide text-slate-500 uppercase">
          <tr>
            <th class="px-4 py-3">Name</th>
            <th class="px-4 py-3">Accommodation</th>
            <th class="px-4 py-3">Name / Notes</th>
            <th class="px-4 py-3">Nights</th>
            <th class="px-4 py-3">Confirmed</th>
            <th class="px-4 py-3">Friday Supper</th>
            <th class="px-4 py-3">Sunday Breakfast</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-slate-100">
          {#each guests as guest (guest.id)}
            <tr>
              <td class="px-4 py-3 font-medium whitespace-nowrap text-slate-900">
                {guest.first_name} {guest.last_name}
              </td>
              <td class="px-4 py-3">
                <select
                  value={guest.accommodation_type ?? ''}
                  onchange={(e) =>
                    updateGuestField(guest, {
                      accommodation_type: (e.currentTarget.value || null) as GuestRecord['accommodation_type']
                    })}
                  class="rounded-lg border border-slate-300 px-2 py-1 text-xs focus:border-rose-400 focus:outline-none"
                >
                  <option value="">—</option>
                  <option value="estate">Estate</option>
                  <option value="guesthouse">Guesthouse</option>
                  <option value="own">Own Arrangement</option>
                </select>
              </td>
              <td class="px-4 py-3">
                <input
                  type="text"
                  value={guest.accommodation_name ?? ''}
                  onblur={(e) => updateGuestField(guest, { accommodation_name: e.currentTarget.value || null })}
                  class="w-36 rounded-lg border border-slate-300 px-2 py-1 text-xs focus:border-rose-400 focus:outline-none"
                />
              </td>
              <td class="px-4 py-3">
                <input
                  type="number"
                  min="0"
                  value={guest.room_nights ?? ''}
                  onblur={(e) =>
                    updateGuestField(guest, {
                      room_nights: e.currentTarget.value ? Number(e.currentTarget.value) : null
                    })}
                  class="w-16 rounded-lg border border-slate-300 px-2 py-1 text-xs focus:border-rose-400 focus:outline-none"
                />
              </td>
              <td class="px-4 py-3">
                <input
                  type="checkbox"
                  checked={guest.accommodation_confirmed}
                  onchange={(e) => updateGuestField(guest, { accommodation_confirmed: e.currentTarget.checked })}
                  class="h-4 w-4 rounded border-slate-300"
                />
              </td>
              <td class="px-4 py-3">
                <select
                  value={guest.friday_supper_status ?? 'pending'}
                  onchange={(e) =>
                    updateGuestField(guest, {
                      friday_supper_status: e.currentTarget.value as GuestRecord['friday_supper_status']
                    })}
                  class="rounded-lg border border-slate-300 px-2 py-1 text-xs focus:border-rose-400 focus:outline-none"
                >
                  <option value="pending">Pending</option>
                  <option value="attending">Attending</option>
                  <option value="declining">Declining</option>
                </select>
              </td>
              <td class="px-4 py-3">
                <select
                  value={guest.sunday_breakfast_status ?? 'pending'}
                  onchange={(e) =>
                    updateGuestField(guest, {
                      sunday_breakfast_status: e.currentTarget.value as GuestRecord['sunday_breakfast_status']
                    })}
                  class="rounded-lg border border-slate-300 px-2 py-1 text-xs focus:border-rose-400 focus:outline-none"
                >
                  <option value="pending">Pending</option>
                  <option value="attending">Attending</option>
                  <option value="declining">Declining</option>
                </select>
              </td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  {/if}
</div>

<!-- Guest Communications Checklist -->
<div class="mt-10">
 <UnifiedChecklist
   slug="guest_communications"
   name="Guest Communications Checklist"
   category="guests"
   subtitle="Track invitations, confirmations, and follow-ups"
   placeholder="Add a task..."
 />
</div>
