<script lang="ts">
  import { guestStore } from '$lib/guestStore';

  let guest = $derived($guestStore.guest);
  let isOpen = $state(false);

  function signOut() {
    guestStore.clearGuest();
    isOpen = false;
  }
</script>

{#if guest}
  <div class="sticky top-0 z-40 border-b border-slate-200 bg-white/95 backdrop-blur-sm">
    <div class="mx-auto max-w-5xl px-6 py-3 flex items-center justify-between">
      <div class="flex items-center gap-2">
        <span class="text-lg">👋</span>
        <div class="text-sm">
          <p class="font-medium text-slate-900">Welcome, {guest.first_name}!</p>
          <p class="text-xs text-slate-500">
            {#if guest.guest_type === 'wedding_party'}
              Wedding Party
            {:else if guest.guest_type === 'vip'}
              VIP Guest
            {:else}
              {guest.guest_type.charAt(0).toUpperCase() + guest.guest_type.slice(1)}
            {/if}
          </p>
        </div>
      </div>

      <div class="relative">
        <button
          onclick={() => (isOpen = !isOpen)}
          class="rounded-full p-2 text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition"
          title="Guest menu"
        >
          <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 20 20">
            <path
              d="M10 12a2 2 0 100-4 2 2 0 000 4z"
            />
            <path fill-rule="evenodd" d="M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z" clip-rule="evenodd" />
          </svg>
        </button>

        {#if isOpen}
          <div class="absolute right-0 mt-1 w-40 rounded-lg border border-slate-200 bg-white shadow-lg">
            <a
              href="/guest"
              class="block px-4 py-2 text-sm text-slate-700 hover:bg-slate-50 rounded-t-lg"
              onclick={() => (isOpen = false)}
            >
              📋 My Invitation
            </a>
            <button
              onclick={signOut}
              class="w-full text-left px-4 py-2 text-sm text-slate-700 hover:bg-slate-50 rounded-b-lg border-t border-slate-200"
            >
              Sign Out
            </button>
          </div>
        {/if}
      </div>
    </div>
  </div>
{/if}
