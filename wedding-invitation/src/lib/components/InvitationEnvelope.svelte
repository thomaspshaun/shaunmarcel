<script lang="ts">
  import { site } from '$lib/site-config';

  let isOpening = $state(false);
  let isDismissed = $state(false);

  function openInvitation() {
    if (isOpening) return;
    isOpening = true;
    window.setTimeout(() => (isDismissed = true), 1450);
  }
</script>

{#if !isDismissed}
  <div class:opening={isOpening} class="intro" aria-label="Wedding invitation">
    <button
      class="envelope-button"
      type="button"
      onclick={openInvitation}
      aria-label="Open the wedding invitation"
      aria-hidden={isOpening}
      tabindex={isOpening ? -1 : 0}
    >
      <span class="hint">Tap to open</span>
      <span class="envelope">
        <span class="letter">
          <span class="letter-kicker">Together with their families</span>
          <span class="letter-names">{site.coupleNames}</span>
          <span class="letter-date">{site.weddingDateLabel}</span>
        </span>
        <span class="envelope-back"></span>
        <span class="envelope-flap"></span>
        <span class="envelope-front"></span>
        <span class="ribbon ribbon-vertical"></span>
        <span class="ribbon ribbon-horizontal"></span>
        <span class="bow" aria-hidden="true">
          <span class="bow-loop bow-left"></span>
          <span class="bow-loop bow-right"></span>
          <span class="bow-knot"></span>
          <span class="bow-tail bow-tail-left"></span>
          <span class="bow-tail bow-tail-right"></span>
        </span>
      </span>
      <span class="seal" aria-hidden="true">S <span>&</span> M</span>
    </button>
  </div>
{/if}

<style>
  .intro {
    position: fixed;
    inset: 0;
    z-index: 100;
    display: grid;
    place-items: center;
    overflow: hidden;
    background:
      radial-gradient(ellipse at center, rgb(255 255 255 / 82%), transparent 68%),
      #f5f0e7;
    transition: opacity 700ms ease, visibility 700ms ease;
  }

  .intro.opening {
    opacity: 0;
    visibility: hidden;
  }

  .envelope-button {
    position: relative;
    display: grid;
    width: min(86vw, 460px);
    justify-items: center;
    padding: 3rem 0;
    color: var(--color-text);
    background: transparent;
    border: 0;
    cursor: pointer;
    -webkit-tap-highlight-color: transparent;
  }

  .envelope-button:focus-visible {
    outline: 2px solid var(--color-primary-dark);
    outline-offset: 12px;
  }

  .hint {
    margin-bottom: 1.6rem;
    color: var(--color-text-muted);
    font-size: 0.65rem;
    letter-spacing: 0.28em;
    text-transform: uppercase;
    animation: breathe 2.4s ease-in-out infinite;
  }

  .envelope {
    position: relative;
    display: block;
    width: 100%;
    aspect-ratio: 1.55;
    filter: drop-shadow(0 18px 24px rgb(66 49 35 / 15%));
    perspective: 900px;
  }

  .envelope-back,
  .envelope-front,
  .envelope-flap {
    position: absolute;
    inset: 0;
  }

  .envelope-back {
    background: #e9dfd0;
    border: 1px solid #d3c4af;
    border-radius: 3px;
  }

  .letter {
    position: absolute;
    z-index: 1;
    inset: 7% 10% 3%;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 0.65rem;
    background: #fffdf8;
    border: 1px solid #e9dfd0;
    transition: transform 850ms cubic-bezier(0.2, 0.75, 0.25, 1) 250ms;
  }

  .letter-kicker,
  .letter-date {
    color: var(--color-text-muted);
    font-size: clamp(0.45rem, 2vw, 0.62rem);
    letter-spacing: 0.2em;
    text-transform: uppercase;
  }

  .letter-names {
    color: var(--color-accent);
    font-family: var(--font-script);
    font-size: clamp(1.5rem, 7vw, 2.5rem);
  }

  .envelope-front {
    z-index: 3;
    background: linear-gradient(145deg, transparent 49.8%, #dfd2c0 50%);
    clip-path: polygon(0 0, 50% 52%, 100% 0, 100% 100%, 0 100%);
  }

  .envelope-front::before {
    position: absolute;
    inset: 0;
    content: "";
    background: linear-gradient(35deg, #eee5d9 50%, transparent 50.4%);
    clip-path: polygon(0 0, 0 100%, 100% 100%);
  }

  .envelope-front::after {
    position: absolute;
    inset: 0;
    content: "";
    background: linear-gradient(-35deg, #e9dfd0 50%, transparent 50.4%);
    clip-path: polygon(100% 0, 100% 100%, 0 100%);
  }

  .envelope-flap {
    z-index: 4;
    background: #f0e7db;
    clip-path: polygon(0 0, 100% 0, 50% 57%);
    transform-origin: top;
    transition: transform 650ms ease, z-index 0ms 325ms;
  }

  .ribbon {
    position: absolute;
    z-index: 5;
    display: block;
    background: #a96961;
    box-shadow: inset 0 0 0 1px rgb(255 255 255 / 16%);
    transition: opacity 300ms ease;
  }

  .ribbon-vertical {
    inset: 0 46% 0;
  }

  .ribbon-horizontal {
    inset: 42% 0 auto;
    height: 13%;
  }

  .bow {
    position: absolute;
    z-index: 6;
    top: 28%;
    left: 50%;
    width: 92px;
    height: 66px;
    transform: translateX(-50%);
    transition: transform 400ms ease, opacity 300ms ease;
  }

  .bow-loop {
    position: absolute;
    top: 5px;
    width: 39px;
    height: 28px;
    border: 7px solid #a96961;
    border-radius: 60% 45% 60% 45%;
  }

  .bow-left {
    left: 6px;
    transform: rotate(25deg);
  }

  .bow-right {
    right: 6px;
    transform: rotate(-25deg) scaleX(-1);
  }

  .bow-knot {
    position: absolute;
    top: 15px;
    left: 39px;
    width: 15px;
    height: 15px;
    background: #a96961;
    border-radius: 50%;
  }

  .bow-tail {
    position: absolute;
    top: 29px;
    width: 13px;
    height: 30px;
    background: #a96961;
    clip-path: polygon(0 0, 100% 0, 100% 100%, 50% 78%, 0 100%);
  }

  .bow-tail-left {
    left: 31px;
    transform: rotate(20deg);
  }

  .bow-tail-right {
    right: 31px;
    transform: rotate(-20deg);
  }

  .seal {
    position: absolute;
    z-index: 7;
    top: 54%;
    left: 50%;
    display: grid;
    width: 48px;
    height: 48px;
    place-items: center;
    color: #fff8ee;
    font-family: var(--font-display);
    font-size: 0.9rem;
    background: #a96961;
    border: 2px solid #f1d5c8;
    border-radius: 50%;
    box-shadow: 0 2px 6px rgb(60 39 31 / 18%);
    transform: translate(-50%, -50%);
    transition: opacity 250ms ease, transform 250ms ease;
  }

  .seal span {
    margin: 0 2px;
    font-family: var(--font-script);
  }

  .opening .envelope-flap {
    z-index: 0;
    transform: rotateX(180deg);
  }

  .opening .letter {
    transform: translateY(-72%);
  }

  .opening .ribbon,
  .opening .bow,
  .opening .seal,
  .opening .hint {
    opacity: 0;
  }

  .opening .bow {
    transform: translate(-50%, -20px) scale(0.8);
  }

  @keyframes breathe {
    50% { opacity: 0.55; }
  }

  @media (prefers-reduced-motion: reduce) {
    .intro,
    .letter,
    .envelope-flap,
    .ribbon,
    .bow,
    .seal,
    .hint {
      transition-duration: 1ms;
      animation-duration: 1ms;
      animation-iteration-count: 1;
    }
  }
</style>
