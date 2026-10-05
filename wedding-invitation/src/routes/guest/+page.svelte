<script lang="ts">
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { guestStore } from '$lib/guestStore';
  import { toGuestProfile } from '$lib/guestProfile';
  import { site } from '$lib/site-config';

  let guest = $derived($guestStore.guest);
  let profile = $derived(toGuestProfile(guest));

  onMount(() => {
    if (!$guestStore.guest) goto('/');
  });

  const status = $derived(
    guest?.rsvp_status === 'attending' ? 'Attending' : guest?.rsvp_status === 'declined' ? 'Declined' : 'Awaiting your reply'
  );
</script>

<svelte:head>
  <title>My Invitation — {site.coupleNames}</title>
  <meta name="robots" content="noindex" />
</svelte:head>

{#if guest && profile}
  <main class="mx-auto max-w-2xl px-6 py-20 text-center sm:py-28">
    <a href="/" class="eyebrow hover:text-ink">← Back to the invitation</a>

    <p class="font-script mt-14 text-5xl text-champagne">Welcome</p>
    <h1 class="heading mt-2">{guest.first_name} {guest.last_name}</h1>
    <p class="lede mt-4">We're so happy to celebrate with you.</p>

    <dl class="mt-14 border-t border-line text-left text-sm">
      <div class="flex justify-between gap-6 border-b border-line py-4">
        <dt class="text-muted">Invitation</dt>
        <dd class="text-ink">{profile.weddingParty ? 'Wedding Party' : 'Guest'}</dd>
      </div>
      <div class="flex justify-between gap-6 border-b border-line py-4">
        <dt class="text-muted">RSVP</dt>
        <dd class="text-ink">{status}</dd>
      </div>
      <div class="flex justify-between gap-6 border-b border-line py-4">
        <dt class="text-muted">Plus one</dt>
        <dd class="text-ink">{guest.plus_one_allowed ? 'Included' : 'Not included'}</dd>
      </div>
      {#if guest.dietary_notes}
        <div class="flex justify-between gap-6 border-b border-line py-4">
          <dt class="text-muted">Dietary notes</dt>
          <dd class="text-right text-ink">{guest.dietary_notes}</dd>
        </div>
      {/if}
      {#if profile.weddingParty && guest.accommodation_name}
        <div class="flex justify-between gap-6 border-b border-line py-4">
          <dt class="text-muted">Accommodation</dt>
          <dd class="text-right text-ink">
            {guest.accommodation_name}{guest.room_nights ? ` · ${guest.room_nights} night${guest.room_nights !== 1 ? 's' : ''}` : ''}
          </dd>
        </div>
      {/if}
    </dl>

    <div class="mt-12 flex flex-wrap justify-center gap-4">
      <a href="/#rsvp" class="btn">{guest.rsvp_status === 'pending' ? 'RSVP' : 'Update RSVP'}</a>
      <a href="/#weekend" class="btn-ghost">View the weekend</a>
    </div>

    <p class="mt-16 text-sm text-muted">
      Questions? Call <a href={site.contactPhoneHref} class="underline underline-offset-4">{site.contactPhoneDisplay}</a>
    </p>
  </main>
{/if}