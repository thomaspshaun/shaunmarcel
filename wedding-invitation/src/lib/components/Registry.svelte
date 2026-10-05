<script lang="ts">
  import { onMount } from "svelte";
  import { registry } from "$lib/site-config";

  let activeSlide = $state<"registry" | "honeymoon">("registry");
  let showBankDetails = $state(false);
  let copied = $state(false);

  onMount(() => {
    const timer = window.setInterval(() => {
      activeSlide = activeSlide === "registry" ? "honeymoon" : "registry";
    }, 5000);
    return () => window.clearInterval(timer);
  });

  async function copyReference() {
    await navigator.clipboard.writeText(registry.bankDetails.reference);
    copied = true;
    window.setTimeout(() => (copied = false), 2000);
  }
</script>

<section id="registry" class="mx-auto max-w-3xl px-6 py-20">
  <div class="rounded-2xl border border-rose-100 bg-rose-50 p-8 text-center sm:p-10">
    <p class="text-xs font-semibold uppercase tracking-[0.4em] text-rose-500 sm:text-sm">Gifts</p>

    {#if activeSlide === "registry"}
      <h2 class="mt-4 text-3xl font-light tracking-tight text-slate-900 sm:text-4xl">Gift Registry</h2>
      <p class="mx-auto mt-4 max-w-xl text-base leading-7 text-slate-600">
        If you would like to give a gift, you can view our Yuppiechef registry.
      </p>
      <a
        href={registry.yuppiechefUrl}
        target="_blank"
        rel="noopener noreferrer"
        class="mt-6 inline-flex rounded-full bg-rose-500 px-6 py-3 text-sm font-medium text-white transition hover:bg-rose-600"
      >
        View our Yuppiechef registry
      </a>
    {:else}
      <h2 class="mt-4 text-3xl font-light tracking-tight text-slate-900 sm:text-4xl">{registry.title}</h2>
      <p class="mx-auto mt-4 max-w-xl text-base leading-7 text-slate-600">{registry.description}</p>
      <button
        type="button"
        onclick={() => (showBankDetails = !showBankDetails)}
        aria-expanded={showBankDetails}
        class="mt-6 inline-flex rounded-full bg-rose-500 px-6 py-3 text-sm font-medium text-white transition hover:bg-rose-600"
      >
        {showBankDetails ? "Hide payment details" : "Pay by bank transfer"}
      </button>

      {#if showBankDetails}
        <div class="mx-auto mt-6 max-w-sm rounded-xl bg-white p-5 text-left">
          <p class="text-sm font-semibold text-slate-900">Banking details</p>
          <dl class="mt-4 space-y-3 text-sm">
            <div class="flex justify-between gap-4"><dt class="text-slate-500">Account name</dt><dd class="text-right font-medium text-slate-900">{registry.bankDetails.accountName}</dd></div>
            <div class="flex justify-between gap-4"><dt class="text-slate-500">Bank</dt><dd class="text-right font-medium text-slate-900">{registry.bankDetails.bankName}</dd></div>
            <div class="flex justify-between gap-4"><dt class="text-slate-500">Account number</dt><dd class="text-right font-medium text-slate-900">{registry.bankDetails.accountNumber}</dd></div>
            <div class="flex justify-between gap-4"><dt class="text-slate-500">Branch code</dt><dd class="text-right font-medium text-slate-900">{registry.bankDetails.branchCode}</dd></div>
          </dl>
          <div class="mt-4 border-t border-slate-100 pt-4">
            <p class="text-xs font-semibold uppercase tracking-wide text-slate-500">Payment reference</p>
            <div class="mt-2 flex items-center justify-between gap-3">
              <code class="text-sm font-medium text-slate-900">{registry.bankDetails.reference}</code>
              <button type="button" onclick={copyReference} class="rounded-full border border-slate-300 px-3 py-1 text-xs font-medium text-slate-700 hover:bg-slate-50">{copied ? "Copied" : "Copy"}</button>
            </div>
          </div>
        </div>
      {/if}
    {/if}

    <div class="mt-8 flex items-center justify-center gap-2" aria-label="Gift options">
      <button type="button" aria-label="Show gift registry" aria-current={activeSlide === "registry"} onclick={() => (activeSlide = "registry")} class="h-2.5 w-2.5 rounded-full" class:bg-rose-500={activeSlide === "registry"} class:bg-slate-300={activeSlide !== "registry"}></button>
      <button type="button" aria-label="Show honeymoon fund" aria-current={activeSlide === "honeymoon"} onclick={() => (activeSlide = "honeymoon")} class="h-2.5 w-2.5 rounded-full" class:bg-rose-500={activeSlide === "honeymoon"} class:bg-slate-300={activeSlide !== "honeymoon"}></button>
    </div>
    <p class="mt-2 text-xs text-slate-500">Gift options rotate automatically</p>
  </div>
</section>
