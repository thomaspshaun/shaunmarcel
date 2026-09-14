<script lang="ts">
  import { site } from '$lib/site-config';

  const year = new Date().getFullYear();
</script>

<footer class="border-t border-rose-100/70 bg-white/60 py-10 text-center text-sm text-slate-500">
  <p class="font-medium text-slate-700">{site.coupleNames}</p>
  <p class="mt-1">{site.weddingDateLabel} &middot; {site.venueName}</p>
  <p class="mt-1">
    <a href={site.contactPhoneHref} class="underline underline-offset-4 hover:text-rose-500">
      {site.contactPhoneDisplay}
    </a>
  </p>
  <p class="mt-4 text-xs text-slate-400">&copy; {year} {site.coupleNames}. Made with love.</p>
</footer>
