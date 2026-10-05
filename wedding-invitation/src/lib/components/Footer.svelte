<script lang="ts">
  import Sprig from '$lib/components/Sprig.svelte';
  import { site } from '$lib/site-config';

  const year = new Date().getFullYear();
</script>

<footer class="border-t border-line/70 px-6 py-16 text-center">
  <p class="font-script text-5xl text-ink">{site.coupleNames}</p>
  <Sprig class="mx-auto mt-6 h-5 w-32 text-champagne" />
  <p class="mt-6 text-[0.68rem] uppercase tracking-[0.3em] text-muted">
    {site.weddingDateLabel} <span class="px-1 text-champagne">·</span> {site.venueName}
  </p>
  <p class="mt-4 text-sm text-muted">
    <a href={site.contactPhoneHref} class="underline decoration-line underline-offset-4 hover:text-sage-dark">
      {site.contactPhoneDisplay}
    </a>
  </p>
  <p class="mt-10 text-[0.6rem] uppercase tracking-[0.25em] text-muted/70">&copy; {year} {site.coupleNames}</p>
</footer>