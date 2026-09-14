<script lang="ts">
  import { accommodations } from '$lib/site-config';
</script>

<section id="accommodation" class="mx-auto max-w-5xl px-6 py-20">
  <div class="text-center">
    <p class="text-xs font-semibold uppercase tracking-[0.4em] text-rose-500 sm:text-sm">
      Where to Stay
    </p>
    <h2 class="mt-4 text-3xl font-light tracking-tight text-slate-900 sm:text-4xl">
      Accommodation
    </h2>
    <p class="mx-auto mt-3 max-w-xl text-base text-slate-600">
      A few options near the venue for out-of-town guests. Booking codes will be shared closer to
      the date.
    </p>
  </div>

  <div class="mt-12 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
    {#each accommodations as stay (stay.id)}
      <div
        class="flex flex-col rounded-2xl border border-slate-200 bg-white p-6 text-left shadow-sm transition hover:shadow-md"
      >
        <h3 class="text-lg font-medium text-slate-900">{stay.name}</h3>
        <p class="mt-1 text-xs font-semibold tracking-[0.15em] text-rose-500 uppercase">
          {stay.distance}
        </p>
        <p class="mt-3 flex-1 text-sm leading-6 text-slate-600">{stay.notes}</p>

        <div class="mt-4 rounded-lg bg-slate-50 px-3 py-2 text-xs text-slate-500">
          Booking code: <span class="font-semibold text-slate-700">{stay.bookingCode}</span>
        </div>

        <a
          href={stay.url}
          target="_blank"
          rel="noopener noreferrer"
          class="mt-4 inline-flex items-center justify-center rounded-full border border-slate-300 px-5 py-2 text-sm font-medium text-slate-700 transition hover:border-slate-400 hover:bg-slate-50"
        >
          View on Map
        </a>
      </div>
    {/each}
  </div>
</section>
