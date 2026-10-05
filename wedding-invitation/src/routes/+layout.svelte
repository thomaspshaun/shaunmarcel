<script lang="ts">
  import '../app.css';
  import Footer from '$lib/components/Footer.svelte';
  import Nav from '$lib/components/Nav.svelte';
  import { site } from '$lib/site-config';

  let { children } = $props();

  const title = `${site.coupleNames} — Wedding Invitation`;
  const description = `${site.coupleNames} invite you to a wedding weekend at ${site.venueName}, ${site.region}. Details, accommodation and RSVP.`;
  const image = `${site.siteUrl}${site.socialImagePath}`;
</script>

<svelte:head>
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
  <link
    href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,500;0,600;1,400&family=Manrope:wght@300;400;500;600&family=Parisienne&display=swap"
    rel="stylesheet"
  />
  <meta property="og:type" content="website" />
  <meta property="og:title" content={title} />
  <meta property="og:description" content={description} />
  <meta property="og:url" content={site.siteUrl} />
  <meta property="og:image" content={image} />
  <meta name="twitter:card" content="summary" />
  <meta name="twitter:title" content={title} />
  <meta name="twitter:description" content={description} />
  <meta name="twitter:image" content={image} />
</svelte:head>

<div class="flex min-h-screen flex-col">
  <!-- Nav hidden for now -->
  <main class="flex-1">
    {@render children()}
  </main>
  <Footer />
</div>