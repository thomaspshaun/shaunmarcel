<script lang="ts">
  import { onMount } from "svelte";
  import { fetchGuestPhotos, uploadGuestPhoto, type GuestPhoto } from "$lib/supabase";

  let photos = $state<GuestPhoto[]>([]);
  let loading = $state(true);
  let loadError = $state("");

  let uploaderName = $state("");
  let caption = $state("");
  let selectedFiles = $state<File[]>([]);
  let uploading = $state(false);
  let uploadError = $state("");
  let uploadedCount = $state(0);
  let activeIndex = $state<number | null>(null);

  onMount(load);

  async function load() {
    loading = true;
    loadError = "";
    try {
      photos = await fetchGuestPhotos();
    } catch (err) {
      loadError = err instanceof Error ? err.message : "Could not load guest photos.";
    } finally {
      loading = false;
    }
  }

  function handleFileChange(event: Event) {
    const input = event.target as HTMLInputElement;
    selectedFiles = input.files ? Array.from(input.files) : [];
  }

  async function handleUpload(event: SubmitEvent) {
    event.preventDefault();
    if (selectedFiles.length === 0) {
      uploadError = "Please choose at least one photo to upload.";
      return;
    }

    uploading = true;
    uploadError = "";
    uploadedCount = 0;

    try {
      for (const file of selectedFiles) {
        await uploadGuestPhoto(file, uploaderName.trim(), caption.trim());
        uploadedCount += 1;
      }
      selectedFiles = [];
      caption = "";
      const fileInput = document.getElementById("guest-photo-input") as HTMLInputElement | null;
      if (fileInput) fileInput.value = "";
      await load();
    } catch (err) {
      uploadError = err instanceof Error ? err.message : "Upload failed. Please try again.";
    } finally {
      uploading = false;
    }
  }

  function openLightbox(index: number) {
    activeIndex = index;
  }

  function closeLightbox() {
    activeIndex = null;
  }
</script>

<section id="guest-photos" class="mx-auto max-w-5xl px-6 py-20">
  <div class="text-center">
    <p class="eyebrow">
      Share the Memories
    </p>
    <h2 class="heading mt-4">
      Guest Photos
    </h2>
    <p class="lede mx-auto mt-5 max-w-md">
      Snapped a photo on the day? Upload it here so we can all enjoy it together. Max 8MB per
      photo — JPG, PNG, WEBP, or HEIC.
    </p>
  </div>

  <form
    onsubmit={handleUpload}
    class="mx-auto mt-10 max-w-xl border border-line bg-surface p-6"
  >
    <label class="block text-sm">
      <span class="font-medium text-ink">Your name (optional)</span>
      <input
        type="text"
        bind:value={uploaderName}
        maxlength="80"
        class="mt-1 w-full rounded-none border border-line px-3 py-2 text-sm focus:border-sage focus:outline-none"
      />
    </label>

    <label class="mt-4 block text-sm">
      <span class="font-medium text-ink">Caption (optional)</span>
      <input
        type="text"
        bind:value={caption}
        maxlength="160"
        class="mt-1 w-full rounded-none border border-line px-3 py-2 text-sm focus:border-sage focus:outline-none"
      />
    </label>

    <label class="mt-4 block text-sm">
      <span class="font-medium text-ink">Photo(s)</span>
      <input
        id="guest-photo-input"
        type="file"
        accept="image/*"
        multiple
        onchange={handleFileChange}
        class="mt-1 w-full rounded-none border border-line px-3 py-2 text-sm file:mr-3 file:border-0 file:bg-paper-2 file:px-4 file:py-1.5 file:text-sm file:font-medium file:text-sage-dark focus:border-sage focus:outline-none"
      />
    </label>

    {#if uploadError}
      <p class="mt-3 text-sm text-sage-dark">{uploadError}</p>
    {/if}
    {#if uploadedCount > 0 && !uploadError}
      <p class="mt-3 text-sm text-sage-dark">
        Uploaded {uploadedCount} photo{uploadedCount === 1 ? "" : "s"} — thank you!
      </p>
    {/if}

    <button
      type="submit"
      disabled={uploading}
      class="mt-5 btn w-full disabled:cursor-not-allowed disabled:opacity-60"
    >
      {uploading ? "Uploading…" : "Upload Photo(s)"}
    </button>
  </form>

  {#if loading}
    <p class="mt-12 text-center text-sm text-muted">Loading guest photos…</p>
  {:else if loadError}
    <p class="mt-12 text-center text-sm text-sage-dark">{loadError}</p>
  {:else if photos.length === 0}
    <p class="mt-12 text-center text-sm text-muted">No guest photos yet — be the first!</p>
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
            alt={photo.caption ?? "Guest photo"}
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
    <div class="flex max-w-full flex-col items-center" onclick={(e) => e.stopPropagation()}>
      <img
        src={photos[activeIndex].url}
        alt={photos[activeIndex].caption ?? "Guest photo"}
        class="max-h-[75vh] max-w-full rounded-none object-contain"
      />
      {#if photos[activeIndex].caption || photos[activeIndex].uploader_name}
        <p class="mt-3 text-center text-sm text-surface/80">
          {photos[activeIndex].caption}
          {#if photos[activeIndex].uploader_name}
            <span class="text-surface/50">— {photos[activeIndex].uploader_name}</span>
          {/if}
        </p>
      {/if}
    </div>
  </div>
{/if}
