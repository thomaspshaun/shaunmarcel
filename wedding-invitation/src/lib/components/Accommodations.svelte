<script lang="ts">
  import { accommodations, additionalAccommodations } from "$lib/site-config";
  import { guestStore } from "$lib/guestStore";

  let guest = $derived($guestStore.guest);
  let isWeddingParty = $derived(guest?.guest_type === "wedding_party");
  let showAdditional = $state(false);
</script>

<section id="accommodation" class="mx-auto max-w-5xl px-6 py-20">
  <div class="text-center">
    <p class="text-xs font-semibold uppercase tracking-[0.4em] text-rose-500 sm:text-sm">
      Where to Stay
    </p>
    <h2 class="mt-4 text-3xl font-light tracking-tight text-slate-900 sm:text-4xl">
      {isWeddingParty ? "Venue Accommodation" : "Accommodation"}
    </h2>
    <p class="mx-auto mt-3 max-w-xl text-base text-slate-600">
      {#if isWeddingParty}
        Your accommodation at Eikenhof Estate has been arranged as part of the wedding party.
      {:else}
        We've curated nearby accommodation options to suit different preferences and budgets.
      {/if}
    </p>
  </div>

  {#if isWeddingParty}
    <!-- Wedding party sees venue accommodation (already paid) -->
    <div class="mt-12 rounded-2xl border-2 border-rose-200 bg-rose-50 p-8">
      <div class="flex items-start gap-4">
        <div class="text-3xl">🏠</div>
        <div>
          <h3 class="text-xl font-semibold text-slate-900">Eikenhof Estate</h3>
          <p class="mt-2 text-slate-600">
            Your accommodation at Eikenhof Estate is included as part of the wedding party. Your
            personalised invitation will include room details, check-in instructions, and all
            necessary contact information.
          </p>
          <p class="mt-4 text-sm font-medium text-rose-600">
            ✓ Room assigned based on your party<br />
            ✓ Breakfast included<br />
            ✓ Parking available<br />
            ✓ Weekend access to grounds
          </p>
        </div>
      </div>
    </div>
  {:else}
    <!-- Regular guests see curated accommodation options -->
    <div class="mt-12 grid gap-6 sm:grid-cols-2 lg:grid-cols-2">
      {#each accommodations as stay (stay.id)}
        <a
          href={stay.url}
          target="_blank"
          rel="noopener noreferrer"
          class="group flex flex-col rounded-2xl border border-slate-200 bg-white p-6 text-left shadow-sm transition hover:shadow-md hover:border-rose-300"
        >
          <h3 class="text-lg font-medium text-slate-900 group-hover:text-rose-600 transition">
            {stay.name}
          </h3>
          <p class="mt-1 text-xs font-semibold tracking-[0.15em] text-slate-500 uppercase">
            {stay.distance}
          </p>
          <p class="mt-3 flex-1 text-sm leading-6 text-slate-600">{stay.notes}</p>

          <div class="mt-4 rounded-lg bg-slate-50 px-3 py-2 text-xs text-slate-500">
            Price level: <span class="font-semibold text-slate-700">{stay.bookingCode}</span>
          </div>

          <div class="mt-4 inline-flex items-center justify-center rounded-full border border-slate-300 px-5 py-2 text-sm font-medium text-slate-700 group-hover:border-rose-400 group-hover:bg-rose-50 transition">
            View Accommodation →
          </div>
        </a>
      {/each}
    </div>

    <!-- Additional options toggle -->
    <div class="mt-12 text-center">
      <button
        type="button"
        onclick={() => (showAdditional = !showAdditional)}
        class="inline-flex items-center gap-2 text-sm font-medium text-rose-600 hover:text-rose-700 transition"
      >
        {showAdditional ? "Hide" : "Show"} additional accommodation options
        <span class="transition" class:rotate-180={showAdditional}>▼</span>
      </button>

      {#if showAdditional}
        <div class="mx-auto mt-8 max-w-2xl">
          <p class="mb-6 text-sm text-slate-600">
            Here are some additional options a bit further from the venue:
          </p>
          <div class="space-y-3">
            {#each additionalAccommodations as option (option.name)}
              <a
                href={option.url}
                target="_blank"
                rel="noopener noreferrer"
                class="flex items-center justify-between gap-4 rounded-lg border border-slate-200 bg-white p-4 text-left transition hover:border-rose-300 hover:bg-rose-50"
              >
                <div>
                  <p class="font-medium text-slate-900 hover:text-rose-600">{option.name}</p>
                  <p class="text-xs text-slate-500">{option.distance}</p>
                </div>
                <div class="text-right">
                  <p class="text-sm font-medium text-slate-700">{option.price}</p>
                  <p class="text-xs text-slate-400">→</p>
                </div>
              </a>
            {/each}
          </div>
        </div>
      {/if}
    </div>
  {/if}
</section>
