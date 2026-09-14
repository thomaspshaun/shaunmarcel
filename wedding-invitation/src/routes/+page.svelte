<svelte:head>
  <title>Wedding Invitation</title>
  <meta name="description" content="Wedding invitation details, RSVP, event schedule, and guest information." />
</svelte:head>

<section class="mx-auto flex min-h-screen max-w-6xl flex-col justify-center px-6 py-16 text-slate-800">
  <div class="rounded-3xl border border-rose-200 bg-white/80 p-8 shadow-[0_20px_60px_rgba(15,23,42,0.08)] backdrop-blur-sm md:p-12">
    <p class="text-sm font-semibold uppercase tracking-[0.35em] text-rose-500">Save the date</p>
    <h1 class="mt-6 text-4xl font-light tracking-tight text-slate-900 md:text-7xl">
      Emma & Daniel
    </h1>
    <p class="mt-6 max-w-xl text-base leading-7 text-slate-600 md:text-xl">
      Our celebration begins on 12 October 2026 in Sonoma Valley. More details, updates, and RSVP access
      will be available here soon.
    </p>

    <div class="mt-8 flex flex-wrap gap-4">
      <a
        href="#rsvp"
        class="rounded-full bg-rose-500 px-6 py-3 text-sm font-medium text-white transition hover:bg-rose-600"
      >
        RSVP Now
      </a>
      <a
        href="#details"
        class="rounded-full border border-slate-300 px-6 py-3 text-sm font-medium text-slate-700 transition hover:border-slate-400 hover:bg-slate-50"
      >
        View Details
      </a>
    </div>

    <div class="mt-12 grid gap-4 sm:grid-cols-3">
      <div class="rounded-2xl bg-rose-50 p-4 text-center">
        <p class="text-xs uppercase tracking-[0.25em] text-rose-500">Date</p>
        <p class="mt-3 text-xl font-medium text-slate-800">12 Oct 2026</p>
      </div>
      <div class="rounded-2xl bg-slate-50 p-4 text-center">
        <p class="text-xs uppercase tracking-[0.25em] text-slate-500">Venue</p>
        <p class="mt-3 text-xl font-medium text-slate-800">Sonoma Valley</p>
      </div>
      <div class="rounded-2xl bg-amber-50 p-4 text-center">
        <p class="text-xs uppercase tracking-[0.25em] text-amber-600">Countdown</p>
        <p class="mt-3 text-xl font-medium text-slate-800">Coming soon</p>
      </div>
    </div>
  </div>
</section>
