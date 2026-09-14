<script lang="ts">
  import AddToCalendar from '$lib/components/AddToCalendar.svelte';
  import { scheduleEvents, venue } from '$lib/site-config';
  import type { CalendarEvent } from '$lib/utils/calendar';

  function toCalendarEvent(item: (typeof scheduleEvents)[number]): CalendarEvent {
    return {
      title: `${item.title} — Shaun & Marcel's Wedding`,
      description: item.description,
      location: venue.address,
      start: new Date(item.startIso),
      end: new Date(item.endIso)
    };
  }

  const fullDayEvent: CalendarEvent = {
    title: "Shaun & Marcel's Wedding",
    description: 'Join us for the full day of celebrations.',
    location: venue.address,
    start: new Date(scheduleEvents[0].startIso),
    end: new Date(scheduleEvents[scheduleEvents.length - 1].endIso)
  };
</script>

<section id="schedule" class="mx-auto max-w-3xl px-6 py-20">
  <div class="text-center">
    <p class="text-xs font-semibold uppercase tracking-[0.4em] text-rose-500 sm:text-sm">
      Wedding Day
    </p>
    <h2 class="mt-4 text-3xl font-light tracking-tight text-slate-900 sm:text-4xl">Schedule</h2>
  </div>

  <div class="mt-8 flex justify-center">
    <AddToCalendar event={fullDayEvent} filename="wedding-day.ics" label="Add Full Day to Calendar" />
  </div>

  <ol class="mt-12 space-y-8 border-l border-slate-200 pl-8">
    {#each scheduleEvents as item (item.id)}
      <li class="relative">
        <span
          class="absolute top-1.5 -left-[calc(2rem+5px)] h-3 w-3 rounded-full border-2 border-white bg-rose-400 shadow"
          aria-hidden="true"
        ></span>

        <p class="text-xs font-semibold tracking-[0.2em] text-rose-500 uppercase">{item.time}</p>
        <h3 class="mt-1 text-xl font-medium text-slate-900">{item.title}</h3>
        <p class="mt-1 text-sm leading-6 text-slate-600 sm:text-base">{item.description}</p>

        <div class="mt-3">
          <AddToCalendar
            event={toCalendarEvent(item)}
            filename={`${item.id}.ics`}
            label="Add to Calendar"
          />
        </div>
      </li>
    {/each}
  </ol>
</section>
