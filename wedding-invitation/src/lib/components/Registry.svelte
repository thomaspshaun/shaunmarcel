<script lang="ts">
  import { registry } from "$lib/site-config";

  let copied = $state(false);

  async function copyReference() {
    await navigator.clipboard.writeText(registry.bankTransferReference);
    copied = true;
    window.setTimeout(() => {
      copied = false;
    }, 2000);
  }
</script>

<section id="registry" class="mx-auto max-w-3xl px-6 py-20">
  <div class="rounded-2xl border border-rose-100 bg-rose-50 p-8 text-center sm:p-10">
    <p class="text-xs font-semibold uppercase tracking-[0.4em] text-rose-500 sm:text-sm">
      Gifts
    </p>
    <h2 class="mt-4 text-3xl font-light tracking-tight text-slate-900 sm:text-4xl">
      {registry.title}
    </h2>
    <p class="mx-auto mt-4 max-w-xl text-base leading-7 text-slate-600">
      {registry.description}
    </p>

    {#if registry.paymentUrl}
      <a
        href={registry.paymentUrl}
        target="_blank"
        rel="noopener noreferrer"
        class="mt-6 inline-flex rounded-full bg-rose-500 px-6 py-3 text-sm font-medium text-white transition hover:bg-rose-600"
      >
        Contribute online
      </a>
    {/if}

    {#if registry.bankTransferReference}
      <div class="mx-auto mt-6 max-w-sm rounded-xl bg-white p-4 text-left">
        <p class="text-xs font-semibold uppercase tracking-wide text-slate-500">
          Bank transfer reference
        </p>
        <div class="mt-2 flex items-center justify-between gap-3">
          <code class="text-sm font-medium text-slate-900">{registry.bankTransferReference}</code>
          <button
            type="button"
            onclick={copyReference}
            class="rounded-full border border-slate-300 px-3 py-1 text-xs font-medium text-slate-700 hover:bg-slate-50"
          >
            {copied ? "Copied" : "Copy"}
          </button>
        </div>
      </div>
    {/if}
  </div>
</section>
