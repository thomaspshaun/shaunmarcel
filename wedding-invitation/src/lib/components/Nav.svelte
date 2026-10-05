<script lang="ts">
  import { navLinks, site } from '$lib/site-config';

  let mobileOpen = $state(false);
  const close = () => (mobileOpen = false);
</script>

<header class="sticky top-0 z-50 border-b border-line/70 bg-paper/90 backdrop-blur-sm">
  <nav class="mx-auto flex max-w-6xl items-center justify-between px-6 py-4 sm:py-5" aria-label="Main">
    <a href="#hero" onclick={close} class="text-[0.7rem] font-semibold uppercase tracking-[0.32em] text-ink">
      {site.coupleNames}
    </a>

    <ul class="hidden items-center gap-9 md:flex">
      {#each navLinks as link (link.href)}
        <li>
          <a href={link.href} class="text-[0.65rem] font-semibold uppercase tracking-[0.24em] text-muted transition-colors hover:text-sage-dark">
            {link.label}
          </a>
        </li>
      {/each}
    </ul>

    <button
      type="button"
      class="-mr-2 flex h-11 items-center gap-3 px-2 text-[0.65rem] font-semibold uppercase tracking-[0.24em] text-ink md:hidden"
      aria-label="Toggle navigation menu"
      aria-expanded={mobileOpen}
      onclick={() => (mobileOpen = !mobileOpen)}
    >
      Menu
      <span class="flex w-5 flex-col gap-1.5" aria-hidden="true">
        <span class="h-px bg-ink transition-transform {mobileOpen ? 'translate-y-[3.5px] rotate-45' : ''}"></span>
        <span class="h-px bg-ink transition-transform {mobileOpen ? '-translate-y-[3.5px] -rotate-45' : ''}"></span>
      </span>
    </button>
  </nav>

  {#if mobileOpen}
    <ul class="border-t border-line/70 bg-paper px-6 py-4 md:hidden">
      {#each navLinks as link (link.href)}
        <li class="border-b border-line/50 last:border-0">
          <a href={link.href} onclick={close} class="font-display block py-3.5 text-2xl text-ink">
            {link.label}
          </a>
        </li>
      {/each}
    </ul>
  {/if}
</header>