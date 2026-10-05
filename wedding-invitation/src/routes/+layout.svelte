<script lang="ts">
  import '../app.css';
  import Footer from '$lib/components/Footer.svelte';
  import Nav from '$lib/components/Nav.svelte';
  import { site } from '$lib/site-config';

  let { children } = $props();
</script>

<svelte:head>
  <meta property="og:type" content="website" />
  <meta property="og:title" content={`${site.coupleNames} — Wedding Invitation`} />
  <meta
    property="og:description"
    content={`${site.coupleNames}'s wedding invitation, event details, and RSVP.`}
  />
  <meta property="og:url" content={site.siteUrl} />
  <meta property="og:image" content={`${site.siteUrl}${site.socialImagePath}`} />
  <meta name="twitter:card" content="summary" />
  <meta name="twitter:title" content={`${site.coupleNames} — Wedding Invitation`} />
  <meta
    name="twitter:description"
    content={`${site.coupleNames}'s wedding invitation, event details, and RSVP.`}
  />
  <meta name="twitter:image" content={`${site.siteUrl}${site.socialImagePath}`} />
</svelte:head>

<div class="flex min-h-screen flex-col">
  <Nav />
  <main class="flex-1">
    {@render children()}
  </main>
  <Footer />
</div>
