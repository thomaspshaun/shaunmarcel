<script lang="ts">
  import { onMount } from 'svelte';
  import { get } from 'svelte/store';
  import Hero from '$lib/components/Hero.svelte';
  import Welcome from '$lib/components/Welcome.svelte';
  import Timeline from '$lib/components/Timeline.svelte';
  import VenueMap from '$lib/components/VenueMap.svelte';
  import Accommodations from '$lib/components/Accommodations.svelte';
  import RsvpForm from '$lib/components/RsvpForm.svelte';
  import PhotoGallery from '$lib/components/PhotoGallery.svelte';
  import Guestbook from '$lib/components/Guestbook.svelte';
  import GuestPhotoUpload from '$lib/components/GuestPhotoUpload.svelte';
  import GuestHeader from '$lib/components/GuestHeader.svelte'; // Hidden for now\n  import GuestLookupModal from '$lib/components/GuestLookupModal.svelte';
  import Registry from '$lib/components/Registry.svelte';
  import { site } from '$lib/site-config';
  import { guestStore } from '$lib/guestStore';
  import { findGuestByCode } from '$lib/supabase';

  // Personalised links look like /?code=AB12CD34
  onMount(async () => {
    const code = new URLSearchParams(window.location.search).get('code')?.trim().toUpperCase();
    if (!code || get(guestStore).code === code) return;
    try {
      const result = await findGuestByCode(code);
      if (result) guestStore.setGuest(result, code);
    } catch {
      // Invalid or unavailable code: fall back to the general invitation.
    }
  });
</script>

<svelte:head>
  <title>{site.coupleNames} — Wedding Invitation</title>
  <meta name="description" content="{site.coupleNames}'s wedding invitation, RSVP, weekend programme and guest information." />
</svelte:head>

<!-- GuestHeader hidden for now -->

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