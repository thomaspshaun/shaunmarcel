<script lang="ts">
  import { findGuestByCode } from '$lib/supabase';
  import { guestStore } from '$lib/guestStore';

  let isOpen = $state(false);
  let code = $state('');
  let error = $state('');
  let loading = $state(false);

  async function handleSubmit(e: Event) {
    e.preventDefault();
    if (!code.trim()) return;

    loading = true;
    error = '';

    try {
      const result = await findGuestByCode(code.toUpperCase());
      if (!result) {
        error = "We couldn't find an invitation with that code. Please double-check and try again.";
        return;
      }

      guestStore.setGuest(result, code.toUpperCase());
      code = '';
      isOpen = false;
    } catch (err) {
      error = err instanceof Error ? err.message : 'Something went wrong. Please try again.';
    } finally {
      loading = false;
    }
  }

  function closeModal() {
    code = '';
    error = '';
    isOpen = false;
  }
</script>

<svelte:window onkeydown={(e) => isOpen && e.key === 'Escape' && closeModal()} />

<button type="button" onclick={() => (isOpen = true)} class="btn-ghost">Find my invitation</button>

{#if isOpen}
  <div class="fixed inset-0 z-[60] flex items-center justify-center bg-ink/40 p-4">
    <div class="relative w-full max-w-md border border-line bg-paper p-8 sm:p-10" role="dialog" tabindex="-1" aria-modal="true" aria-labelledby="lookup-title">
      <button
        type="button"
        onclick={closeModal}
        class="absolute right-2 top-2 flex h-11 w-11 items-center justify-center text-muted hover:text-ink"
        aria-label="Close"
      >
        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M6 18L18 6M6 6l12 12" />
        </svg>
      </button>

      <p class="eyebrow text-center">Your invitation</p>
      <h2 id="lookup-title" class="font-display mt-3 text-center text-3xl font-light text-ink">Find your invitation</h2>
      <p class="lede mt-3 text-center text-sm">Enter the 8-character code from your invitation.</p>

      <form onsubmit={handleSubmit} class="mt-8">
        <label for="code" class="sr-only">Invitation code</label>
        <input
          id="code"
          type="text"
          bind:value={code}
          placeholder="AB12CD34"
          maxlength="8"
          autocomplete="off"
          class="w-full border border-line bg-surface px-4 py-3 text-center font-mono text-lg uppercase tracking-[0.3em] text-ink placeholder:text-muted/50 focus:border-sage focus:outline-none"
          disabled={loading}
        />

        {#if error}
          <p class="mt-4 border border-line bg-surface p-3 text-sm text-ink" role="alert">{error}</p>
        {/if}

        <button type="submit" disabled={loading || !code.trim()} class="btn mt-6 w-full disabled:cursor-not-allowed disabled:opacity-50">
          {loading ? 'Looking up…' : 'Unlock'}
        </button>
      </form>
    </div>
  </div>
{/if}