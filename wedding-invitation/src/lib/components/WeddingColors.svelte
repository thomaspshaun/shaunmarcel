<script lang="ts">
  const paletteColors = [
    {
      name: 'Sage Green',
      hex: '#B0C4B1',
      image: '/palette-items/sage-green.png',
      description: 'For fresh elegance & natural textures'
    },
    {
      name: 'Dusty Rose',
      hex: '#DCAE96',
      image: '/palette-items/dusty-rose.png',
      description: 'For soft romance & warm highlights'
    },
    {
      name: 'Charcoal Grey',
      hex: '#36454F',
      image: '/palette-items/charcoal-grey.png',
      description: 'For modern grounding & clean lines'
    },
    {
      name: 'Terra Cotta',
      hex: '#C07050',
      image: '/palette-items/terra-cotta.png',
      description: 'For warm texture & ceramic elements'
    },
    {
      name: 'Golden Mustard',
      hex: '#E1B64F',
      image: '/palette-items/golden-mustard.png',
      description: 'For bright pops & dried flower bursts'
    }
  ];
</script>

<section
  id="colors"
  class="palette-section border-y border-taupe/60 bg-paper-2/75 px-4 py-8 sm:px-6 sm:py-20"
  aria-labelledby="wedding-colors-heading"
>
  <div class="mx-auto w-full max-w-6xl text-center">
    <p class="eyebrow">The Details</p>
    <h2 id="wedding-colors-heading" class="heading mt-2 text-2xl sm:mt-4 sm:text-5xl">
      A palette for the day
    </h2>
    <p class="lede mx-auto mt-2 max-w-lg text-xs leading-5 sm:mt-4 sm:text-base sm:leading-[1.85]">
      A little look at the colors and textures chosen for our celebration.
    </p>

    <ul class="palette-grid mx-auto mt-5 grid max-w-5xl grid-cols-3 gap-x-2 gap-y-4 sm:mt-10 sm:grid-cols-3 sm:gap-x-6 sm:gap-y-8 lg:grid-cols-5">
      {#each paletteColors as color (color.name)}
        <li class="palette-card">
          <img
            src={color.image}
            alt=""
            class="palette-image"
            loading="lazy"
            decoding="async"
            aria-hidden="true"
          />
          <h3 class="palette-name">{color.name}</h3>
          <p class="palette-hex">{color.hex}</p>
          <p class="palette-use">{color.description}</p>
        </li>
      {/each}
    </ul>
  </div>
</section>

<style>
  .palette-section {
    min-height: 50svh;
  }

  .palette-card {
    display: flex;
    min-width: 0;
    flex-direction: column;
    align-items: center;
    gap: 0.25rem;
  }

  .palette-image {
    width: clamp(2.5rem, 11vw, 5.5rem);
    aspect-ratio: 1;
    object-fit: cover;
    border: 1px solid rgb(73 59 48 / 12%);
    border-radius: 50%;
    box-shadow: 0 4px 14px rgb(73 59 48 / 10%);
  }

  .palette-name {
    margin-top: 0.4rem;
    color: var(--color-text);
    font-family: var(--font-display);
    font-size: clamp(0.65rem, 2.5vw, 1rem);
    font-weight: 500;
    letter-spacing: 0.08em;
    line-height: 1.2;
    text-transform: uppercase;
  }

  .palette-hex {
    color: var(--color-text-muted);
    font-family: var(--font-body);
    font-size: 0.65rem;
    letter-spacing: 0.06em;
  }

  .palette-use {
    display: none;
  }

  @media (max-width: 63.999rem) {
    .palette-grid {
      grid-template-columns: repeat(6, minmax(0, 1fr));
    }

    .palette-card {
      grid-column: span 2;
    }

    .palette-card:nth-child(4) {
      grid-column: 2 / span 2;
    }

    .palette-card:nth-child(5) {
      grid-column: 4 / span 2;
    }
  }

  @media (min-width: 40rem) {
    .palette-section {
      min-height: 0;
    }

    .palette-card {
      gap: 0.45rem;
    }

    .palette-image {
      width: clamp(4rem, 8vw, 7rem);
    }

    .palette-name {
      margin-top: 0.75rem;
      font-size: clamp(0.8rem, 1.3vw, 1.1rem);
    }

    .palette-hex {
      font-size: 0.8rem;
    }

    .palette-use {
      display: block;
      max-width: 13rem;
      color: var(--color-text-muted);
      font-family: var(--font-body);
      font-size: 0.82rem;
      line-height: 1.6;
    }
  }
</style>
