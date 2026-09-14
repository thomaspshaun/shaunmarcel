<script lang="ts">
  import { onMount } from 'svelte';
  import { supabase, type GuestRecord } from '$lib/supabase';
  import { buildWhatsappLink } from '$lib/utils/whatsapp';
  import type { Session } from '@supabase/supabase-js';

  let session: Session | null = $state(null);
  let authLoading = $state(true);

  let email = $state('');
  let password = $state('');
  let authError = $state('');
  let signingIn = $state(false);

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

  onMount(() => {
    supabase.auth.getSession().then(({ data }) => {
      session = data.session;
      authLoading = false;
      if (session) loadGuests();
    });

    const { data: sub } = supabase.auth.onAuthStateChange((_event, newSession) => {
      session = newSession;
      if (newSession) loadGuests();
    });

    return () => sub.subscription.unsubscribe();
  });

  async function handleSignIn(e: Event) {
    e.preventDefault();
    signingIn = true;
    authError = '';

    const { error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) {
      authError = error.message;
    }
    signingIn = false;
  }

  async function handleSignOut() {
    await supabase.auth.signOut();
    guests = [];
  }

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
    await supabase
      .from('guests')
      .update({ invite_sent_at: new Date().toISOString() })
      .eq('id', guest.id);
    await loadGuests();
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

<svelte:head>
  <title>Guest Admin</title>
  <meta name="robots" content="noindex, nofollow" />
</svelte:head>

<div class="mx-auto max-w-5xl px-6 py-16">
  {#if authLoading}
    <p class="text-center text-slate-500">Loading...</p>
  {:else if !session}
    <div class="mx-auto max-w-sm rounded-3xl border border-slate-200 bg-white p-8 shadow-sm">
      <h1 class="text-xl font-medium text-slate-900">Admin Sign In</h1>
      <form onsubmit={handleSignIn} class="mt-6 space-y-4">
        <div>
          <label class="block text-sm font-medium text-slate-700" for="email">Email</label>
          <input
            id="email"
            type="email"
            bind:value={email}
            required
            class="mt-2 w-full rounded-xl border border-slate-300 px-4 py-3 text-base text-slate-900 focus:border-rose-400 focus:ring-2 focus:ring-rose-200 focus:outline-none"
          />
        </div>
        <div>
          <label class="block text-sm font-medium text-slate-700" for="password">Password</label>
          <input
            id="password"
            type="password"
            bind:value={password}
            required
            class="mt-2 w-full rounded-xl border border-slate-300 px-4 py-3 text-base text-slate-900 focus:border-rose-400 focus:ring-2 focus:ring-rose-200 focus:outline-none"
          />
        </div>
        {#if authError}
          <p class="text-sm text-red-600">{authError}</p>
        {/if}
        <button
          type="submit"
          disabled={signingIn}
          class="w-full rounded-full bg-rose-500 px-6 py-3 text-sm font-medium text-white shadow-lg shadow-rose-200 transition hover:bg-rose-600 disabled:cursor-not-allowed disabled:opacity-60"
        >
          {signingIn ? 'Signing in...' : 'Sign In'}
        </button>
      </form>
    </div>
  {:else}
    <div class="flex flex-wrap items-center justify-between gap-4">
      <h1 class="text-2xl font-medium text-slate-900">Guest Management</h1>
      <button
        type="button"
        onclick={handleSignOut}
        class="rounded-full border border-slate-300 px-5 py-2 text-sm font-medium text-slate-700 transition hover:border-slate-400 hover:bg-slate-50"
      >
        Sign Out
      </button>
    </div>

    <!-- Add guest -->
    <div class="mt-8 rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
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
        <button
          type="button"
          onclick={loadGuests}
          class="text-sm font-medium text-rose-600 hover:underline"
        >
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
                <th class="px-4 py-3">RSVP</th>
                <th class="px-4 py-3">Invite Sent</th>
                <th class="px-4 py-3">WhatsApp</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
              {#each guests as guest (guest.id)}
                <tr>
                  <td class="px-4 py-3 font-medium text-slate-900">
                    {guest.first_name} {guest.last_name}
                  </td>
                  <td class="px-4 py-3 font-mono text-xs text-slate-600">{guest.guest_code}</td>
                  <td class="px-4 py-3 text-slate-600 capitalize">{guest.guest_type.replace('_', ' ')}</td>
                  <td class="px-4 py-3">
                    <span class="rounded-full px-2.5 py-1 text-xs font-medium {rsvpBadgeClass(guest.rsvp_status)}">
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
  {/if}
</div>
