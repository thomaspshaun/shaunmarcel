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
    <p class="text-xs font-semibold uppercase tracking-[0.4em] text-rose-500 sm:text-sm">
      Leave a Note
    </p>
    <h2 class="mt-4 text-3xl font-light tracking-tight text-slate-900 sm:text-4xl">
      Guestbook
    </h2>
    <p class="mx-auto mt-3 max-w-xl text-base text-slate-600">
      Share a message, a memory, or your excitement for the big day.
    </p>
  </div>

  <form
    onsubmit={handleSubmit}
    class="mt-10 rounded-2xl border border-slate-200 bg-white p-6 shadow-sm"
  >
    <div class="grid gap-4 sm:grid-cols-2">
      <label class="block text-sm">
        <span class="font-medium text-slate-700">Your name</span>
        <input
          type="text"
          bind:value={displayName}
          maxlength="80"
          required
          class="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-rose-400 focus:ring-1 focus:ring-rose-400 focus:outline-none"
        />
      </label>
    </div>

    <label class="mt-4 block text-sm">
      <span class="font-medium text-slate-700">Message</span>
      <textarea
        bind:value={message}
        maxlength="500"
        rows="3"
        required
        placeholder="So happy for you both!"
        class="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-rose-400 focus:ring-1 focus:ring-rose-400 focus:outline-none"
      ></textarea>
    </label>

    {#if submitError}
      <p class="mt-3 text-sm text-rose-500">{submitError}</p>
    {/if}
    {#if submitted && !submitError}
      <p class="mt-3 text-sm text-emerald-600">Thank you — your message was posted!</p>
    {/if}

    <button
      type="submit"
      disabled={submitting}
      class="mt-5 inline-flex w-full items-center justify-center rounded-full bg-rose-500 px-6 py-2.5 text-sm font-medium text-white transition hover:bg-rose-600 disabled:cursor-not-allowed disabled:opacity-60 sm:w-auto"
    >
      {submitting ? "Posting…" : "Post Message"}
    </button>
  </form>

  <div class="mt-10 space-y-4">
    {#if loading}
      <p class="text-center text-sm text-slate-500">Loading messages…</p>
    {:else if loadError}
      <p class="text-center text-sm text-rose-500">{loadError}</p>
    {:else if comments.length === 0}
      <p class="text-center text-sm text-slate-500">Be the first to leave a message!</p>
    {:else}
      {#each comments as comment (comment.id)}
        <div class="rounded-xl border border-slate-200 bg-white p-5 shadow-sm">
          <div class="flex items-baseline justify-between gap-4">
            <p class="font-medium text-slate-900">{comment.display_name}</p>
            <p class="text-xs text-slate-400">{formatDate(comment.created_at)}</p>
          </div>
          <p class="mt-2 text-sm leading-6 text-slate-600">{comment.message}</p>
        </div>
      {/each}
    {/if}
  </div>
</section>
