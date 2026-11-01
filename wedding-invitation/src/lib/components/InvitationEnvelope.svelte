<script lang="ts">
  import { site } from '$lib/site-config';

  let isOpening = $state(false);
  let isDismissed = $state(false);

  function openInvitation() {
    if (isOpening) return;
    isOpening = true;
    const duration = window.matchMedia('(prefers-reduced-motion: reduce)').matches ? 0 : 4300;
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
        <span class="engraving" aria-hidden="true">
          <span>{site.names[0].charAt(0)}</span><span class="engraving-ampersand">&</span><span>{site.names[1].charAt(0)}</span>
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
    transition-delay: 3600ms, 4250ms;
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
      z-index 0ms linear 1700ms,
      transform 1400ms cubic-bezier(0.22, 0.72, 0.22, 1) 1700ms,
      box-shadow 900ms ease 1700ms;
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
      transform 1200ms cubic-bezier(0.22, 0.72, 0.22, 1) 500ms,
      z-index 0ms linear 1050ms;
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

  .opening .hint {
    opacity: 0;
  }

  @keyframes breathe {
    50% { opacity: 0.55; }
  }

  @media (prefers-reduced-motion: reduce) {
    .intro,
    .letter,
    .envelope-flap,
    .hint {
      transition-duration: 1ms;
      transition-delay: 0ms;
      animation-duration: 1ms;
      animation-iteration-count: 1;
    }
  }
</style>
