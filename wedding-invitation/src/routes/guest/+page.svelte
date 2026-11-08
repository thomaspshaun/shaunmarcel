<script lang="ts">
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { guestStore } from '$lib/guestStore';
  import { site } from '$lib/site-config';

  let guest = $derived($guestStore.guest);

  onMount(() => {
    if (!$guestStore.guest) goto('/');
  });

</script>

<svelte:head>
  <title>My Invitation — {site.coupleNames}</title>
  <meta name="robots" content="noindex" />
</svelte:head>

{#if guest}
  <main class="mx-auto max-w-2xl px-6 py-20 text-center sm:py-28">
    <a href="/" class="eyebrow hover:text-ink">← Back to the invitation</a>

    <p class="font-script mt-14 text-5xl text-champagne">Welcome</p>
    <h1 class="heading mt-2">{guest.first_name}</h1>
    <p class="lede mt-4">We're so happy to celebrate with you.</p>

    <dl class="mt-14 border-t border-line text-left text-sm">
      <div class="flex justify-between gap-6 border-b border-line py-4">
        <dt class="text-muted">People invited</dt>
        <dd class="text-ink">{1 + guest.partners.length} {guest.partners.length === 0 ? 'person' : 'people'}</dd>
      </div>
      {#if guest.partners.length}
        <div class="flex justify-between gap-6 border-b border-line py-4">
          <dt class="text-muted">Invited partners</dt>
          <dd class="text-right text-ink">{guest.partners.map((partner) => partner.first_name).join(', ')}</dd>
        </div>
      {/if}
    </dl>

    <div class="mt-12 flex flex-wrap justify-center gap-4">
      <a href="/#rsvp" class="btn">RSVP / Update RSVP</a>
      <a href="/#weekend" class="btn-ghost">View the weekend</a>
    </div>

    <p class="mt-16 text-sm text-muted">
      Questions? Call <a href={site.contactPhoneHref} class="underline underline-offset-4">{site.contactPhoneDisplay}</a>
    </p>
  </main>
{/if}