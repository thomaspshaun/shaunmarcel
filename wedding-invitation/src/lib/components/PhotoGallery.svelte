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
    <p class="text-xs font-semibold uppercase tracking-[0.4em] text-rose-500 sm:text-sm">
      A Few of Our Favorites
    </p>
    <h2 class="mt-4 text-3xl font-light tracking-tight text-slate-900 sm:text-4xl">
      Photo Gallery
    </h2>
    <p class="mx-auto mt-3 max-w-xl text-base text-slate-600">
      Some of our favorite moments together, ahead of the big day.
    </p>
  </div>

  {#if loading}
    <p class="mt-12 text-center text-sm text-slate-500">Loading photos…</p>
  {:else if loadError}
    <p class="mt-12 text-center text-sm text-rose-500">{loadError}</p>
  {:else if photos.length === 0}
    <p class="mt-12 text-center text-sm text-slate-500">Photos coming soon.</p>
  {:else}
    <div class="mt-12 grid grid-cols-2 gap-3 sm:grid-cols-3 md:gap-4 lg:grid-cols-4">
      {#each photos as photo, index (photo.id)}
        <button
          type="button"
          onclick={() => openLightbox(index)}
          class="group aspect-square overflow-hidden rounded-xl bg-slate-100"
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
    class="fixed inset-0 z-50 flex items-center justify-center bg-black/90 p-4"
    onclick={closeLightbox}
    role="dialog"
    aria-modal="true"
  >
    <button
      type="button"
      onclick={closeLightbox}
      aria-label="Close"
      class="absolute top-4 right-4 text-3xl leading-none text-white/80 hover:text-white"
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
        class="absolute left-2 text-3xl text-white/70 hover:text-white sm:left-6"
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
        class="absolute right-2 text-3xl text-white/70 hover:text-white sm:right-6"
      >
        &#8250;
      </button>
    {/if}

    <img
      src={photos[activeIndex].url}
      alt={photos[activeIndex].caption ?? "Wedding gallery photo"}
      onclick={(e) => e.stopPropagation()}
      class="max-h-[85vh] max-w-full rounded-lg object-contain"
    />
  </div>
{/if}
