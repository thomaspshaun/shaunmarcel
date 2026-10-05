<script lang="ts">
  import { guestStore } from '$lib/guestStore';
  import { site } from '$lib/site-config';
  import { goto } from '$app/navigation';

  let guest = $derived($guestStore.guest);
  let code = $derived($guestStore.code);

  // Redirect to home if no guest logged in
  if (!guest) {
    goto('/');
  }
</script>

<svelte:head>
  <title>My Invitation — {site.coupleNames}</title>
  <meta name="description" content="Your personalized wedding invitation details." />
</svelte:head>

{#if guest && code}
  <div class="min-h-screen bg-gradient-to-b from-rose-50 to-white">
    <!-- Header -->
    <div class="border-b border-rose-200 bg-white">
      <div class="mx-auto max-w-3xl px-6 py-8">
        <div class="mb-4">
          <a href="/" class="inline-flex items-center gap-1 text-sm text-rose-600 hover:text-rose-700">
            ← Back to wedding site
          </a>
        </div>
        <h1 class="text-3xl font-light text-slate-900">Your Invitation</h1>
        <p class="mt-2 text-slate-600">
          All your personalized wedding details and information below.
        </p>
      </div>
    </div>

    <!-- Main Content -->
    <div class="mx-auto max-w-3xl px-6 py-12">
      <!-- Welcome Card -->
      <div class="mb-8 rounded-2xl border-2 border-rose-200 bg-rose-50 p-8">
        <div class="text-center">
          <p class="text-5xl">👋</p>
          <h2 class="mt-4 text-2xl font-light text-slate-900">
            Welcome, {guest.first_name} {guest.last_name}!
          </h2>
          <p class="mt-2 text-slate-600">
            We're so excited to celebrate with you!
          </p>
        </div>
      </div>

      <!-- Guest Details -->
      <div class="mb-8 grid gap-6 sm:grid-cols-2">
        <!-- Guest Type -->
        <div class="rounded-xl border border-slate-200 bg-white p-6">
          <p class="text-xs font-semibold uppercase text-slate-500">Guest Type</p>
          <p class="mt-2 text-lg font-medium text-slate-900">
            {#if guest.guest_type === 'wedding_party'}
              💍 Wedding Party
            {:else if guest.guest_type === 'vip'}
              ⭐ VIP Guest
            {:else if guest.guest_type === 'family'}
              👨‍👩‍👧‍👦 Family
            {:else}
              👥 Standard Guest
            {/if}
          </p>
        </div>

        <!-- RSVP Status -->
        <div class="rounded-xl border border-slate-200 bg-white p-6">
          <p class="text-xs font-semibold uppercase text-slate-500">RSVP Status</p>
          <p class="mt-2 text-lg font-medium">
            {#if guest.rsvp_status === 'attending'}
              <span class="text-green-600">✓ Attending</span>
            {:else if guest.rsvp_status === 'declined'}
              <span class="text-slate-500">— Declined</span>
            {:else}
              <span class="text-amber-600">⏳ Pending</span>
            {/if}
          </p>
        </div>

        <!-- Plus One -->
        <div class="rounded-xl border border-slate-200 bg-white p-6">
          <p class="text-xs font-semibold uppercase text-slate-500">Plus One</p>
          <p class="mt-2 text-lg font-medium text-slate-900">
            {guest.plus_one_allowed ? '✓ Allowed' : '— Not allowed'}
          </p>
        </div>

        <!-- Dietary Notes -->
        <div class="rounded-xl border border-slate-200 bg-white p-6">
          <p class="text-xs font-semibold uppercase text-slate-500">Dietary Notes</p>
          <p class="mt-2 text-sm text-slate-700">
            {guest.dietary_notes || '(None provided)'}
          </p>
        </div>
      </div>

      <!-- Quick Actions -->
      <div class="mb-8 rounded-xl border border-slate-200 bg-slate-50 p-6">
        <h3 class="text-lg font-medium text-slate-900">Quick Actions</h3>
        <div class="mt-4 flex flex-col gap-3 sm:flex-row">
          <a
            href="#rsvp"
            class="flex-1 rounded-lg bg-rose-500 px-4 py-2.5 text-center text-sm font-medium text-white transition hover:bg-rose-600"
          >
            Update RSVP
          </a>
          <a
            href="#details"
            class="flex-1 rounded-lg border border-slate-300 px-4 py-2.5 text-center text-sm font-medium text-slate-700 transition hover:bg-white"
          >
            View Schedule
          </a>
          <a
            href="mailto:?subject=Wedding%20Invitation&body=You're%20invited!%20{window.location.origin}?code={code}"
            class="flex-1 rounded-lg border border-slate-300 px-4 py-2.5 text-center text-sm font-medium text-slate-700 transition hover:bg-white"
          >
            Share Invite
          </a>
        </div>
      </div>

      <!-- Special Info for Wedding Party -->
      {#if guest.guest_type === 'wedding_party'}
        <div class="mb-8 rounded-xl border-2 border-rose-300 bg-rose-50 p-6">
          <h3 class="text-lg font-semibold text-rose-900">🎊 Wedding Party Perks</h3>
          <ul class="mt-4 space-y-2 text-sm text-rose-800">
            <li>✓ Complimentary accommodation at the estate</li>
            <li>✓ Included meals throughout the weekend</li>
            <li>✓ Reserved parking at the venue</li>
            <li>✓ Early access to all wedding events</li>
            <li>✓ Special recognition during the ceremony</li>
          </ul>
          <p class="mt-4 text-xs text-rose-700">
            More details will be sent via WhatsApp and email closer to the date.
          </p>
        </div>
      {/if}

      <!-- Accommodation Info -->
      {#if guest.guest_type === 'wedding_party' && guest.accommodation_name}
        <div class="mb-8 rounded-xl border border-slate-200 bg-white p-6">
          <h3 class="text-lg font-medium text-slate-900">Your Accommodation</h3>
          <p class="mt-3 text-slate-700">
            <strong>{guest.accommodation_name}</strong>
            {#if guest.room_nights}
              · {guest.room_nights} night{guest.room_nights !== 1 ? 's' : ''}
            {/if}
          </p>
          <p class="mt-2 text-sm text-slate-600">
            Confirmation status: <strong>
              {guest.accommodation_confirmed ? '✓ Confirmed' : '⏳ Pending'}
            </strong>
          </p>
        </div>
      {/if}

      <!-- Contact Info -->
      <div class="rounded-xl border border-slate-200 bg-white p-6">
        <h3 class="text-lg font-medium text-slate-900">Contact Us</h3>
        <p class="mt-3 text-sm text-slate-600">
          Questions about the wedding? Reach out via WhatsApp or email:
        </p>
        <div class="mt-4 flex flex-col gap-2 text-sm">
          <a href="https://wa.me/27..." class="text-rose-600 hover:underline">
            💬 Message via WhatsApp
          </a>
          <a href="mailto:..." class="text-rose-600 hover:underline">
            ✉️ Email us
          </a>
        </div>
      </div>
    </div>
  </div>
{:else}
  <!-- Not logged in, show redirect message -->
  <div class="flex min-h-screen items-center justify-center">
    <div class="text-center">
      <p class="text-lg text-slate-600">Redirecting...</p>
    </div>
  </div>
{/if}
