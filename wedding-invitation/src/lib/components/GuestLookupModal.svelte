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

<!-- Open button (usually in Hero or Header) -->
<button
  onclick={() => (isOpen = true)}
  class="inline-flex items-center justify-center gap-2 rounded-full bg-rose-500 px-6 py-2.5 text-sm font-medium text-white transition hover:bg-rose-600"
>
  <span>🎫 Find My Invitation</span>
</button>

<!-- Modal -->
{#if isOpen}
  <div class="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
    <div class="w-full max-w-md rounded-2xl bg-white p-8 shadow-xl">
      <h2 class="text-2xl font-light tracking-tight text-slate-900">Find Your Invitation</h2>
      <p class="mt-2 text-sm text-slate-600">
        Enter your 8-character invitation code to access your personalized experience.
      </p>

      <form onsubmit={handleSubmit} class="mt-6">
        <div>
          <label for="code" class="block text-sm font-medium text-slate-700">Invitation Code</label>
          <input
            id="code"
            type="text"
            bind:value={code}
            placeholder="e.g., AB12CD34"
            maxlength="8"
            class="mt-2 w-full rounded-lg border border-slate-300 px-4 py-2 text-center text-lg font-mono uppercase tracking-widest text-slate-900 placeholder-slate-400 focus:border-rose-500 focus:outline-none focus:ring-2 focus:ring-rose-500/10"
            disabled={loading}
          />
        </div>

        {#if error}
          <div class="mt-4 rounded-lg bg-red-50 p-3 text-sm text-red-700">
            {error}
          </div>
        {/if}

        <div class="mt-6 flex gap-3">
          <button
            type="button"
            onclick={closeModal}
            class="flex-1 rounded-lg border border-slate-300 px-4 py-2.5 text-sm font-medium text-slate-700 transition hover:bg-slate-50"
            disabled={loading}
          >
            Cancel
          </button>
          <button
            type="submit"
            disabled={loading || !code.trim()}
            class="flex-1 rounded-lg bg-rose-500 px-4 py-2.5 text-sm font-medium text-white transition hover:bg-rose-600 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {loading ? 'Looking up...' : 'Unlock'}
          </button>
        </div>
      </form>

      <button
        type="button"
        onclick={closeModal}
        class="absolute right-4 top-4 text-slate-400 hover:text-slate-600"
        aria-label="Close modal"
      >
        <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
        </svg>
      </button>
    </div>
  </div>
{/if}
