<script lang="ts">
  import { site } from '$lib/site-config';

  let isOpening = $state(false);
  let isDismissed = $state(false);

  function openInvitation() {
    if (isOpening) return;
    isOpening = true;
    const duration = window.matchMedia('(prefers-reduced-motion: reduce)').matches ? 0 : 5800;
    window.setTimeout(() => (isDismissed = true), duration);
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
      <span class="hint">Tap to untie</span>
      <span class="envelope">
        <span class="letter">
          <span class="letter-kicker">Together with their families</span>
          <span class="letter-names">{site.coupleNames}</span>
          <span class="letter-date">{site.weddingDateLabel}</span>
        </span>
        <span class="envelope-back"></span>
        <span class="envelope-flap"></span>
        <span class="envelope-front"></span>
        <span class="engraving" aria-hidden="true">
          <span>{site.names[0].charAt(0)}</span><span class="engraving-ampersand">&</span><span>{site.names[1].charAt(0)}</span>
        </span>
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
      var(--color-background-secondary);
    transition: opacity 700ms ease, visibility 700ms ease;
  }

  .intro.opening {
    opacity: 0;
    visibility: hidden;
    transition-delay: 5100ms, 5750ms;
  }

  .envelope-button {
    position: absolute;
    inset: 0;
    display: grid;
    width: 100%;
    height: 100%;
    justify-items: center;
    align-content: center;
    padding: 0;
    color: var(--color-text);
    background: transparent;
    border: 0;
    cursor: pointer;
    appearance: none;
    -webkit-appearance: none;
    touch-action: manipulation;
    -webkit-tap-highlight-color: transparent;
  }

  .envelope-button:focus-visible {
    outline: 2px solid var(--color-primary-dark);
    outline-offset: 12px;
  }

  .hint {
    position: absolute;
    z-index: 10;
    top: max(2rem, env(safe-area-inset-top));
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
    width: min(88vw, 620px);
    aspect-ratio: 7 / 5;
    filter: drop-shadow(0 22px 32px rgb(66 49 35 / 18%));
    perspective: 900px;
    -webkit-perspective: 900px;
  }

  .envelope-back,
  .envelope-front,
  .envelope-flap {
    position: absolute;
    inset: 0;
  }

  .envelope-back {
    z-index: 1;
    overflow: hidden;
    background:
      repeating-linear-gradient(112deg, rgb(92 70 45 / 2%) 0 1px, transparent 1px 4px),
      radial-gradient(ellipse at 50% 30%, rgb(255 255 255 / 82%), transparent 76%),
      var(--color-border);
    border: 1px solid rgb(128 92 55 / 26%);
    border-radius: 12px;
    box-shadow:
      inset 0 1px 0 rgb(255 255 255 / 72%),
      inset 0 -12px 28px rgb(110 80 48 / 10%);
  }

  .letter {
    position: absolute;
    z-index: 0;
    inset: 5% 8% 0;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 0.65rem;
    background: var(--color-background);
    border: 1px solid var(--color-border);
    box-shadow: 0 5px 18px rgb(68 53 35 / 14%);
    transition:
      z-index 0ms linear 3500ms,
      transform 1300ms cubic-bezier(0.22, 0.72, 0.22, 1) 3500ms,
      box-shadow 900ms ease 3500ms;
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
    background:
      repeating-linear-gradient(112deg, rgb(92 70 45 / 2%) 0 1px, transparent 1px 4px),
      linear-gradient(145deg, transparent 49.8%, #d8bd99 50%);
    clip-path: polygon(0 0, 50% 52%, 100% 0, 100% 100%, 0 100%);
  }

  .envelope-front::before {
    position: absolute;
    inset: 0;
    content: "";
    background:
      repeating-linear-gradient(112deg, rgb(92 70 45 / 2%) 0 1px, transparent 1px 4px),
      linear-gradient(35deg, #fff8df 50%, transparent 50.4%);
    clip-path: polygon(0 0, 0 100%, 100% 100%);
  }

  .envelope-front::after {
    position: absolute;
    inset: 0;
    content: "";
    background:
      repeating-linear-gradient(112deg, rgb(92 70 45 / 2%) 0 1px, transparent 1px 4px),
      linear-gradient(-35deg, #f4e8c9 50%, transparent 50.4%);
    clip-path: polygon(100% 0, 100% 100%, 0 100%);
  }

  .envelope-flap {
    z-index: 4;
    background:
      repeating-linear-gradient(112deg, rgb(92 70 45 / 2%) 0 1px, transparent 1px 4px),
      linear-gradient(135deg, #fff9e5, #e8d4b3);
    clip-path: polygon(0 0, 100% 0, 50% 57%);
    transform-origin: top;
    -webkit-transform-origin: top;
    backface-visibility: hidden;
    -webkit-backface-visibility: hidden;
    transition:
      transform 1100ms cubic-bezier(0.22, 0.72, 0.22, 1) 2400ms,
      z-index 0ms linear 2950ms;
  }

  .ribbon {
    position: absolute;
    z-index: 5;
    display: block;
    background: var(--color-primary);
    box-shadow: inset 0 0 0 1px rgb(255 255 255 / 16%);
    transition:
      transform 1200ms cubic-bezier(0.22, 0.72, 0.22, 1) 1300ms,
      opacity 400ms ease 2400ms;
  }

  .ribbon-vertical {
    inset: 0 47% 0;
  }

  .ribbon-horizontal {
    inset: 47% 0 auto;
    height: 8%;
  }

  .bow {
    position: absolute;
    z-index: 6;
    top: 43%;
    left: 50%;
    width: clamp(110px, 28vw, 190px);
    height: clamp(78px, 19vw, 130px);
    transform: translateX(-50%);
    transition:
      transform 1200ms cubic-bezier(0.22, 0.72, 0.22, 1) 200ms,
      opacity 400ms ease 1450ms;
  }

  .bow-loop {
    position: absolute;
    top: 6%;
    width: 43%;
    height: 47%;
    border: clamp(7px, 1.8vw, 12px) solid var(--color-primary);
    border-radius: 60% 45% 60% 45%;
    transition: transform 1000ms cubic-bezier(0.22, 0.72, 0.22, 1) 350ms;
  }

  .bow-left {
    left: 3%;
    transform: rotate(25deg);
  }

  .bow-right {
    right: 3%;
    transform: rotate(-25deg) scaleX(-1);
  }

  .bow-knot {
    position: absolute;
    top: 28%;
    left: 43%;
    width: 16%;
    height: 22%;
    background: var(--color-primary);
    border-radius: 50%;
    transition: transform 850ms cubic-bezier(0.22, 0.72, 0.22, 1) 450ms;
  }

  .bow-tail {
    position: absolute;
    top: 43%;
    width: 14%;
    height: 47%;
    background: var(--color-primary);
    clip-path: polygon(0 0, 100% 0, 100% 100%, 50% 78%, 0 100%);
    transition: transform 950ms cubic-bezier(0.22, 0.72, 0.22, 1) 450ms;
  }

  .bow-tail-left {
    left: 33%;
    transform: rotate(20deg);
  }

  .bow-tail-right {
    right: 33%;
    transform: rotate(-20deg);
  }

  .engraving {
    position: absolute;
    z-index: 4;
    bottom: 10%;
    left: 12%;
    color: rgb(166 124 82 / 82%);
    font-family: var(--font-display);
    font-size: clamp(1.15rem, 3vw, 1.65rem);
    font-style: italic;
    letter-spacing: -0.08em;
    line-height: 1;
    text-shadow:
      0 1px 0 rgb(255 255 255 / 78%),
      0 -1px 0 rgb(95 68 42 / 24%);
  }

  .engraving-ampersand {
    margin: 0 0.08em;
    font-size: 0.62em;
    vertical-align: 0.16em;
  }

  .opening .envelope-flap {
    z-index: 0;
    transform: rotateX(180deg);
  }

  .opening .letter {
    z-index: 30;
    transform: translateY(-102%);
    box-shadow: 0 24px 42px rgb(68 53 35 / 22%);
  }

  .opening .ribbon-vertical {
    transform: translateY(115%);
  }

  .opening .ribbon-horizontal {
    transform: translateX(110%);
  }

  .opening .bow-loop.bow-left {
    transform: rotate(-42deg) translate(-18px, -16px) scale(0.78);
  }

  .opening .bow-loop.bow-right {
    transform: rotate(42deg) translate(18px, -16px) scale(0.78);
  }

  .opening .bow-tail-left {
    transform: rotate(65deg) translateY(24px);
  }

  .opening .bow-tail-right {
    transform: rotate(-65deg) translateY(24px);
  }

  .opening .bow,
  .opening .hint {
    opacity: 0;
  }

  .opening .bow {
    transform: translate(-50%, -22px) scale(0.9);
  }

  .opening .bow-knot {
    transform: scale(0.7);
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
    .bow-loop,
    .bow-tail,
    .hint {
      transition-duration: 1ms;
      transition-delay: 0ms;
      animation-duration: 1ms;
      animation-iteration-count: 1;
    }
  }
</style>
