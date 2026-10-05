<script lang="ts">
  import { venue } from '$lib/site-config';

  const embedSrc = `https://www.google.com/maps?q=${encodeURIComponent(venue.mapEmbedQuery)}&output=embed`;
</script>

<section id="venue" class="mx-auto max-w-5xl px-6 py-28">
  <div class="text-center">
    <p class="text-xs font-semibold uppercase tracking-[0.4em] text-[var(--color-primary)] sm:text-sm">Location</p>
    <h2 class="mt-4 font-display text-4xl font-medium tracking-tight text-[var(--color-text)] sm:text-5xl">{venue.name}</h2>
    <p class="mt-3 text-base text-[var(--color-text-muted)]">{venue.address}</p>

    <a
      href={venue.mapsUrl}
      target="_blank"
      rel="noopener noreferrer"
      class="mt-6 inline-flex items-center gap-2 border border-[var(--color-primary)] bg-[var(--color-primary)] px-6 py-3 text-xs font-semibold uppercase tracking-[0.2em] text-[var(--color-surface)] transition hover:bg-[var(--color-primary-dark)]"
    >
      Get Directions
    </a>
  </div>

  <div class="mt-10 overflow-hidden border-y border-[var(--color-border)] py-3">
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

