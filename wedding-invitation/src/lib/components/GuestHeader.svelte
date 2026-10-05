<script lang="ts">
  import { guestStore } from '$lib/guestStore';

  let guest = $derived($guestStore.guest);

  const roleLabel = (type: string) =>
    type === 'wedding_party' ? 'Wedding Party' : type.charAt(0).toUpperCase() + type.slice(1).replace('_', ' ');
</script>

{#if guest}
  <div class="border-b border-line/70 bg-paper-2/60">
    <div class="mx-auto flex max-w-6xl flex-wrap items-center justify-between gap-x-6 gap-y-1 px-6 py-2.5">
      <p class="text-[0.65rem] uppercase tracking-[0.24em] text-muted">
        Welcome, <span class="text-ink">{guest.first_name}</span>
        <span class="px-1 text-champagne">·</span>{roleLabel(guest.guest_type)}
      </p>
      <div class="flex items-center gap-5 text-[0.65rem] font-semibold uppercase tracking-[0.24em]">
        <a href="/guest" class="flex min-h-9 items-center text-sage-dark hover:text-ink">My invitation</a>
        <button type="button" onclick={() => guestStore.clearGuest()} class="flex min-h-9 items-center text-muted hover:text-ink">
          Sign out
        </button>
      </div>
    </div>
  </div>
{/if}