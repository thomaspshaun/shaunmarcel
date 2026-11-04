<script lang="ts">
  import Sprig from '$lib/components/Sprig.svelte';
  import { reveal } from '$lib/actions/reveal';
  import { registry } from '$lib/site-config';

  let showBankDetails = $state(false);
  let copied = $state(false);

  async function copyReference() {
    await navigator.clipboard.writeText(registry.bankDetails.reference);
    copied = true;
    window.setTimeout(() => (copied = false), 2000);
  }

  const rows = $derived([
    ['Account name', registry.bankDetails.accountName],
    ['Bank', registry.bankDetails.bankName],
    ['Account number', registry.bankDetails.accountNumber],
    ['Branch code', registry.bankDetails.branchCode]
  ]);
</script>

<section id="registry" class="border-t border-line/70 bg-paper-2/40 px-6 py-24 sm:py-32">
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
                <div class="flex justify-between gap-4 border-b border-line/70 py-2.5">
                  <dt class="text-muted">{label}</dt>
                  <dd class="text-right text-ink">{value}</dd>
                </div>
              {/each}
            </dl>
            <div class="mt-5 flex items-center justify-between gap-3">
              <div>
                <p class="eyebrow eyebrow-accent">Reference</p>
                <code class="mt-1 block text-sm text-ink">{registry.bankDetails.reference}</code>
              </div>
              <button type="button" onclick={copyReference} class="btn-ghost !px-4 !py-2">
                {copied ? 'Copied' : 'Copy'}
              </button>
            </div>
          </div>
        {/if}
      </article>
    </div>
  </div>
</section>
