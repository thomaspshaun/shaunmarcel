<script lang="ts">
  import { onMount } from 'svelte';
  import { site } from '$lib/site-config';

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
  <div class="frame" aria-hidden="true">
    <span class="corner corner-top-left"></span>
    <span class="corner corner-top-right"></span>
    <span class="corner corner-bottom-left"></span>
    <span class="corner corner-bottom-right"></span>
  </div>

  <div class="composition">
    <p class="invitation">Save the Date</p>

    <div class="date-block">
      <p class="date">1 April 2027</p>
      <p class="location">Cape Town</p>
    </div>

    <span class="divider" aria-hidden="true"><span></span></span>
    <h1 class="names">{site.coupleNames}</h1>
  </div>
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
    --olive: #bdc3a7;
    --soft-white: #fdfdfd;

    position: fixed;
    inset: 0;
    z-index: 100;
    display: grid;
    min-height: 100vh;
    min-height: 100dvh;
    overflow: hidden;
    place-items: center;
    padding: max(1.25rem, env(safe-area-inset-top)) max(1.25rem, env(safe-area-inset-right))
      max(1.25rem, env(safe-area-inset-bottom)) max(1.25rem, env(safe-area-inset-left));
    color: #51493e;
    background:
      radial-gradient(ellipse at 50% 46%, rgb(253 253 253 / 78%), transparent 58%),
      var(--cream);
    isolation: isolate;
  }

  .splash::before,
  .splash::after {
    position: absolute;
    z-index: -1;
    width: min(45vw, 34rem);
    aspect-ratio: 1;
    content: "";
    pointer-events: none;
    border: 1px solid rgb(166 124 82 / 11%);
    border-radius: 50%;
  }

  .splash::before {
    top: -34%;
    right: -17%;
    box-shadow: 0 0 0 2rem rgb(189 195 167 / 5%), 0 0 0 5rem rgb(210 180 140 / 5%);
  }

  .splash::after {
    bottom: -37%;
    left: -18%;
    box-shadow: 0 0 0 2rem rgb(189 195 167 / 6%), 0 0 0 5rem rgb(210 180 140 / 5%);
  }

  .frame {
    position: absolute;
    inset: max(1rem, env(safe-area-inset-top)) max(1rem, env(safe-area-inset-right))
      max(1rem, env(safe-area-inset-bottom)) max(1rem, env(safe-area-inset-left));
    border: 1px solid rgb(166 124 82 / 28%);
    pointer-events: none;
  }

  .corner {
    position: absolute;
    width: 1.1rem;
    height: 1.1rem;
    border-color: var(--mocca);
    border-style: solid;
  }

  .corner-top-left {
    top: -1px;
    left: -1px;
    border-width: 1px 0 0 1px;
  }

  .corner-top-right {
    top: -1px;
    right: -1px;
    border-width: 1px 1px 0 0;
  }

  .corner-bottom-left {
    bottom: -1px;
    left: -1px;
    border-width: 0 0 1px 1px;
  }

  .corner-bottom-right {
    right: -1px;
    bottom: -1px;
    border-width: 0 1px 1px 0;
  }

  .composition {
    display: flex;
    width: min(100%, 54rem);
    flex-direction: column;
    align-items: center;
    text-align: center;
    animation: arrive 1.2s cubic-bezier(0.2, 0.65, 0.2, 1) both;
  }

  .invitation {
    margin: 0;
    color: var(--olive);
    font-family: var(--font-script);
    font-size: clamp(3.75rem, 13vw, 8.5rem);
    line-height: 0.95;
    text-shadow: 0 1px 0 rgb(166 124 82 / 25%);
  }

  .date-block {
    margin-top: clamp(1.6rem, 5vh, 3rem);
  }

  .date {
    margin: 0;
    color: #4b493f;
    font-family: var(--font-display);
    font-size: clamp(1.45rem, 4vw, 2.45rem);
    font-weight: 500;
    letter-spacing: 0.12em;
  }

  .location {
    margin: 0.75rem 0 0;
    color: var(--mocca);
    font-family: var(--font-body);
    font-size: clamp(0.65rem, 1.8vw, 0.78rem);
    font-weight: 500;
    letter-spacing: 0.3em;
    text-transform: uppercase;
  }

  .divider {
    display: flex;
    width: clamp(4rem, 14vw, 7rem);
    align-items: center;
    justify-content: center;
    gap: 0.55rem;
    margin: clamp(1.5rem, 5vh, 2.75rem) 0 clamp(1rem, 3vh, 1.6rem);
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
    margin: 0;
    color: var(--mocca);
    font-family: var(--font-display);
    font-size: clamp(2rem, 7.5vw, 4.4rem);
    font-weight: 400;
    letter-spacing: 0.045em;
    line-height: 1;
  }

  @keyframes arrive {
    from {
      opacity: 0;
      transform: translateY(18px);
    }

    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  @media (max-height: 620px) {
    .composition {
      transform: scale(0.8);
    }

    .date-block {
      margin-top: 1rem;
    }

    .divider {
      margin: 0.9rem 0 0.6rem;
    }
  }

  @media (prefers-reduced-motion: reduce) {
    .composition {
      animation: none;
    }
  }
</style>
