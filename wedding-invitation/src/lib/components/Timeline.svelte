<script lang="ts">
  import AddToCalendar from '$lib/components/AddToCalendar.svelte';
  import Sprig from '$lib/components/Sprig.svelte';
  import { reveal } from '$lib/actions/reveal';
  import { scheduleEvents, weekend, venue } from '$lib/site-config';
  import type { CalendarEvent } from '$lib/utils/calendar';

  const weddingDay: CalendarEvent = {
    title: "Shaun & Marcel's Wedding",
    description: 'Wedding day programme: arrival and welcome drink from 13:30, ceremony at 14:00.',
    location: venue.address,
    start: new Date(scheduleEvents[0].startIso),
    end: new Date(scheduleEvents[scheduleEvents.length - 1].endIso)
  };
</script>

<section id="weekend" class="mx-auto max-w-3xl px-6 py-24 sm:py-32">
  <div class="text-center" use:reveal>
    <p class="eyebrow">The Programme</p>
    <h2 class="heading mt-4">Our Weekend</h2>
  </div>

  <div class="mt-16 sm:mt-20">
    {#each weekend as day, i (day.id)}
      <article id={day.id === 'saturday' ? 'wedding' : undefined} class="scroll-mt-24" use:reveal>
        <header class="text-center">
          <p class="eyebrow">{day.day}</p>
          <p class="mt-1 text-[0.68rem] uppercase tracking-[0.28em] text-muted">{day.date} 2027</p>
          <h3 class="font-display mt-5 text-4xl font-light text-ink sm:text-5xl">{day.title}</h3>
          <p class="lede mx-auto mt-4 max-w-md text-sm sm:text-base">{day.description}</p>
        </header>

        {#if day.id === 'saturday'}
          <ol class="mx-auto mt-10 max-w-md border-t border-line/70">
            {#each scheduleEvents as item (item.id)}
              <li class="grid grid-cols-[4.5rem_1fr] items-baseline gap-4 border-b border-line/70 py-4 sm:grid-cols-[6rem_1fr]">
                <span class="font-display text-2xl tabular-nums text-sage">{item.time}</span>
                <span class="text-sm leading-6 text-ink sm:text-base">{item.title}</span>
              </li>
            {/each}
          </ol>
          <div class="mt-8 flex justify-center">
            <AddToCalendar event={weddingDay} filename="wedding-day.ics" label="Add to calendar" />
          </div>
        {:else if day.note}
          <p class="eyebrow eyebrow-accent mt-8 text-center">{day.note}</p>
        {/if}
      </article>

      {#if i < weekend.length - 1}
        <Sprig class="mx-auto my-16 h-5 w-32 text-champagne sm:my-20" />
      {/if}
    {/each}
  </div>
</section>