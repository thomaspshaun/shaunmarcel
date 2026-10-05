<script lang="ts">
  import Hero from '$lib/components/Hero.svelte';
  import Timeline from '$lib/components/Timeline.svelte';
  import VenueMap from '$lib/components/VenueMap.svelte';
  import Accommodations from '$lib/components/Accommodations.svelte';
  import RsvpForm from '$lib/components/RsvpForm.svelte';
  import PhotoGallery from '$lib/components/PhotoGallery.svelte';
  import Guestbook from '$lib/components/Guestbook.svelte';
  import GuestPhotoUpload from '$lib/components/GuestPhotoUpload.svelte';
  import GuestHeader from '$lib/components/GuestHeader.svelte';
  import GuestLookupModal from '$lib/components/GuestLookupModal.svelte';
  import { site } from '$lib/site-config';
  import { guestStore } from '$lib/guestStore';
  import { onMount } from 'svelte';

  let guest = $derived($guestStore.guest);

  // Auto-lookup guest from URL param on mount
  onMount(() => {
    const params = new URLSearchParams(window.location.search);
    const code = params.get('code');
    if (code && !guest) {
      // Trigger lookup via modal's findGuestByCode
      // (handled in RsvpForm component as well, but we set it here for consistency)
    }
  });
</script>

<svelte:head>
  <title>{site.coupleNames} — Wedding Invitation</title>
  <meta name="description" content="{site.coupleNames}'s wedding invitation, RSVP, event schedule, and guest information." />
</svelte:head>

<GuestHeader />

<Hero>
  <slot name="action">
    <GuestLookupModal />
  </slot>
</Hero>

<div id="details">
  <Timeline />
  <VenueMap />
  <Accommodations />
</div>

<RsvpForm />

<PhotoGallery />
<Guestbook />
<GuestPhotoUpload />
