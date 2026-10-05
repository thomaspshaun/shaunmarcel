<script lang="ts">
  import { onMount } from "svelte";
  import { fetchGalleryPhotos, type GalleryPhoto } from "$lib/supabase";

  let photos = $state<GalleryPhoto[]>([]);
  let loading = $state(true);
  let loadError = $state("");
  let activeIndex = $state<number | null>(null);

  onMount(load);

  async function load() {
    loading = true;
    loadError = "";
    try {
      photos = await fetchGalleryPhotos();
    } catch (err) {
      loadError = err instanceof Error ? err.message : "Could not load the gallery.";
    } finally {
      loading = false;
    }
  }

  function openLightbox(index: number) {
    activeIndex = index;
  }

  function closeLightbox() {
    activeIndex = null;
  }

  function showPrev() {
    if (activeIndex === null) return;
    activeIndex = (activeIndex - 1 + photos.length) % photos.length;
  }

  function showNext() {
    if (activeIndex === null) return;
    activeIndex = (activeIndex + 1) % photos.length;
  }

  function handleKeydown(event: KeyboardEvent) {
    if (activeIndex === null) return;
    if (event.key === "Escape") closeLightbox();
    if (event.key === "ArrowLeft") showPrev();
    if (event.key === "ArrowRight") showNext();
  }
</script>

<svelte:window onkeydown={handleKeydown} />

<section id="gallery" class="mx-auto max-w-5xl px-6 py-20">
  <div class="text-center">
    <p class="eyebrow">
      A Few of Our Favorites
    </p>
    <h2 class="heading mt-4">
      Photo Gallery
    </h2>
    <p class="lede mx-auto mt-5 max-w-md">
      Some of our favorite moments together, ahead of the big day.
    </p>
  </div>

  {#if loading}
    <p class="mt-12 text-center text-sm text-muted">Loading photos…</p>
  {:else if loadError}
    <p class="mt-12 text-center text-sm text-sage-dark">{loadError}</p>
  {:else if photos.length === 0}
    <p class="mt-12 text-center text-sm text-muted">Photos coming soon.</p>
  {:else}
    <div class="mt-12 grid grid-cols-2 gap-3 sm:grid-cols-3 md:gap-4 lg:grid-cols-4">
      {#each photos as photo, index (photo.id)}
        <button
          type="button"
          onclick={() => openLightbox(index)}
          class="group aspect-square overflow-hidden rounded-none bg-paper-2"
        >
          <img
            src={photo.url}
            alt={photo.caption ?? "Wedding gallery photo"}
            loading="lazy"
            class="h-full w-full object-cover transition duration-300 group-hover:scale-105"
          />
        </button>
      {/each}
    </div>
  {/if}
</section>

{#if activeIndex !== null && photos[activeIndex]}
  <div
    class="fixed inset-0 z-50 flex items-center justify-center bg-ink/90 p-4"
    onclick={closeLightbox}
    role="dialog"
    aria-modal="true"
  >
    <button
      type="button"
      onclick={closeLightbox}
      aria-label="Close"
      class="absolute top-4 right-4 text-3xl leading-none text-surface/80 hover:text-surface"
    >
      &times;
    </button>

    {#if photos.length > 1}
      <button
        type="button"
        onclick={(e) => {
          e.stopPropagation();
          showPrev();
        }}
        aria-label="Previous photo"
        class="absolute left-2 text-3xl text-surface/80 hover:text-surface sm:left-6"
      >
        &#8249;
      </button>
      <button
        type="button"
        onclick={(e) => {
          e.stopPropagation();
          showNext();
        }}
        aria-label="Next photo"
        class="absolute right-2 text-3xl text-surface/80 hover:text-surface sm:right-6"
      >
        &#8250;
      </button>
    {/if}

    <img
      src={photos[activeIndex].url}
      alt={photos[activeIndex].caption ?? "Wedding gallery photo"}
      onclick={(e) => e.stopPropagation()}
      class="max-h-[85vh] max-w-full rounded-none object-contain"
    />
  </div>
{/if}
