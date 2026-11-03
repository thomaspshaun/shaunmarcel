<script lang="ts">
  import { onMount } from 'svelte';
  import { site } from '$lib/site-config';

  const photo = '/save-the-date-illustration.png';

  onMount(() => {
    const root = document.documentElement;
    const body = document.body;
    root.classList.add('save-date-page');
    body.classList.add('save-date-page');

    return () => {
      root.classList.remove('save-date-page');
      body.classList.remove('save-date-page');
    };
  });
</script>

<svelte:head>
  <title>Save the Date — {site.coupleNames}</title>
  <meta name="description" content="Save the date: 1 April 2027 in Cape Town. Shaun & Marcel." />
  <meta name="theme-color" content="#fffbe8" />
</svelte:head>

<main class="splash" aria-label="Save the date: 1 April 2027, Cape Town, Shaun and Marcel">
  <img
    class="background-image"
    src={photo}
    alt="A hand-drawn bride and groom above a softly textured cream background"
  />
  <div class="veil" aria-hidden="true"></div>
  <div class="frame" aria-hidden="true"></div>

  <section class="composition" aria-label="Wedding details">
    <p class="invitation">Save the Date</p>
    <p class="date">1 April 2027</p>
    <p class="location">Cape Town</p>
    <span class="divider" aria-hidden="true"><span></span></span>
    <h1 class="names">{site.coupleNames}</h1>
  </section>
</main>

<style>
  :global(html.save-date-page),
  :global(body.save-date-page) {
    width: 100%;
    height: 100%;
    overflow: hidden;
  }

  .splash {
    --cream: #fffbe8;
    --taupe: #d2b48c;
    --mocca: #a67c52;
    --olive: #687052;

    position: fixed;
    inset: 0;
    z-index: 100;
    display: grid;
    min-height: 100vh;
    min-height: 100dvh;
    overflow: hidden;
    place-items: center;
    color: var(--olive);
    background: var(--cream);
    isolation: isolate;
  }

  .background-image,
  .veil,
  .frame {
    position: absolute;
    inset: 0;
    width: 100%;
    height: 100%;
  }

  .background-image {
    z-index: -2;
    object-fit: cover;
    object-position: center top;
  }

  .veil {
    z-index: -1;
    background: linear-gradient(
      180deg,
      transparent 24%,
      rgb(255 251 232 / 10%) 31%,
      rgb(255 251 232 / 33%) 48%,
      rgb(255 251 232 / 18%) 100%
    );
    pointer-events: none;
  }

  .frame {
    inset: max(0.7rem, env(safe-area-inset-top)) max(0.7rem, env(safe-area-inset-right))
      max(0.7rem, env(safe-area-inset-bottom)) max(0.7rem, env(safe-area-inset-left));
    width: auto;
    height: auto;
    border: 1px solid rgb(166 124 82 / 35%);
    pointer-events: none;
  }

  .composition {
    position: absolute;
    inset: 31% 1rem max(5%, env(safe-area-inset-bottom));
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: space-evenly;
    text-align: center;
  }

  .invitation,
  .date,
  .location,
  .divider,
  .names {
    margin: 0;
    opacity: 0;
    animation: rise-in 1.15s cubic-bezier(0.2, 0.7, 0.2, 1) forwards;
  }

  .invitation {
    color: var(--olive);
    font-family: var(--font-script);
    font-size: clamp(3.2rem, 11vw, 7.5rem);
    line-height: 1;
    text-shadow: 0 1px 0 rgb(255 251 232 / 75%);
    animation-delay: 150ms;
  }

  .date {
    color: #51493e;
    font-family: var(--font-display);
    font-size: clamp(1.7rem, 5vw, 3.2rem);
    font-variant-numeric: lining-nums;
    font-weight: 500;
    letter-spacing: 0.12em;
    text-shadow: 0 1px 0 rgb(255 251 232 / 75%);
    animation-delay: 350ms;
  }

  .location {
    color: var(--mocca);
    font-family: var(--font-body);
    font-size: clamp(0.7rem, 2vw, 0.95rem);
    font-weight: 500;
    letter-spacing: 0.34em;
    text-transform: uppercase;
    animation-delay: 500ms;
  }

  .divider {
    display: flex;
    width: clamp(4.5rem, 15vw, 7rem);
    align-items: center;
    justify-content: center;
    gap: 0.55rem;
    animation-delay: 650ms;
  }

  .divider::before,
  .divider::after {
    width: 100%;
    height: 1px;
    content: "";
    background: var(--taupe);
  }

  .divider span {
    width: 0.38rem;
    height: 0.38rem;
    flex: 0 0 auto;
    background: var(--olive);
    transform: rotate(45deg);
  }

  .names {
    color: var(--mocca);
    font-family: var(--font-display);
    font-size: clamp(2.2rem, 8vw, 4.8rem);
    font-weight: 400;
    letter-spacing: 0.045em;
    line-height: 1;
    text-shadow: 0 1px 0 rgb(255 251 232 / 75%);
    animation-delay: 800ms;
  }

  @keyframes rise-in {
    from {
      opacity: 0;
      transform: translateY(20px);
    }

    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  @media (max-height: 620px) {
    .composition {
      inset-block: 29% max(3%, env(safe-area-inset-bottom));
    }
  }

  @media (min-width: 760px) {
    .composition {
      inset-inline: max(3rem, 10vw);
      inset-block-start: 29%;
      inset-block-end: 8%;
    }
  }

  @media (prefers-reduced-motion: reduce) {
    .invitation,
    .date,
    .location,
    .divider,
    .names {
      opacity: 1;
      animation: none;
    }
  }
</style>
