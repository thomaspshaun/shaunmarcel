<script lang="ts">
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabase';
  import type { Session } from '@supabase/supabase-js';

  import OverviewTab from '$lib/components/admin/OverviewTab.svelte';
  import GuestsTab from '$lib/components/admin/GuestsTab.svelte';
  import RsvpTab from '$lib/components/admin/RsvpTab.svelte';
  import ScheduleTab from '$lib/components/admin/ScheduleTab.svelte';
  import ReceptionTab from '$lib/components/admin/ReceptionTab.svelte';
  import VendorsTab from '$lib/components/admin/VendorsTab.svelte';
    import VenueTab from '$lib/components/admin/VenueTab.svelte';
    import EmergencyTab from '$lib/components/admin/EmergencyTab.svelte';
    import MediaTab from '$lib/components/admin/MediaTab.svelte';
    import ChecklistsTab from '$lib/components/admin/ChecklistsTab.svelte';

  let session: Session | null = $state(null);
  let authLoading = $state(true);

  let email = $state('');
  let password = $state('');
  let authError = $state('');
  let signingIn = $state(false);

  const tabs = [
    { id: 'overview', label: 'Overview' },
    { id: 'guests', label: 'Guests' },
    { id: 'rsvps', label: 'RSVPs' },
    { id: 'schedule', label: 'Weekend Schedule' },
    { id: 'reception', label: 'Reception & Seating' },
    { id: 'vendors', label: 'Vendors' },
    { id: 'venue', label: 'Venue' },
    { id: 'emergency', label: 'Emergency & Quick Ref' },
    { id: 'media', label: 'Media' },
    { id: 'checklists', label: 'Checklists' }
  ] as const;

  let activeTab: (typeof tabs)[number]['id'] = $state('overview');

  onMount(() => {
    supabase.auth.getSession().then(({ data }) => {
      session = data.session;
      authLoading = false;
    });

    const { data: sub } = supabase.auth.onAuthStateChange((_event, newSession) => {
      session = newSession;
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
  }
</script>

<svelte:head>
  <title>Wedding Planner Admin</title>
  <meta name="robots" content="noindex, nofollow" />
</svelte:head>

<div class="mx-auto max-w-6xl px-6 py-16">
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
      <h1 class="text-2xl font-medium text-slate-900">Wedding Planner</h1>
      <button
        type="button"
        onclick={handleSignOut}
        class="rounded-full border border-slate-300 px-5 py-2 text-sm font-medium text-slate-700 transition hover:border-slate-400 hover:bg-slate-50"
      >
        Sign Out
      </button>
    </div>

    <div class="mt-6 flex flex-wrap gap-2 border-b border-slate-200 pb-3">
      {#each tabs as tab (tab.id)}
        <button
          type="button"
          onclick={() => (activeTab = tab.id)}
          class="rounded-full px-4 py-1.5 text-sm font-medium transition {activeTab === tab.id
            ? 'bg-rose-500 text-white'
            : 'bg-slate-100 text-slate-600 hover:bg-slate-200'}"
        >
          {tab.label}
        </button>
      {/each}
    </div>

    <div class="mt-8">
      {#if activeTab === 'overview'}
        <OverviewTab />
      {:else if activeTab === 'guests'}
        <GuestsTab />
      {:else if activeTab === 'rsvps'}
        <RsvpTab />
      {:else if activeTab === 'schedule'}
        <ScheduleTab />
      {:else if activeTab === 'reception'}
        <ReceptionTab />
      {:else if activeTab === 'vendors'}
        <VendorsTab />
      {:else if activeTab === 'venue'}
        <VenueTab />
      {:else if activeTab === 'emergency'}
        <EmergencyTab />
      {:else if activeTab === 'media'}
        <MediaTab />
      {:else if activeTab === 'checklists'}
        <ChecklistsTab />
      {/if}
    </div>
  {/if}
</div>
