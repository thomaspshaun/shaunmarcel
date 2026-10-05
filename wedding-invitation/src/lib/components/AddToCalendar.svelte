<script lang="ts">
  import { downloadICS, googleCalendarUrl, type CalendarEvent } from '$lib/utils/calendar';

  interface Props {
    event: CalendarEvent;
    filename?: string;
    label?: string;
  }

  let { event, filename = 'wedding-event.ics', label = 'Add to Calendar' }: Props = $props();

  let open = $state(false);

  function toggle() {
    open = !open;
  }

  function close() {
    open = false;
  }

  function handleDownload() {
    downloadICS(event, filename);
    close();
  }
</script>

<svelte:window onclick={close} />

<div class="relative inline-block text-left" onclick={(e) => e.stopPropagation()} role="presentation">
  <button
    type="button"
    onclick={toggle}
    class="btn-ghost"
    aria-haspopup="true"
    aria-expanded={open}
  >
    {label}
  </button>

  {#if open}
    <div
      class="absolute left-1/2 z-20 mt-2 w-60 -translate-x-1/2 border border-line bg-surface text-left"
    >
      <a
        href={googleCalendarUrl(event)}
        target="_blank"
        rel="noopener noreferrer"
        class="block px-4 py-3.5 text-sm text-ink hover:bg-paper-2"
        onclick={close}
      >
        Google Calendar
      </a>
      <button
        type="button"
        onclick={handleDownload}
        class="block w-full px-4 py-3 text-left text-sm text-ink hover:bg-paper-2"
      >
        Apple Calendar (.ics)
      </button>
      <button
        type="button"
        onclick={handleDownload}
        class="block w-full border-t border-line px-4 py-3 text-left text-sm text-ink hover:bg-paper-2"
      >
        Outlook (.ics)
      </button>
    </div>
  {/if}
</div>
