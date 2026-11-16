<script lang="ts">
  import { reveal } from '$lib/actions/reveal';
  import { accommodations, venue } from '$lib/site-config';

  const recommended = accommodations.filter((stay) => stay.group === 'recommended');
  const nearby = accommodations.filter((stay) => stay.group === 'nearby');
</script>

<section id="accommodation" class="mx-auto max-w-5xl px-6 py-12 sm:py-16">
  <div class="text-center" use:reveal>
    <p class="eyebrow">Where to Stay</p>
    <h2 class="heading mt-4">Accommodation Nearby</h2>
    <p class="lede mx-auto mt-4 max-w-lg">
      Here are some nearby places to stay while celebrating with us at {venue.name}.
    </p>
    <p class="mt-2 text-xs text-muted">
      Approximate driving distances from {venue.name}; actual routes may vary.
    </p>
  </div>

  <h3 class="eyebrow eyebrow-accent mt-6">Recommended Accommodation</h3>
  <div class="mt-3 grid gap-3 md:grid-cols-3">
    {#each recommended as stay (stay.id)}
      <article class="border border-line/70 bg-surface/80 p-4" use:reveal>
        <h4 class="font-display text-xl leading-tight text-ink">{stay.name}</h4>
        <p class="eyebrow eyebrow-accent mt-1">{stay.distance}</p>
        <p class="mt-2 text-sm leading-5 text-ink">{stay.description}</p>
        <div class="mt-2 space-y-1 text-xs text-ink">
          <p>Email: <a class="underline" href={'mailto:' + stay.email}>{stay.email}</a></p>
          {#if stay.phone}
            <p>
              Tel:
              <a class="underline" href={'tel:' + stay.phone.replace(/[^+\d]/g, '')}>{stay.phone}</a>
            </p>
          {/if}
          <a
            href={stay.url}
            target="_blank"
            rel="noopener noreferrer"
            class="btn-ghost mt-2 inline-flex !px-3 !py-1.5"
          >
            Visit Website
          </a>
        </div>
      </article>
    {/each}
  </div>

  <h3 class="eyebrow eyebrow-accent mt-6">Other Nearby Options</h3>
  <ul class="mt-2 border-t border-line">
    {#each nearby as stay (stay.id)}
      <li class="grid gap-2 border-b border-line py-2 sm:grid-cols-[1fr_auto] sm:items-center">
        <div>
          <div class="flex flex-wrap items-baseline gap-x-3 gap-y-1">
            <h4 class="font-display text-lg text-ink">{stay.name}</h4>
            <span class="eyebrow eyebrow-accent">{stay.distance}</span>
          </div>
          <div class="mt-1 flex flex-wrap gap-x-4 gap-y-1 text-xs">
            <a class="underline" href={'mailto:' + stay.email}>{stay.email}</a>
            {#if stay.phone}
              <a class="underline" href={'tel:' + stay.phone.replace(/[^+\d]/g, '')}>{stay.phone}</a>
            {/if}
          </div>
        </div>
        <a
          href={stay.url}
          target="_blank"
          rel="noopener noreferrer"
          class="btn-ghost justify-self-start !px-3 !py-1.5 sm:justify-self-end"
        >
          Visit Website
        </a>
      </li>
    {/each}
  </ul>
</section>
