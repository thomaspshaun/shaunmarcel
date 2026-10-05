<script lang="ts">
  import { onMount } from "svelte";
  import {
    fetchGuestbookComments,
    postGuestbookComment,
    type GuestbookComment,
  } from "$lib/supabase";

  let comments = $state<GuestbookComment[]>([]);
  let loading = $state(true);
  let loadError = $state("");

  let displayName = $state("");
  let message = $state("");
  let submitting = $state(false);
  let submitError = $state("");
  let submitted = $state(false);

  onMount(load);

  async function load() {
    loading = true;
    loadError = "";
    try {
      comments = await fetchGuestbookComments();
    } catch (err) {
      loadError = err instanceof Error ? err.message : "Could not load the guestbook.";
    } finally {
      loading = false;
    }
  }

  async function handleSubmit(event: SubmitEvent) {
    event.preventDefault();
    if (!displayName.trim() || !message.trim()) {
      submitError = "Please add your name and a short message.";
      return;
    }

    submitting = true;
    submitError = "";
    try {
      await postGuestbookComment(displayName.trim(), message.trim());
      message = "";
      submitted = true;
      await load();
    } catch (err) {
      submitError = err instanceof Error ? err.message : "Could not post your message.";
    } finally {
      submitting = false;
    }
  }

  function formatDate(iso: string) {
    return new Date(iso).toLocaleDateString(undefined, {
      day: "numeric",
      month: "short",
      year: "numeric",
    });
  }
</script>

<section id="guestbook" class="mx-auto max-w-3xl px-6 py-20">
  <div class="text-center">
    <p class="eyebrow">
      Leave a Note
    </p>
    <h2 class="heading mt-4">
      Guestbook
    </h2>
    <p class="lede mx-auto mt-5 max-w-md">
      Share a message, a memory, or your excitement for the big day.
    </p>
  </div>

  <form
    onsubmit={handleSubmit}
    class="mt-10 border border-line bg-surface p-6"
  >
    <div class="grid gap-4 sm:grid-cols-2">
      <label class="block text-sm">
        <span class="font-medium text-ink">Your name</span>
        <input
          type="text"
          bind:value={displayName}
          maxlength="80"
          required
          class="mt-1 w-full rounded-none border border-line px-3 py-2 text-sm focus:border-sage focus:outline-none"
        />
      </label>
    </div>

    <label class="mt-4 block text-sm">
      <span class="font-medium text-ink">Message</span>
      <textarea
        bind:value={message}
        maxlength="500"
        rows="3"
        required
        placeholder="So happy for you both!"
        class="mt-1 w-full rounded-none border border-line px-3 py-2 text-sm focus:border-sage focus:outline-none"
      ></textarea>
    </label>

    {#if submitError}
      <p class="mt-3 text-sm text-sage-dark">{submitError}</p>
    {/if}
    {#if submitted && !submitError}
      <p class="mt-3 text-sm text-sage-dark">Thank you — your message was posted!</p>
    {/if}

    <button
      type="submit"
      disabled={submitting}
      class="mt-5 btn w-full disabled:cursor-not-allowed disabled:opacity-60 sm:w-auto"
    >
      {submitting ? "Posting…" : "Post Message"}
    </button>
  </form>

  <div class="mt-10 space-y-4">
    {#if loading}
      <p class="text-center text-sm text-muted">Loading messages…</p>
    {:else if loadError}
      <p class="text-center text-sm text-sage-dark">{loadError}</p>
    {:else if comments.length === 0}
      <p class="text-center text-sm text-muted">Be the first to leave a message!</p>
    {:else}
      {#each comments as comment (comment.id)}
        <div class="border border-line bg-surface p-5">
          <div class="flex items-baseline justify-between gap-4">
            <p class="font-medium text-ink">{comment.display_name}</p>
            <p class="text-xs text-muted">{formatDate(comment.created_at)}</p>
          </div>
          <p class="mt-2 text-sm leading-6 text-ink">{comment.message}</p>
        </div>
      {/each}
    {/if}
  </div>
</section>
