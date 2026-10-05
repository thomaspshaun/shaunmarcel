<script lang="ts">
  import type { Snippet } from "svelte";
  import CountdownTimer from "$lib/components/CountdownTimer.svelte";
  import Sprig from "$lib/components/Sprig.svelte";
  import { site } from "$lib/site-config";
  import { guestStore } from "$lib/guestStore";

  let { action }: { action?: Snippet } = $props();

  let guest = $derived($guestStore.guest);

  let invitationText = $derived.by(() => {
    if (!guest) return null;
    let names = [guest.first_name];
    
    if (guest.partner_first_name && guest.partner_last_name) {
      names.push(guest.partner_first_name + " " + guest.partner_last_name);
    } else if (guest.plus_one_allowed && guest.plus_one_name) {
      names.push(guest.plus_one_name);
    }
    
    return names.join(" & ");
  });
</script>

<section id="hero" class="px-6 pt-20 pb-24 sm:pt-28 sm:pb-32">
  <div class="mx-auto max-w-4xl text-center">
    {#if invitationText}
      <div class="fade-up" style="--d: 0.1s">
        <p class="font-display text-xl leading-relaxed text-muted sm:text-2xl">
          {invitationText}
          <span class="block text-sm uppercase tracking-[0.18em] sm:text-base">you are invited to the wedding of</span>
        </p>
        <h1 class="font-script mt-8 text-5xl text-ink">{site.coupleNames}</h1>
      </div>
    {:else}
      <p class="eyebrow fade-up" style="--d: 0.1s">{site.tagline}</p>

      <h1 class="font-script fade-up mt-10 text-5xl text-ink" style="--d: 0.35s">{site.coupleNames}</h1>
    {/if}

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