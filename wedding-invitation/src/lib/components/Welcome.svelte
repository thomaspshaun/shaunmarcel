<script lang="ts">
  import Sprig from '$lib/components/Sprig.svelte';
  import { reveal } from '$lib/actions/reveal';
  import { site } from '$lib/site-config';

  const notes = [
    `The wedding ceremony and reception will both take place at ${site.venueName}.`,
    'Your invitation is personalised, so the information shown will be specific to you and your role in the wedding.',
    'Further details, including RSVP, accommodation, directions and other useful information, will be available on this website.'
  ];
</script>

<section class="border-y border-line/70 bg-paper-2/50 px-6 py-24 sm:py-32">
  <div class="mx-auto max-w-2xl text-center" use:reveal>
    <p class="font-script text-5xl text-champagne sm:text-6xl">Our Wedding</p>
    <p class="font-display mt-8 text-2xl leading-relaxed text-ink italic sm:text-3xl">
      We'd love for you to join us for a relaxed wedding weekend at {site.venueName} in the Cape Winelands.
    </p>
    <Sprig class="mx-auto mt-10 h-5 w-32 text-champagne" />

    <p class="eyebrow mt-12">A few things to know</p>
    <ul class="mx-auto mt-6 max-w-lg text-left">
      {#each notes as note (note)}
        <li class="flex gap-4 border-b border-line/60 py-4 text-sm leading-7 text-muted last:border-0 sm:text-base">
          <span class="mt-2.5 h-1 w-1 shrink-0 rotate-45 bg-champagne" aria-hidden="true"></span>
          <span>{note}</span>
        </li>
      {/each}
    </ul>
  </div>
</section>