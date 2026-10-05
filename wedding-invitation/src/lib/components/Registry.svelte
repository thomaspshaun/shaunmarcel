<script lang="ts">
  import { onMount } from 'svelte';
  import Sprig from '$lib/components/Sprig.svelte';
  import { reveal } from '$lib/actions/reveal';
  import { registry } from '$lib/site-config';

  let activeSlide = $state<'registry' | 'honeymoon'>('registry');
  let showBankDetails = $state(false);
  let paused = $state(false);
  let copied = $state(false);

  // Rotate every 5s, but never while someone is reading bank details or hovering/focusing the card.
  onMount(() => {
    const timer = window.setInterval(() => {
      if (paused || showBankDetails) return;
      activeSlide = activeSlide === 'registry' ? 'honeymoon' : 'registry';
    }, 5000);
    return () => window.clearInterval(timer);
  });

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
  <div
    class="mx-auto max-w-2xl text-center"
    use:reveal
    role="group"
    aria-label="Gift options"
    onmouseenter={() => (paused = true)}
    onmouseleave={() => (paused = false)}
    onfocusin={() => (paused = true)}
    onfocusout={() => (paused = false)}
  >
    <p class="eyebrow">Gifts</p>

    <div class="mt-4 min-h-[20rem] sm:min-h-[18rem]">
      {#key activeSlide}
        <div class="fade-up" style="--d: 0s">
          {#if activeSlide === 'registry'}
            <h2 class="heading">Gift Registry</h2>
            <p class="lede mx-auto mt-6 max-w-md">If you would like to give a gift, you can view our Yuppiechef registry.</p>
            <a href={registry.yuppiechefUrl} target="_blank" rel="noopener noreferrer" class="btn mt-8">View our registry</a>
          {:else}
            <h2 class="heading">{registry.title}</h2>
            <p class="lede mx-auto mt-6 max-w-md">{registry.description}</p>
            <button type="button" class="btn mt-8" aria-expanded={showBankDetails} onclick={() => (showBankDetails = !showBankDetails)}>
              {showBankDetails ? 'Hide payment details' : 'Pay by bank transfer'}
            </button>

            {#if showBankDetails}
              <div class="mx-auto mt-8 max-w-sm border border-line bg-surface p-6 text-left">
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
                  <button type="button" onclick={copyReference} class="btn-ghost !px-4 !py-2">{copied ? 'Copied' : 'Copy'}</button>
                </div>
              </div>
            {/if}
          {/if}
        </div>
      {/key}
    </div>

    <div class="mt-6 flex items-center justify-center gap-1">
      {#each [['registry', 'Show gift registry'], ['honeymoon', 'Show honeymoon fund']] as [id, label] (id)}
        <button type="button" aria-label={label} aria-current={activeSlide === id} onclick={() => (activeSlide = id as 'registry' | 'honeymoon')} class="flex h-8 w-8 items-center justify-center">
          <span class="h-1.5 w-1.5 rotate-45 transition-colors {activeSlide === id ? 'bg-champagne' : 'bg-line'}"></span>
        </button>
      {/each}
    </div>
    <Sprig class="mx-auto mt-4 h-5 w-28 text-champagne" />
  </div>
</section>