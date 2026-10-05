<script lang="ts">
  let { class: className = "" }: { class?: string } = $props();
</script>

<!-- Fine botanical divider -->
<svg class={className} viewBox="0 0 160 24" fill="none" stroke="currentColor" stroke-width="0.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
  <path d="M8 12h54M98 12h54" />
  <path d="M80 6l4 6-4 6-4-6z" />
  <path d="M62 12c-3-5-8-6-12-5 2 4 6 6 12 5zM62 12c-3 5-8 6-12 5 2-4 6-6 12-5z" />
  <path d="M98 12c3-5 8-6 12-5-2 4-6 6-12 5zM98 12c3 5 8 6 12 5-2-4-6-6-12-5z" />
  <path d="M42 12c-2-4-6-5-9-4 1 3 5 5 9 4zM42 12c-2 4-6 5-9 4 1-3 5-5 9-4z" />
  <path d="M118 12c2-4 6-5 9-4-1 3-5 5-9 4zM118 12c2 4 6 5 9 4-1-3-5-5-9-4z" />
</svg>