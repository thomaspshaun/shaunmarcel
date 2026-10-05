<script lang="ts">
  import { reveal } from '$lib/actions/reveal';
  import { venue } from '$lib/site-config';

  const embedSrc = `https://www.google.com/maps?q=${encodeURIComponent(venue.mapEmbedQuery)}&output=embed`;
</script>

<section id="venue" class="border-t border-line/70 bg-paper-2/40 px-6 py-24 sm:py-32">
  <div class="mx-auto max-w-5xl">
    <div class="text-center" use:reveal>
      <p class="eyebrow">The Venue</p>
      <h2 class="heading mt-4">{venue.name}</h2>
      <p class="mt-4 text-[0.68rem] uppercase tracking-[0.3em] text-muted">{venue.region}</p>
      <p class="lede mx-auto mt-6 max-w-md">The ceremony and reception will both take place at {venue.name}.</p>
      <a href={venue.mapsUrl} target="_blank" rel="noopener noreferrer" class="btn-ghost mt-8">Get directions</a>
    </div>

    {#if venue.image}
      <figure class="mt-14 overflow-hidden" use:reveal>
        <img src={venue.image} alt={venue.name} class="aspect-[4/5] w-full object-cover sm:aspect-[16/9]" loading="lazy" />
      </figure>
    {/if}

    <div class="mt-14 border border-line p-2 sm:p-3" use:reveal>
      <iframe
        title="Venue map"
        src={embedSrc}
        class="h-72 w-full sm:h-96"
        style="border:0; filter: grayscale(0.7) sepia(0.2) contrast(0.95);"
        loading="lazy"
        referrerpolicy="no-referrer-when-downgrade"
      ></iframe>
    </div>
  </div>
</section>