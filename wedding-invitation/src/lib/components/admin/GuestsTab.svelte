<script lang="ts">
  import { onMount } from 'svelte';
  import { supabase, type GuestRecord } from '$lib/supabase';
  import { buildWhatsappLink } from '$lib/utils/whatsapp';

  let guests: GuestRecord[] = $state([]);
  let loading = $state(false);
  let error = $state('');
  let firstName = $state('');
  let partnerNames = $state('');
  let whatsapp = $state('');
  let adding = $state(false);

  onMount(loadGuests);

  async function loadGuests() {
    loading = true;
    error = '';
    const { data, error: loadError } = await supabase
      .from('guests')
      .select('*, partners:guest_partners(id, first_name, sort_order)')
      .order('created_at', { ascending: false });
    if (loadError) {
      error = loadError.message;
    } else {
      guests = (data as GuestRecord[]).map((guest) => ({
        ...guest,
        partners: [...(guest.partners ?? [])].sort((a, b) => a.sort_order - b.sort_order)
      }));
    }
    loading = false;
  }

  function generateGuestCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return Array.from({ length: 8 }, () => chars[Math.floor(Math.random() * chars.length)]).join('');
  }

  async function addGuest(event: SubmitEvent) {
    event.preventDefault();
    const names = partnerNames.split(',').map((name) => name.trim()).filter(Boolean);
    if (names.length > 3) {
      error = 'A guest can have up to 3 invited partners.';
      return;
    }
    adding = true;
    error = '';
    const { data, error: insertError } = await supabase
      .from('guests')
      .insert({
        first_name: firstName.trim(),
        whatsapp_number: whatsapp.trim() || null,
        guest_code: generateGuestCode()
      })
      .select('id')
      .single();
    if (insertError) {
      error = insertError.message;
    } else {
      const { error: partnersError } = names.length
        ? await supabase.from('guest_partners').insert(
            names.map((name, index) => ({
              guest_id: data.id,
              first_name: name,
              sort_order: index + 1
            }))
          )
        : { error: null };
      if (partnersError) error = `Guest added, but partner names could not be saved: ${partnersError.message}`;
      firstName = '';
      partnerNames = '';
      whatsapp = '';
      await loadGuests();
    }
    adding = false;
  }

  async function updatePartners(guest: GuestRecord, value: string) {
    const names = value.split(',').map((name) => name.trim()).filter(Boolean);
    if (names.length > 3) {
      error = 'A guest can have up to 3 invited partners.';
      return;
    }
    error = '';
    if (names.length) {
      const { error: saveError } = await supabase.from('guest_partners').upsert(
        names.map((name, index) => ({
          guest_id: guest.id,
          first_name: name,
          sort_order: index + 1
        })),
        { onConflict: 'guest_id,sort_order' }
      );
      if (saveError) {
        error = saveError.message;
        return;
      }
    }
    const { error: deleteError } = await supabase
      .from('guest_partners')
      .delete()
      .eq('guest_id', guest.id)
      .gt('sort_order', names.length);
    if (deleteError) {
      error = deleteError.message;
      return;
    }
    await loadGuests();
  }

  async function markInviteSent(guest: GuestRecord) {
    const { error: updateError } = await supabase
      .from('guests')
      .update({ invite_sent_at: new Date().toISOString() })
      .eq('id', guest.id);
    if (updateError) error = updateError.message;
    await loadGuests();
  }
</script>

<section class="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
  <h2 class="text-lg font-medium text-slate-900">Add a Guest</h2>
  <form onsubmit={addGuest} class="mt-4 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
    <input bind:value={firstName} placeholder="Guest first name" required class="rounded-xl border border-slate-300 px-4 py-2.5 text-sm" />
    <input bind:value={partnerNames} placeholder="Partner first names (comma-separated, max 3)" class="rounded-xl border border-slate-300 px-4 py-2.5 text-sm" />
    <input bind:value={whatsapp} placeholder="WhatsApp number" class="rounded-xl border border-slate-300 px-4 py-2.5 text-sm" />
    <button type="submit" disabled={adding} class="rounded-full bg-rose-500 px-6 py-2.5 text-sm font-medium text-white disabled:opacity-60">
      {adding ? 'Adding...' : 'Add Guest'}
    </button>
  </form>

  <div class="mt-8 flex items-center justify-between">
    <h2 class="text-lg font-medium text-slate-900">Invitations ({guests.length})</h2>
    <button type="button" onclick={loadGuests} class="text-sm font-medium text-rose-600 hover:underline">Refresh</button>
  </div>
  {#if error}<p class="mt-3 text-sm text-red-600" role="alert">{error}</p>{/if}
  {#if loading}
    <p class="mt-4 text-slate-500">Loading guests...</p>
  {:else}
    <div class="mt-4 overflow-x-auto">
      <table class="min-w-full divide-y divide-slate-200 text-sm">
        <thead class="bg-slate-50 text-left text-xs font-semibold tracking-wide text-slate-500 uppercase">
          <tr>
            <th class="px-4 py-3">Guest first name</th>
            <th class="px-4 py-3">Invited partners</th>
            <th class="px-4 py-3">People invited</th>
            <th class="px-4 py-3">Invite code</th>
            <th class="px-4 py-3">WhatsApp</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-slate-100">
          {#each guests as guest (guest.id)}
            <tr>
              <td class="px-4 py-3 font-medium text-slate-900">{guest.first_name}</td>
              <td class="px-4 py-3">
                <input
                  aria-label={`Partner first names for ${guest.first_name}`}
                  value={guest.partners.map((partner) => partner.first_name).join(', ')}
                  placeholder="None"
                  onblur={(event) => updatePartners(guest, event.currentTarget.value)}
                  class="w-56 rounded-lg border border-slate-300 px-2 py-1 text-xs"
                />
              </td>
              <td class="px-4 py-3">{1 + guest.partners.length}</td>
              <td class="px-4 py-3 font-mono text-xs">{guest.guest_code}</td>
              <td class="px-4 py-3">
                {#if guest.whatsapp_number}
                  <a
                    href={buildWhatsappLink(guest.whatsapp_number, guest.first_name, guest.guest_code)}
                    target="_blank"
                    rel="noopener noreferrer"
                    onclick={() => markInviteSent(guest)}
                    class="text-green-700 hover:underline"
                  >Send WhatsApp</a>
                {:else}
                  <span class="text-slate-400">No number</span>
                {/if}
              </td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  {/if}
</section>
