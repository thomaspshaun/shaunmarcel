<script lang="ts">
  import { guestStore } from '$lib/guestStore';
  import { toGuestProfile } from '$lib/guestProfile';
  import { reveal } from '$lib/actions/reveal';
  import { accommodations, venue } from '$lib/site-config';

  let guest = $derived($guestStore.guest);
  let profile = $derived(toGuestProfile(guest));
  let showMore = $state(false);

  const closest = accommodations.filter((a) => a.group === 'closest');
  const further = accommodations.filter((a) => a.group === 'further');
</script>

<section id="accommodation" class="mx-auto max-w-4xl px-6 py-24 sm:py-32">
  {#if profile?.weddingParty}
    <div class="text-center" use:reveal>
      <p class="eyebrow">Your Accommodation</p>
      <h2 class="heading mt-4">Arranged for you at {venue.name}</h2>
      <p class="lede mx-auto mt-6 max-w-lg">
        Accommodation at {venue.name} has been arranged for members of the wedding party. Your
        invitation will include your accommodation details and any relevant check-in information.
      </p>
    </div>

    {#if guest?.accommodation_name}
      <dl class="mx-auto mt-12 max-w-sm border-y border-line text-sm">
        <div class="flex justify-between gap-6 border-b border-line/70 py-4">
          <dt class="text-muted">Accommodation</dt>
          <dd class="text-right text-ink">{guest.accommodation_name}</dd>
        </div>
        {#if guest.room_nights}
          <div class="flex justify-between gap-6 border-b border-line/70 py-4">
            <dt class="text-muted">Nights</dt>
            <dd class="text-ink">{guest.room_nights}</dd>
          </div>
        {/if}
        <div class="flex justify-between gap-6 py-4">
          <dt class="text-muted">Status</dt>
          <dd class="text-ink">{guest.accommodation_confirmed ? 'Confirmed' : 'To be confirmed'}</dd>
        </div>
      </dl>
    {/if}
  {:else}
    <div class="text-center" use:reveal>
      <p class="eyebrow">Where to Stay</p>
      <h2 class="heading mt-4">Accommodation Nearby</h2>
      <p class="lede mx-auto mt-6 max-w-lg">
        Guests can choose from a selection of nearby hotels, guesthouses and wine estates. We have
        gathered a few close to {venue.name} to make planning your stay easier.
      </p>
    </div>

    <p class="eyebrow eyebrow-accent mt-16">Closest to the venue</p>
    <ul class="mt-4 border-t border-line">
      {#each closest as stay (stay.id)}
        {@render entry(stay)}
      {/each}
    </ul>

    {#if showMore}
      <p class="eyebrow eyebrow-accent mt-14">More options</p>
      <ul class="mt-4 border-t border-line">
        {#each further as stay (stay.id)}
          {@render entry(stay)}
        {/each}
      </ul>
    {/if}

    <div class="mt-10 text-center">
      <button type="button" class="btn-ghost" aria-expanded={showMore} onclick={() => (showMore = !showMore)}>
        {showMore ? 'Show fewer options' : 'More options'}
      </button>
      <p class="mx-auto mt-8 max-w-md text-xs leading-6 text-muted">
        Price level is a relative guide only ($ to $$$$). Rates for April 2027 may not be published
        yet, so please check each property for current prices.
      </p>
    </div>
  {/if}
</section>

{#snippet entry(stay: (typeof accommodations)[number])}
  <li class="grid gap-5 border-b border-line py-8 sm:grid-cols-[1fr_auto] sm:items-center sm:gap-10" use:reveal>
    <div>
      <div class="flex flex-wrap items-baseline gap-x-4 gap-y-1">
        <h3 class="font-display text-2xl text-ink sm:text-3xl">{stay.name}</h3>
        <span class="eyebrow eyebrow-accent">{stay.distance} from Eikenhof</span>
      </div>
      <p class="lede mt-2 max-w-xl text-sm">{stay.description}</p>
      <p class="mt-3 text-sm tracking-[0.2em]" aria-label="Price level {stay.price.length} of 4">
        <span class="text-sage-dark">{stay.price}</span><span class="text-line">{'$'.repeat(4 - stay.price.length)}</span>
      </p>
    </div>
    <a href={stay.url} target="_blank" rel="noopener noreferrer" class="btn-ghost justify-self-start sm:justify-self-end">
      View accommodation
    </a>
  </li>
{/snippet}