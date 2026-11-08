<script lang="ts">
  import { page } from '$app/state';
  import '../app.css';
  import Footer from '$lib/components/Footer.svelte';
  import Nav from '$lib/components/Nav.svelte';
  import { guestStore } from '$lib/guestStore';
  import { site } from '$lib/site-config';

  let { children } = $props();
  let requestedCode = $derived((page.url.searchParams.get('code') ?? '').trim().toUpperCase());
  let hasVerifiedInvitation = $derived(
    Boolean(requestedCode && $guestStore.code === requestedCode && $guestStore.guest)
  );
  let isSplashPage = $derived(page.url.pathname === '/' && !hasVerifiedInvitation);

  const title = `${site.coupleNames} — Wedding Invitation`;
  const description = `${site.coupleNames} invite you to their wedding on 1 April 2027 at ${site.venueName}, ${site.region}. View the ceremony details and RSVP.`;
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

<div class="site-layout flex min-h-screen flex-col" class:save-date-layout={isSplashPage}>
  {#if !isSplashPage}
    <div class="invitation-background" aria-hidden="true"></div>
  {/if}
  <div class="site-content flex flex-1 flex-col">
    <!-- Nav hidden for now -->
    <main class="flex-1">
      {@render children()}
    </main>
    {#if !isSplashPage}
      <Footer />
    {/if}
  </div>
</div>

<style>
  .site-layout {
    position: relative;
    isolation: isolate;
  }

  .invitation-background {
    position: fixed;
    inset: 0;
    z-index: 0;
    background: url('/invitation-background.png') center / cover no-repeat;
    pointer-events: none;
  }

  .site-content {
    position: relative;
    z-index: 1;
  }

  .save-date-layout {
    min-height: 100vh;
    min-height: 100dvh;
    overflow: hidden;
  }
</style>