<script lang="ts">
  import { onMount } from 'svelte';
  import { supabase, type GalleryPhoto, type GuestPhoto } from '$lib/supabase';

  const GALLERY_BUCKET = 'gallery';
  const GUEST_PHOTOS_BUCKET = 'guest-photos';

  let galleryPhotos: GalleryPhoto[] = $state([]);
  let galleryLoading = $state(false);
  let galleryError = $state('');
  let galleryCaption = $state('');
  let galleryFiles: File[] = $state([]);
  let galleryUploading = $state(false);
  let galleryUploadError = $state('');

  let allGuestPhotos: GuestPhoto[] = $state([]);
  let guestPhotosLoading = $state(false);
  let guestPhotosError = $state('');

  onMount(() => {
    loadGalleryPhotos();
    loadAllGuestPhotos();
  });

  function withPublicUrl<T extends { storage_path: string }>(
    row: T,
    bucket: string
  ): T & { url: string } {
    return { ...row, url: supabase.storage.from(bucket).getPublicUrl(row.storage_path).data.publicUrl };
  }

  async function loadGalleryPhotos() {
    galleryLoading = true;
    galleryError = '';

    const { data, error } = await supabase
      .from('gallery_photos')
      .select('*')
      .order('sort_order', { ascending: true })
      .order('created_at', { ascending: true });

    if (error) {
      galleryError = error.message;
    } else {
      galleryPhotos = (data ?? []).map((row) => withPublicUrl(row, GALLERY_BUCKET));
    }
    galleryLoading = false;
  }

  function handleGalleryFileChange(e: Event) {
    const input = e.target as HTMLInputElement;
    galleryFiles = input.files ? Array.from(input.files) : [];
  }

  async function handleGalleryUpload(e: Event) {
    e.preventDefault();
    if (galleryFiles.length === 0) return;

    galleryUploading = true;
    galleryUploadError = '';

    try {
      for (const file of galleryFiles) {
        const ext = file.name.split('.').pop()?.toLowerCase() || 'jpg';
        const path = `${crypto.randomUUID()}.${ext}`;

        const { error: uploadError } = await supabase.storage
          .from(GALLERY_BUCKET)
          .upload(path, file, { contentType: file.type || undefined });
        if (uploadError) throw uploadError;

        const { error: insertError } = await supabase.from('gallery_photos').insert({
          storage_path: path,
          caption: galleryCaption.trim() || null,
          sort_order: galleryPhotos.length
        });
        if (insertError) throw insertError;
      }

      galleryFiles = [];
      galleryCaption = '';
      const fileInput = document.getElementById('gallery-file-input') as HTMLInputElement | null;
      if (fileInput) fileInput.value = '';
      await loadGalleryPhotos();
    } catch (err) {
      galleryUploadError = err instanceof Error ? err.message : 'Upload failed.';
    } finally {
      galleryUploading = false;
    }
  }

  async function deleteGalleryPhoto(photo: GalleryPhoto) {
    if (!confirm('Remove this photo from the gallery?')) return;
    await supabase.storage.from(GALLERY_BUCKET).remove([photo.storage_path]);
    await supabase.from('gallery_photos').delete().eq('id', photo.id);
    await loadGalleryPhotos();
  }

  async function loadAllGuestPhotos() {
    guestPhotosLoading = true;
    guestPhotosError = '';

    const { data, error } = await supabase
      .from('guest_photos')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) {
      guestPhotosError = error.message;
    } else {
      allGuestPhotos = (data ?? []).map((row) => withPublicUrl(row, GUEST_PHOTOS_BUCKET));
    }
    guestPhotosLoading = false;
  }

  async function deleteGuestPhoto(photo: GuestPhoto) {
    if (!confirm('Delete this guest photo?')) return;
    await supabase.storage.from(GUEST_PHOTOS_BUCKET).remove([photo.storage_path]);
    await supabase.from('guest_photos').delete().eq('id', photo.id);
    await loadAllGuestPhotos();
  }

  async function toggleGuestPhotoApproved(photo: GuestPhoto) {
    await supabase.from('guest_photos').update({ approved: !photo.approved }).eq('id', photo.id);
    await loadAllGuestPhotos();
  }
</script>

