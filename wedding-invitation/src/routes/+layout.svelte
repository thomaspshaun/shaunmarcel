<script lang="ts">
  import '../app.css';
  import Footer from '$lib/components/Footer.svelte';
  import Nav from '$lib/components/Nav.svelte';
  import { site } from '$lib/site-config';

  let { children } = $props();
</script>

<svelte:head>\n  <link rel="preconnect" href="https://fonts.googleapis.com" />\n  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />\n  <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@400;500;600&family=Manrope:wght@400;500;600&family=Parisienne&display=swap" rel="stylesheet" />
  <meta property="og:type" content="website" />
  <meta property="og:title" content={`${site.coupleNames} â€” Wedding Invitation`} />
  <meta
    property="og:description"
    content={`${site.coupleNames}'s wedding invitation, event details, and RSVP.`}
  />
  <meta property="og:url" content={site.siteUrl} />
  <meta property="og:image" content={`${site.siteUrl}${site.socialImagePath}`} />
  <meta name="twitter:card" content="summary" />
  <meta name="twitter:title" content={`${site.coupleNames} â€” Wedding Invitation`} />
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

