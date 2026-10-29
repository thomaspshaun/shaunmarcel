<script lang="ts">
  const photo = '/save-the-date-photo.png';
</script>

<svelte:head>
  <title>Save the Date — Shaun &amp; Marcel</title>
  <meta name="description" content="Save the date: Shaun and Marcel, 1 April 2027." />
  <meta property="og:title" content="Save the Date — Shaun &amp; Marcel" />
  <meta property="og:description" content="Thursday, 1 April 2027" />
  <meta property="og:image" content={photo} />
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
  <link
    href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,400;0,500;0,600;1,400&family=Parisienne&display=swap"
    rel="stylesheet"
  />
</svelte:head>

<main class="save-date">
  <div class="backdrop" style:background-image={`url("${photo}")`} aria-hidden="true"></div>
  <img class="photo" src={photo} alt="Shaun and Marcel sharing a playful moment in their wedding attire" />
  <div class="shade" aria-hidden="true"></div>

  <section class="card" aria-label="Save the date">
    <p class="save-title">Save the Date</p>
    <h1 class="couple">Shaun <span>&amp;</span> Marcel</h1>
    <div class="details">
      <p class="date"><span>Thursday</span><strong>1</strong><span>April 2027</span></p>
      <footer class="contact">
        Questions in the meantime? Reach us at
        <a href="tel:+27836338108">083 633 8108</a>
      </footer>
    </div>
  </section>
</main>

<style>
  .save-date {
    position: relative;
    display: grid;
    width: 100%;
    height: 100vh;
    height: 100svh;
    min-height: 100%;
    overflow: hidden;
    place-items: center;
    isolation: isolate;
    color: #fffdf9;
    background: #30251f;
  }

  .backdrop,
  .photo,
  .shade {
    position: absolute;
    inset: 0;
    width: 100%;
    height: 100%;
  }

  .backdrop {
    z-index: -3;
    background-position: center;
    background-size: cover;
    filter: blur(18px) brightness(0.55) saturate(0.9);
    transform: scale(1.08);
  }

  .photo {
    z-index: -2;
    object-fit: cover;
    object-position: center 50%;
    filter: contrast(1.04) saturate(1.04);
  }

  .shade {
    z-index: -1;
    background: linear-gradient(
      180deg,
      rgb(24 19 16 / 12%) 0%,
      transparent 30%,
      transparent 54%,
      rgb(24 19 16 / 12%) 68%,
      rgb(24 19 16 / 66%) 100%
    );
  }

  .card {
    position: absolute;
    inset: 0;
    padding: 0 1rem;
    text-align: center;
    pointer-events: none;
  }

  .save-title,
  .couple,
  .date,
  .contact {
    margin: 0;
    opacity: 0;
    animation: rise-in 1.15s cubic-bezier(0.2, 0.7, 0.2, 1) forwards;
  }

  .save-title {
    position: absolute;
    top: 35%;
    left: 0;
    width: 100%;
    color: #fffdf9;
    font-family: "Parisienne", "Brush Script MT", cursive;
    font-size: clamp(3.4rem, 11vw, 8rem);
    line-height: 0.94;
    -webkit-text-stroke: 0.65px #77736f;
    paint-order: stroke fill;
    text-shadow: 0 2px 8px rgb(0 0 0 / 55%);
    animation-delay: 350ms;
  }

  .couple {
    position: absolute;
    top: 76%;
    left: 0;
    width: 100%;
    color: #fffdf9;
    font-family: "Cormorant Garamond", Georgia, serif;
    font-size: clamp(2.15rem, 7.2vw, 5rem);
    font-weight: 500;
    letter-spacing: 0.025em;
    line-height: 1;
    -webkit-text-stroke: 0.45px #77736f;
    paint-order: stroke fill;
    text-shadow: 0 2px 8px rgb(0 0 0 / 75%);
    animation-delay: 850ms;
  }

  .couple span {
    color: #f2dfbd;
    font-style: italic;
  }

  .date {
    position: absolute;
    right: 0;
    bottom: max(8%, calc(env(safe-area-inset-bottom) + 4.5rem));
    left: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: clamp(0.6rem, 3.2vw, 2rem);
    font-family: "Cormorant Garamond", Georgia, serif;
    -webkit-text-stroke: 0.3px #77736f;
    paint-order: stroke fill;
    text-shadow: 0 2px 8px rgb(0 0 0 / 80%);
    animation-delay: 1.25s;
  }

  .date span {
    font-size: clamp(1rem, 3.5vw, 1.8rem);
    font-weight: 600;
  }

  .date strong {
    color: #fffdf9;
    font-size: clamp(1rem, 3.5vw, 1.8rem);
    font-variant-numeric: lining-nums;
    font-weight: 600;
    line-height: 1;
  }

  .details {
    display: contents;
  }

  .contact {
    position: absolute;
    right: 1rem;
    bottom: max(1.5%, env(safe-area-inset-bottom));
    left: 1rem;
    color: #fffdf9;
    font-family: Arial, Helvetica, sans-serif;
    font-size: clamp(0.72rem, 2.5vw, 0.95rem);
    line-height: 1.5;
    text-shadow: 0 1px 5px rgb(0 0 0 / 85%);
    animation-delay: 1.55s;
  }

  .contact a {
    color: inherit;
    font-weight: 600;
    text-decoration: underline;
    text-underline-offset: 0.18em;
    pointer-events: auto;
  }

  @keyframes rise-in {
    from {
      opacity: 0;
      transform: translateY(28px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  @media (min-width: 700px) {
    .photo {
      width: auto;
      max-width: 100%;
      margin: auto;
      object-fit: contain;
      filter: contrast(1.04) saturate(1.04);
    }

    .save-title {
      top: 35%;
    }

    .couple {
      top: 76%;
    }
  }

  @media (prefers-reduced-motion: reduce) {
    .save-title,
    .couple,
    .date,
    .contact {
      opacity: 1;
      animation: none;
    }
  }
</style>
