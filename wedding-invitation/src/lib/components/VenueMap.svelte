<script lang="ts">
  import { venue } from '$lib/site-config';

  const embedSrc = `https://www.google.com/maps?q=${encodeURIComponent(venue.mapEmbedQuery)}&output=embed`;
</script>

<section id="venue" class="mx-auto max-w-4xl px-6 py-20">
  <div class="text-center">
    <p class="text-xs font-semibold uppercase tracking-[0.4em] text-rose-500 sm:text-sm">Location</p>
    <h2 class="mt-4 text-3xl font-light tracking-tight text-slate-900 sm:text-4xl">{venue.name}</h2>
    <p class="mt-3 text-base text-slate-600">{venue.address}</p>

    <a
      href={venue.mapsUrl}
      target="_blank"
      rel="noopener noreferrer"
      class="mt-6 inline-flex items-center gap-2 rounded-full bg-rose-500 px-6 py-3 text-sm font-medium text-white shadow-lg shadow-rose-200 transition hover:bg-rose-600"
    >
      Get Directions
    </a>
  </div>

  <div class="mt-10 overflow-hidden rounded-3xl border border-slate-200 shadow-lg">
    <iframe
      title="Venue map"
      src={embedSrc}
      class="h-72 w-full sm:h-96"
      style="border:0;"
      loading="lazy"
      referrerpolicy="no-referrer-when-downgrade"
    ></iframe>
  </div>
</section>
