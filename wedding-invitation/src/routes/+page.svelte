<script lang="ts">
  import Hero from '$lib/components/Hero.svelte';
  import Timeline from '$lib/components/Timeline.svelte';
  import VenueMap from '$lib/components/VenueMap.svelte';
  import Accommodations from '$lib/components/Accommodations.svelte';
  import RsvpForm from '$lib/components/RsvpForm.svelte';
  import { site } from '$lib/site-config';
</script>

<svelte:head>
  <title>{site.coupleNames} — Wedding Invitation</title>
  <meta name="description" content="{site.coupleNames}'s wedding invitation, RSVP, event schedule, and guest information." />
</svelte:head>

<Hero />

<div id="details">
  <Timeline />
  <VenueMap />
  <Accommodations />
</div>

<RsvpForm />
