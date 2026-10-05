<script lang="ts">
  import { navLinks, site } from '$lib/site-config';

  let mobileOpen = $state(false);

  function closeMobileMenu() {
    mobileOpen = false;
  }
</script>

<header class="sticky top-0 z-50 border-b border-[var(--color-border)]/80 bg-[var(--color-background)]/95 backdrop-blur-sm">
  <nav class="mx-auto flex max-w-6xl items-center justify-between px-6 py-5">
    <a href="#hero" class="font-display text-2xl tracking-wide text-[var(--color-text)]" onclick={closeMobileMenu}>
      {site.coupleNames}
    </a>

    <!-- Desktop nav -->
    <ul class="hidden items-center gap-8 text-[0.65rem] font-semibold uppercase tracking-[0.2em] text-[var(--color-text-muted)] sm:flex">
      {#each navLinks as link (link.href)}
        <li>
          <a href={link.href} class="transition hover:text-[var(--color-primary)]">{link.label}</a>
        </li>
      {/each}
    </ul>

    <!-- Mobile menu toggle -->
    <button
      type="button"
      class="flex h-10 w-10 items-center justify-center rounded-none border border-[var(--color-border)] text-[var(--color-text)] sm:hidden"
      aria-label="Toggle navigation menu"
      aria-expanded={mobileOpen}
      onclick={() => (mobileOpen = !mobileOpen)}
    >
      {#if mobileOpen}
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
        </svg>
      {:else}
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16" />
        </svg>
      {/if}
    </button>
  </nav>

  <!-- Mobile menu panel -->
  {#if mobileOpen}
    <ul class="flex flex-col gap-1 border-t border-[var(--color-border)] bg-[var(--color-surface)] px-6 py-4 text-sm font-medium text-slate-700 sm:hidden">
      {#each navLinks as link (link.href)}
        <li>
          <a
            href={link.href}
            class="block rounded-lg px-3 py-2 transition hover:bg-rose-50 hover:text-rose-500"
            onclick={closeMobileMenu}
          >
            {link.label}
          </a>
        </li>
      {/each}
    </ul>
  {/if}
</header>

