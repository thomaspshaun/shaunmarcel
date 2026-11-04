<script lang="ts">
  import { onMount } from 'svelte';
  import Hero from '$lib/components/Hero.svelte';
  import Welcome from '$lib/components/Welcome.svelte';
  import Timeline from '$lib/components/Timeline.svelte';
  import VenueMap from '$lib/components/VenueMap.svelte';
  import Accommodations from '$lib/components/Accommodations.svelte';
  import RsvpForm from '$lib/components/RsvpForm.svelte';
  import PhotoGallery from '$lib/components/PhotoGallery.svelte';
  import Guestbook from '$lib/components/Guestbook.svelte';
  import GuestLookupModal from '$lib/components/GuestLookupModal.svelte';
  import Registry from '$lib/components/Registry.svelte';
  import SaveTheDateSplash from '$lib/components/SaveTheDateSplash.svelte';
  import { site } from '$lib/site-config';
  import { guestStore } from '$lib/guestStore';
  import { findGuestByCode } from '$lib/supabase';

  let hasVerifiedInvitation = $state(false);

  onMount(async () => {
    const code = new URLSearchParams(window.location.search).get('code')?.trim().toUpperCase();
    if (!code) return;

    guestStore.clearGuest();

    try {
      const guest = await findGuestByCode(code);
      if (!guest) return;

      guestStore.setGuest(guest, code);
      hasVerifiedInvitation = true;
    } catch (error) {
      console.error('Could not verify invitation code; showing Save the Date splash.', error);
    }
  });
</script>

<svelte:head>
  {#if hasVerifiedInvitation}
    <title>{site.coupleNames} — Wedding Invitation</title>
    <meta name="description" content="{site.coupleNames}'s wedding invitation, RSVP, weekend programme and guest information." />
  {/if}
</svelte:head>

{#if hasVerifiedInvitation}
  <Hero>
    {#snippet action()}
      <GuestLookupModal />
    {/snippet}
  </Hero>

  <Welcome />
  <Timeline />
  <VenueMap />
  <Accommodations />
  <RsvpForm />
  <Registry />
  <Guestbook />
  <PhotoGallery />
{:else}
  <SaveTheDateSplash />
{/if}
