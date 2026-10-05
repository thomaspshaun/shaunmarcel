<script lang="ts">
  import CountdownTimer from "$lib/components/CountdownTimer.svelte";
  import { site } from "$lib/site-config";
</script>

<section id="hero" class="relative flex min-h-[calc(100svh-72px)] items-center justify-center overflow-hidden px-6 py-20 sm:py-28">
  <div class="pointer-events-none absolute inset-0" aria-hidden="true">
    <div class="absolute inset-x-8 top-8 bottom-8 border border-[var(--color-border)]/70 sm:inset-x-16"></div>
    <div class="absolute left-1/2 top-1/2 h-px w-20 -translate-x-1/2 bg-[var(--color-accent)]/70"></div>
  </div>

  <div class="relative mx-auto w-full max-w-4xl text-center">
    <p class="text-[0.65rem] font-semibold uppercase tracking-[0.38em] text-[var(--color-primary)] sm:text-xs">
      Together with their families
    </p>
    <p class="font-script mt-8 text-4xl text-[var(--color-accent)] sm:text-5xl">Our Wedding</p>
    <h1 class="font-display mt-3 text-[clamp(4rem,13vw,9rem)] leading-[0.82] font-medium tracking-[-0.04em] text-[var(--color-text)]">
      Shaun <span class="text-[var(--color-accent)]">&</span> Marcel
    </h1>
    <div class="mx-auto mt-10 flex items-center justify-center gap-4 text-[0.68rem] font-semibold uppercase tracking-[0.28em] text-[var(--color-text-muted)] sm:text-xs">
      <span>17 April 2027</span><span class="text-[var(--color-accent)]">·</span><span>Eikenhof Estate</span>
    </div>
    <p class="mt-3 text-xs uppercase tracking-[0.25em] text-[var(--color-text-muted)]">Cape Winelands · South Africa</p>
    <div class="mx-auto mt-12 max-w-xs border-y border-[var(--color-border)] py-5"><CountdownTimer targetIso={site.countdownTargetIso} /></div>
    <div class="mt-10 flex flex-wrap items-center justify-center gap-5">
      <a href="#rsvp" class="border border-[var(--color-primary)] bg-[var(--color-primary)] px-7 py-3 text-xs font-semibold uppercase tracking-[0.2em] text-[var(--color-surface)] transition hover:bg-[var(--color-primary-dark)]">RSVP</a>
      <a href="#details" class="border border-[var(--color-border)] px-7 py-3 text-xs font-semibold uppercase tracking-[0.2em] text-[var(--color-text)] transition hover:border-[var(--color-primary)]">Our weekend</a>
      <slot name="action" />
    </div>
  </div>
</section>
