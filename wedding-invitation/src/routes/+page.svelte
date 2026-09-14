<script lang="ts">
  import Hero from '$lib/components/Hero.svelte';
  import Timeline from '$lib/components/Timeline.svelte';
  import VenueMap from '$lib/components/VenueMap.svelte';
  import Accommodations from '$lib/components/Accommodations.svelte';
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

<section id="rsvp" class="mx-auto max-w-4xl px-6 py-20 text-center text-slate-600">
  <p class="text-sm uppercase tracking-[0.3em] text-rose-500">Coming next</p>
  <p class="mt-4 text-lg">The RSVP form will appear here.</p>
</section>
