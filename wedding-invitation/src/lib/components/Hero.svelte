<script lang="ts">
  import CountdownTimer from '$lib/components/CountdownTimer.svelte';
  import { site } from '$lib/site-config';
</script>

<section
  id="hero"
  class="relative flex min-h-[calc(100svh-64px)] items-center justify-center overflow-hidden px-6 py-16 sm:py-20"
>
  <!-- Soft decorative background accents -->
  <div class="pointer-events-none absolute inset-0 -z-10">
    <div
      class="absolute -top-24 -left-20 h-72 w-72 rounded-full bg-[radial-gradient(circle,_rgba(251,113,133,0.18),_transparent_70%)] blur-2xl"
    ></div>
    <div
      class="absolute top-1/3 -right-16 h-80 w-80 rounded-full bg-[radial-gradient(circle,_rgba(244,182,80,0.16),_transparent_70%)] blur-2xl"
    ></div>
  </div>

  <div class="mx-auto w-full max-w-3xl text-center">
    <p class="text-xs font-semibold uppercase tracking-[0.4em] text-rose-500 sm:text-sm">
      {site.tagline}
    </p>

    <h1
      class="mt-6 text-[clamp(2.5rem,8vw,5.5rem)] leading-[1.05] font-light tracking-tight text-slate-900"
    >
      {site.coupleNames}
    </h1>

    <p class="mx-auto mt-6 max-w-xl text-base leading-7 text-slate-600 sm:text-lg">
      {site.weddingDateLabel} &middot; {site.venueName}
    </p>

    <div class="mt-10">
      <CountdownTimer targetIso={site.countdownTargetIso} />
    </div>

    <div class="mt-10 flex flex-wrap items-center justify-center gap-4">
      <a
        href="#rsvp"
        class="rounded-full bg-rose-500 px-7 py-3 text-sm font-medium text-white shadow-lg shadow-rose-200 transition hover:bg-rose-600"
      >
        RSVP Now
      </a>
      <a
        href="#details"
        class="rounded-full border border-slate-300 px-7 py-3 text-sm font-medium text-slate-700 transition hover:border-slate-400 hover:bg-slate-50"
      >
        View Details
      </a>
    </div>
  </div>
</section>
