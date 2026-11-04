<script lang="ts">
  import Sprig from '$lib/components/Sprig.svelte';
  import { reveal } from '$lib/actions/reveal';
  import { guestStore } from '$lib/guestStore';
  import { registry } from '$lib/site-config';

  let showBankDetails = $state(false);
  let copyMessage = $state('');
  const guestName = $derived(
    $guestStore.guest
      ? [$guestStore.guest.first_name, $guestStore.guest.partner_first_name]
          .filter((name): name is string => Boolean(name?.trim()))
          .join(' & ')
      : 'Guest'
  );
  const reference = $derived(`${registry.bankDetails.referencePrefix} ${guestName}`);

  async function copyValue(value: string, label: string) {
    try {
      await navigator.clipboard.writeText(value);
      copyMessage = `${label} copied`;
    } catch {
      copyMessage = `Could not copy ${label.toLowerCase()}. Please copy it manually.`;
    }
  }

  const rows = $derived([
    ['Reference', reference],
    ['Account name', registry.bankDetails.accountName],
    ['Bank', registry.bankDetails.bankName],
    ['Branch code', registry.bankDetails.branchCode],
    ['Account number', registry.bankDetails.accountNumber]
  ]);
</script>

<section id="registry" class="border-t border-line/70 px-6 py-24 sm:py-32">
  <div class="mx-auto max-w-5xl text-center" use:reveal>
    <p class="eyebrow">Gifts</p>
    <h2 class="heading mt-4">Choose an Option</h2>
    <p class="lede mx-auto mt-5 max-w-xl">
      Your presence is the greatest gift. If you wish, you can choose either of these options.
    </p>
    <Sprig class="mx-auto mt-6 h-5 w-28 text-champagne" />

    <div class="mt-10 grid gap-6 text-left md:grid-cols-2">
      <article class="border border-line/70 bg-surface/90 p-7 sm:p-9">
        <p class="eyebrow eyebrow-accent">Option One</p>
        <h3 class="heading mt-3">Gift Registry</h3>
        <p class="lede mt-4">
          If you would like to give us a gift, you can choose something from our Yuppiechef registry.
        </p>
        <a
          href={registry.yuppiechefUrl}
          target="_blank"
          rel="noopener noreferrer"
          class="btn mt-7"
        >
          View our registry
        </a>
      </article>

      <article class="border border-line/70 bg-surface/90 p-7 sm:p-9">
        <p class="eyebrow eyebrow-accent">Option Two</p>
        <h3 class="heading mt-3">{registry.title}</h3>
        <p class="lede mt-4">{registry.description}</p>
        <button
          type="button"
          class="btn mt-7"
          aria-expanded={showBankDetails}
          aria-controls="honeymoon-bank-details"
          onclick={() => (showBankDetails = !showBankDetails)}
        >
          {showBankDetails ? 'Hide payment details' : 'Pay by bank transfer'}
        </button>

        {#if showBankDetails}
          <div id="honeymoon-bank-details" class="mt-8 border border-line bg-surface p-6">
            <p class="eyebrow">Banking details</p>
            <dl class="mt-4 text-sm">
              {#each rows as [label, value] (label)}
                <div class="grid grid-cols-[auto_1fr_auto] items-center gap-3 border-b border-line/70 py-2.5">
                  <dt class="text-muted">{label}</dt>
                  <dd class="min-w-0 break-words text-right text-ink">{value}</dd>
                  <button
                    type="button"
                    class="rounded p-1.5 text-muted transition hover:bg-line/40 hover:text-ink focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ink"
                    aria-label={`Copy ${label}`}
                    title={`Copy ${label}`}
                    onclick={() => copyValue(value, label)}
                  >
                    <svg
                      aria-hidden="true"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      stroke-width="1.8"
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      class="h-4 w-4"
                    >
                      <rect x="8" y="8" width="14" height="14" rx="2" />
                      <path d="M16 8V5a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h3" />
                    </svg>
                  </button>
                </div>
              {/each}
            </dl>
            <p class="sr-only" aria-live="polite">{copyMessage}</p>
          </div>
        {/if}
      </article>
    </div>
  </div>
</section>
