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
    <p class="text-xs font-semibold uppercase tracking-[0.4em] text-rose-500 sm:text-sm">
      Share the Memories
    </p>
    <h2 class="mt-4 text-3xl font-light tracking-tight text-slate-900 sm:text-4xl">
      Guest Photos
    </h2>
    <p class="mx-auto mt-3 max-w-xl text-base text-slate-600">
      Snapped a photo on the day? Upload it here so we can all enjoy it together. Max 8MB per
      photo — JPG, PNG, WEBP, or HEIC.
    </p>
  </div>

  <form
    onsubmit={handleUpload}
    class="mx-auto mt-10 max-w-xl rounded-2xl border border-slate-200 bg-white p-6 shadow-sm"
  >
    <label class="block text-sm">
      <span class="font-medium text-slate-700">Your name (optional)</span>
      <input
        type="text"
        bind:value={uploaderName}
        maxlength="80"
        class="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-rose-400 focus:ring-1 focus:ring-rose-400 focus:outline-none"
      />
    </label>

    <label class="mt-4 block text-sm">
      <span class="font-medium text-slate-700">Caption (optional)</span>
      <input
        type="text"
        bind:value={caption}
        maxlength="160"
        class="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-rose-400 focus:ring-1 focus:ring-rose-400 focus:outline-none"
      />
    </label>

    <label class="mt-4 block text-sm">
      <span class="font-medium text-slate-700">Photo(s)</span>
      <input
        id="guest-photo-input"
        type="file"
        accept="image/*"
        multiple
        onchange={handleFileChange}
        class="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-sm file:mr-3 file:rounded-full file:border-0 file:bg-rose-50 file:px-4 file:py-1.5 file:text-sm file:font-medium file:text-rose-600 focus:border-rose-400 focus:ring-1 focus:ring-rose-400 focus:outline-none"
      />
    </label>

    {#if uploadError}
      <p class="mt-3 text-sm text-rose-500">{uploadError}</p>
    {/if}
    {#if uploadedCount > 0 && !uploadError}
      <p class="mt-3 text-sm text-emerald-600">
        Uploaded {uploadedCount} photo{uploadedCount === 1 ? "" : "s"} — thank you!
      </p>
    {/if}

    <button
      type="submit"
      disabled={uploading}
      class="mt-5 inline-flex w-full items-center justify-center rounded-full bg-rose-500 px-6 py-2.5 text-sm font-medium text-white transition hover:bg-rose-600 disabled:cursor-not-allowed disabled:opacity-60"
    >
      {uploading ? "Uploading…" : "Upload Photo(s)"}
    </button>
  </form>

  {#if loading}
    <p class="mt-12 text-center text-sm text-slate-500">Loading guest photos…</p>
  {:else if loadError}
    <p class="mt-12 text-center text-sm text-rose-500">{loadError}</p>
  {:else if photos.length === 0}
    <p class="mt-12 text-center text-sm text-slate-500">No guest photos yet — be the first!</p>
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
    <div class="flex max-w-full flex-col items-center" onclick={(e) => e.stopPropagation()}>
      <img
        src={photos[activeIndex].url}
        alt={photos[activeIndex].caption ?? "Guest photo"}
        class="max-h-[75vh] max-w-full rounded-lg object-contain"
      />
      {#if photos[activeIndex].caption || photos[activeIndex].uploader_name}
        <p class="mt-3 text-center text-sm text-white/80">
          {photos[activeIndex].caption}
          {#if photos[activeIndex].uploader_name}
            <span class="text-white/50">— {photos[activeIndex].uploader_name}</span>
          {/if}
        </p>
      {/if}
    </div>
  </div>
{/if}
