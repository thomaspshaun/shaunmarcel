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
    class="inline-flex items-center gap-2 rounded-full border border-slate-300 px-5 py-2 text-sm font-medium text-slate-700 transition hover:border-slate-400 hover:bg-slate-50"
    aria-haspopup="true"
    aria-expanded={open}
  >
    <span aria-hidden="true">📅</span>
    {label}
  </button>

  {#if open}
    <div
      class="absolute z-20 mt-2 w-56 overflow-hidden rounded-xl border border-slate-200 bg-white text-left shadow-lg"
    >
      <a
        href={googleCalendarUrl(event)}
        target="_blank"
        rel="noopener noreferrer"
        class="block px-4 py-3 text-sm text-slate-700 hover:bg-slate-50"
        onclick={close}
      >
        Google Calendar
      </a>
      <button
        type="button"
        onclick={handleDownload}
        class="block w-full px-4 py-3 text-left text-sm text-slate-700 hover:bg-slate-50"
      >
        Apple Calendar (.ics)
      </button>
      <button
        type="button"
        onclick={handleDownload}
        class="block w-full border-t border-slate-100 px-4 py-3 text-left text-sm text-slate-700 hover:bg-slate-50"
      >
        Outlook (.ics)
      </button>
    </div>
  {/if}
</div>
