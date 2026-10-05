<script lang="ts">
  import type { Snippet } from 'svelte';
  import CountdownTimer from '$lib/components/CountdownTimer.svelte';
  import Sprig from '$lib/components/Sprig.svelte';
  import { site } from '$lib/site-config';

  let { action }: { action?: Snippet } = $props();
</script>

<section id="hero" class="px-6 pt-20 pb-24 sm:pt-28 sm:pb-32">
  <div class="mx-auto max-w-4xl text-center">
    <p class="eyebrow fade-up" style="--d: 0.1s">{site.tagline}</p>

    <h1
      class="font-display fade-up mt-10 flex flex-col items-center text-[clamp(3.75rem,15vw,8rem)] leading-[0.95] font-light text-ink sm:mt-12 sm:flex-row sm:items-baseline sm:justify-center sm:gap-6"
      style="--d: 0.35s"
    >
      <span>{site.names[0]}</span>
      <span class="font-script my-1 text-[0.62em] leading-none text-champagne sm:my-0" aria-label="and">&amp;</span>
      <span>{site.names[1]}</span>
    </h1>

    <Sprig class="fade-up mx-auto mt-10 h-5 w-36 text-champagne" />

    <div class="fade-up mt-10" style="--d: 0.7s">
      <p class="text-sm font-semibold uppercase tracking-[0.36em] text-ink">{site.weddingDateLabel}</p>
      <p class="mt-3 text-[0.68rem] uppercase tracking-[0.3em] text-muted">
        {site.venueName} <span class="px-1 text-champagne">·</span> Cape Winelands
      </p>
    </div>

    <div class="fade-up mx-auto mt-14 max-w-sm border-y border-line py-6" style="--d: 0.9s">
      <CountdownTimer targetIso={site.countdownTargetIso} />
    </div>

    <div class="fade-up mt-12 flex flex-wrap items-center justify-center gap-4" style="--d: 1.1s">
      <a href="#rsvp" class="btn">RSVP</a>
      {@render action?.()}
    </div>

    {#if site.heroImage}
      <figure class="mt-20 overflow-hidden">
        <img src={site.heroImage} alt="{site.coupleNames}" class="aspect-[4/5] w-full object-cover sm:aspect-[16/9]" loading="eager" />
      </figure>
    {/if}
  </div>
</section>