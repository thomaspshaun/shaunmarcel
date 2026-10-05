<script lang="ts">
  import { accommodations } from '$lib/site-config';
  import { guestStore } from '$lib/guestStore';

  let guest = $derived($guestStore.guest);
  let isWeddingParty = $derived(guest?.guest_type === 'wedding_party');
</script>

<section id="accommodation" class="mx-auto max-w-5xl px-6 py-20">
  <div class="text-center">
    <p class="text-xs font-semibold uppercase tracking-[0.4em] text-rose-500 sm:text-sm">
      Where to Stay
    </p>
    <h2 class="mt-4 text-3xl font-light tracking-tight text-slate-900 sm:text-4xl">
      {isWeddingParty ? 'Venue Accommodation' : 'Accommodation'}
    </h2>
    <p class="mx-auto mt-3 max-w-xl text-base text-slate-600">
      {#if isWeddingParty}
        You have exclusive accommodation at the venue as part of the wedding party. Details below.
      {:else}
        A few options near the venue for out-of-town guests. Booking codes will be shared closer to
        the date.
      {/if}
    </p>
  </div>

  {#if isWeddingParty}
    <!-- Wedding party sees venue accommodation (already paid) -->
    <div class="mt-12 rounded-2xl border-2 border-rose-200 bg-rose-50 p-8">
      <div class="flex items-start gap-4">
        <div class="text-3xl">🏠</div>
        <div>
          <h3 class="text-xl font-semibold text-slate-900">Estate Accommodation</h3>
          <p class="mt-2 text-slate-600">
            Your accommodation at the estate is included as part of the wedding party. You'll receive
            further details, check-in instructions, and contact information via email and WhatsApp
            closer to the date.
          </p>
          <p class="mt-4 text-sm font-medium text-rose-600">
            ✓ Room assigned based on party size<br />
            ✓ Breakfast included<br />
            ✓ Parking available<br />
            ✓ Venue access all weekend
          </p>
        </div>
      </div>
    </div>
  {:else}
    <!-- Regular guests see public accommodation options -->
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
  {/if}
</section>