<!-- Curated gallery management -->
<div class="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
  <h2 class="text-lg font-medium text-slate-900">Photo Gallery</h2>
  <p class="mt-1 text-sm text-slate-500">
    Upload the curated pre-wedding photos shown on the public gallery section.
  </p>

  <form onsubmit={handleGalleryUpload} class="mt-4 grid gap-4 sm:grid-cols-[1fr_1fr_auto]">
    <input
      id="gallery-file-input"
      type="file"
      accept="image/*"
      multiple
      onchange={handleGalleryFileChange}
      class="rounded-xl border border-slate-300 px-4 py-2.5 text-sm text-slate-900 file:mr-3 file:rounded-full file:border-0 file:bg-rose-50 file:px-4 file:py-1.5 file:text-sm file:font-medium file:text-rose-600 focus:border-rose-400 focus:ring-2 focus:ring-rose-200 focus:outline-none"
    />
    <input
      type="text"
      placeholder="Caption (optional, applies to this batch)"
      bind:value={galleryCaption}
      class="rounded-xl border border-slate-300 px-4 py-2.5 text-sm text-slate-900 focus:border-rose-400 focus:ring-2 focus:ring-rose-200 focus:outline-none"
    />
    <button
      type="submit"
      disabled={galleryUploading}
      class="rounded-full bg-rose-500 px-6 py-2.5 text-sm font-medium text-white shadow transition hover:bg-rose-600 disabled:cursor-not-allowed disabled:opacity-60"
    >
      {galleryUploading ? 'Uploading...' : 'Upload'}
    </button>
  </form>
  {#if galleryUploadError}
    <p class="mt-2 text-sm text-red-600">{galleryUploadError}</p>
  {/if}

  {#if galleryLoading}
    <p class="mt-4 text-slate-500">Loading gallery...</p>
  {:else if galleryError}
    <p class="mt-4 text-red-600">{galleryError}</p>
  {:else if galleryPhotos.length === 0}
    <p class="mt-4 text-slate-500">No curated photos yet.</p>
  {:else}
    <div class="mt-4 grid grid-cols-3 gap-3 sm:grid-cols-4 lg:grid-cols-6">
      {#each galleryPhotos as photo (photo.id)}
        <div class="group relative aspect-square overflow-hidden rounded-xl bg-slate-100">
          <img src={photo.url} alt={photo.caption ?? ''} class="h-full w-full object-cover" />
          <button
            type="button"
            onclick={() => deleteGalleryPhoto(photo)}
            class="absolute top-1.5 right-1.5 rounded-full bg-black/60 px-2 py-1 text-xs text-white opacity-0 transition group-hover:opacity-100"
          >
            Remove
          </button>
        </div>
      {/each}
    </div>
  {/if}
</div>

<!-- Guest photo moderation -->
<div class="mt-10 rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
  <div class="flex items-center justify-between">
    <h2 class="text-lg font-medium text-slate-900">Guest Photo Uploads ({allGuestPhotos.length})</h2>
    <button type="button" onclick={loadAllGuestPhotos} class="text-sm font-medium text-rose-600 hover:underline">
      Refresh
    </button>
  </div>
  <p class="mt-1 text-sm text-slate-500">
    Photos guests uploaded after the wedding. Hide or delete any that shouldn't be public.
  </p>

  {#if guestPhotosLoading}
    <p class="mt-4 text-slate-500">Loading guest photos...</p>
  {:else if guestPhotosError}
    <p class="mt-4 text-red-600">{guestPhotosError}</p>
  {:else if allGuestPhotos.length === 0}
    <p class="mt-4 text-slate-500">No guest uploads yet.</p>
  {:else}
    <div class="mt-4 grid grid-cols-3 gap-3 sm:grid-cols-4 lg:grid-cols-6">
      {#each allGuestPhotos as photo (photo.id)}
        <div class="group relative aspect-square overflow-hidden rounded-xl bg-slate-100">
          <img
            src={photo.url}
            alt={photo.caption ?? ''}
            class="h-full w-full object-cover {photo.approved ? '' : 'opacity-40'}"
          />
          <div
            class="absolute inset-x-0 bottom-0 flex justify-center gap-1 bg-black/50 p-1 opacity-0 transition group-hover:opacity-100"
          >
            <button
              type="button"
              onclick={() => toggleGuestPhotoApproved(photo)}
              class="rounded-full bg-white/90 px-2 py-0.5 text-[10px] font-medium text-slate-700"
            >
              {photo.approved ? 'Hide' : 'Show'}
            </button>
            <button
              type="button"
              onclick={() => deleteGuestPhoto(photo)}
              class="rounded-full bg-red-500/90 px-2 py-0.5 text-[10px] font-medium text-white"
            >
              Delete
            </button>
          </div>
        </div>
      {/each}
    </div>
  {/if}
</div>
