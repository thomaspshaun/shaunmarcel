<script lang="ts">
  import { page } from '$app/state';
  import Hero from '$lib/components/Hero.svelte';
  import Welcome from '$lib/components/Welcome.svelte';
  import Timeline from '$lib/components/Timeline.svelte';
  import VenueMap from '$lib/components/VenueMap.svelte';
  import Accommodations from '$lib/components/Accommodations.svelte';
  import RsvpForm from '$lib/components/RsvpForm.svelte';
  import PhotoGallery from '$lib/components/PhotoGallery.svelte';
  import Guestbook from '$lib/components/Guestbook.svelte';
  import GuestPhotoUpload from '$lib/components/GuestPhotoUpload.svelte';
  import GuestHeader from '$lib/components/GuestHeader.svelte'; // Hidden for now
  import GuestLookupModal from '$lib/components/GuestLookupModal.svelte';
  import Registry from '$lib/components/Registry.svelte';
  import InvitationEnvelope from '$lib/components/InvitationEnvelope.svelte';
  import SaveTheDateSplash from '$lib/components/SaveTheDateSplash.svelte';
  import { site } from '$lib/site-config';

  let hasUniqueCode = $derived(Boolean(page.url.searchParams.get('code')?.trim()));
</script>

<svelte:head>
  {#if !hasUniqueCode}
    <title>{site.coupleNames} — Wedding Invitation</title>
    <meta name="description" content="{site.coupleNames}'s wedding invitation, RSVP, weekend programme and guest information." />
  {/if}
</svelte:head>

{#if hasUniqueCode}
  <SaveTheDateSplash />
{:else}
  <!-- GuestHeader hidden for now -->

  <InvitationEnvelope />

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
  <PhotoGallery />
  <Guestbook />
  <GuestPhotoUpload />
{/if}