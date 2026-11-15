<script lang="ts">
  const paletteColors = ['Cream', 'Taupe', 'Mocca', 'Sage Green', 'Soft White', 'Brown'];
</script>

<section
  id="colors"
  class="palette-section border-y border-taupe/60 bg-paper-2/75 px-4 py-8 sm:px-6 sm:py-24"
  aria-labelledby="wedding-colors-heading"
>
  <div class="mx-auto max-w-6xl text-center">
    <p class="eyebrow">The Details</p>
    <h2 id="wedding-colors-heading" class="heading mt-2 text-2xl sm:mt-4 sm:text-5xl">
      A palette for the day
    </h2>
    <p class="palette-description lede mx-auto mt-2 max-w-lg text-xs leading-5 sm:mt-4 sm:text-base sm:leading-[1.85]">
      A little look at the colors and textures chosen for our celebration.
    </p>

    <figure
      class="mx-auto mt-4 max-w-5xl overflow-hidden border border-taupe/70 bg-surface p-1 shadow-[0_16px_50px_rgba(73,59,48,0.12)] sm:mt-12 sm:p-3"
    >
      <img
        src="/wedding-colors-strip.png"
        alt="Shaun and Marcel's wedding colors: cream, taupe, mocca, sage green, soft white, and brown."
        class="palette-desktop h-auto w-full"
        loading="lazy"
        decoding="async"
      />
      <div class="palette-mobile grid grid-cols-3 gap-2 sm:hidden" aria-label="Wedding color swatches">
        {#each paletteColors as color, index (color)}
          <div
            class="palette-swatch"
            role="img"
            aria-label={color}
            style={`background-position: ${index * 20}% center`}
          ></div>
        {/each}
      </div>
    </figure>
  </div>
</section>

<style>
  .palette-description {
    display: none;
  }

  @media (max-width: 39.999rem) {
    .palette-section {
      min-height: 50svh;
    }
  }

  @media (min-width: 40rem) {
    .palette-description {
      display: block;
    }
  }

  .palette-desktop {
    display: none;
  }

  @media (min-width: 40rem) {
    .palette-desktop {
      display: block;
    }

    .palette-mobile {
      display: none;
    }
  }

  .palette-swatch {
    aspect-ratio: 157 / 204;
    background-image: url('/wedding-colors-strip.png');
    background-repeat: no-repeat;
    background-size: 600% 100%;
  }
</style>
