<script lang="ts">
  import { reveal } from '$lib/actions/reveal';
  import { accommodations, venue } from '$lib/site-config';
  const recommended = accommodations.filter((a) => a.group === 'recommended');
  const nearby = accommodations.filter((a) => a.group === 'nearby');
</script>

<section id="accommodation" class="mx-auto max-w-4xl px-6 py-12 sm:py-16">
  <div class="text-center" use:reveal>
      <p class="eyebrow">Where to Stay</p>
      <h2 class="heading mt-4">Accommodation Nearby</h2>
      <p class="lede mx-auto mt-6 max-w-lg">
        Here are some nearby places to stay while celebrating with us at {venue.name}.
      </p>
      <p class="mt-3 text-xs text-muted">
        Approximate driving distances from {venue.name}; actual routes may vary.
      </p>
  </div>

    <h3 class="eyebrow eyebrow-accent mt-8">Recommended Accommodation</h3>
    <div class="mt-4 grid gap-3 md:grid-cols-3">
      {#each recommended as stay (stay.id)}
        <article class="border border-line/70 bg-surface/80 p-4 sm:p-5" use:reveal>
          <h4 class="font-display text-2xl leading-tight text-ink">{stay.name}</h4>
          <p class="eyebrow eyebrow-accent mt-1.5">{stay.distance}</p>
          <p class="lede mt-2 text-sm leading-5">{stay.description}</p>
          {#if stay.promotion}
            <p class="mt-2 text-sm leading-5 text-ink">
              Wedding guests receive a <strong>{stay.promotion}</strong> when booking directly via email.
              Contact Pia at <a class="underline" href={'mailto:' + stay.email}>{stay.email}</a> and quote
              <strong>"Shaun &amp; Marcel"</strong>.
            </p>
          {/if}
          <div class="mt-3 space-y-1.5 text-sm">
            {#if !stay.promotion}
              <p>Email: <a class="underline" href={'mailto:' + stay.email}>{stay.email}</a></p>
            {/if}
            {#if stay.phone}
              <p>Tel: <a class="underline" href={'tel:' + stay.phone.replace(/[^+\d]/g, '')}>{stay.phone}</a></p>
            {/if}
            <a href={stay.url} target="_blank" rel="noopener noreferrer" class="btn-ghost mt-2 inline-flex !px-4 !py-2">
              Visit Website
            </a>
          </div>
        </article>
      {/each}
    </div>

    <h3 class="eyebrow eyebrow-accent mt-8">Other Nearby Options</h3>
    <ul class="mt-4 border-t border-line">
      {#each nearby as stay (stay.id)}
        <li class="grid gap-2 border-b border-line py-3 sm:grid-cols-[1fr_auto] sm:items-center">
          <div>
            <div class="flex flex-wrap items-baseline gap-x-4 gap-y-1">
              <h4 class="font-display text-xl text-ink">{stay.name}</h4>
              <span class="eyebrow eyebrow-accent">{stay.distance}</span>
            </div>
            <div class="mt-1 flex flex-wrap gap-x-5 gap-y-1 text-sm">
              <a class="underline" href={'mailto:' + stay.email}>{stay.email}</a>
              {#if stay.phone}
                <a class="underline" href={'tel:' + stay.phone.replace(/[^+\d]/g, '')}>{stay.phone}</a>
              {/if}
            </div>
          </div>
          <a href={stay.url} target="_blank" rel="noopener noreferrer" class="btn-ghost justify-self-start !px-4 !py-2 sm:justify-self-end">
            Visit Website
          </a>
        </li>
      {/each}
    </ul>
</section>