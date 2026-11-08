<script lang="ts">
  import AddToCalendar from '$lib/components/AddToCalendar.svelte';
  import { reveal } from '$lib/actions/reveal';
  import { scheduleEvents, venue } from '$lib/site-config';
  import type { CalendarEvent } from '$lib/utils/calendar';

  const weddingDayInfo = {
    day: 'Thursday',
    date: '1 April',
    title: 'Our Wedding Day',
    description: 'Join us for the ceremony and reception at Eikenhof Estate.'
  };
  const calendarEvent: CalendarEvent = {
    title: "Shaun & Marcel's Wedding",
    description: 'Wedding day programme: arrival and welcome drink from 13:30, ceremony at 14:00.',
    location: venue.address,
    start: new Date(scheduleEvents[0].startIso),
    end: new Date(scheduleEvents[scheduleEvents.length - 1].endIso)
  };
  const updatedItinerary = [
    {
      time: '14:30',
      title: 'The Guests Arrive',
      description: 'Find your seats, grab a smile and get ready for the celebrations!'
    },
    {
      time: '15:00',
      title: 'The “I Do” Moment',
      description: 'The main event! Time for happy tears, big smiles and a little romance.'
    },
    {
      time: '16:00',
      title: 'Cocktails, Photos & Good Times',
      description: 'Sip, mingle, strike a pose and enjoy some well-deserved catching up.'
    },
    {
      time: '18:00',
      title: 'Reception Celebrations',
      description: 'The formalities, speeches and all the special moments.'
    },
    {
      time: '19:00',
      title: 'Let’s Eat!',
      description: 'Good food, great company and plenty of reasons to loosen that belt!'
    },
    {
      time: 'Then…',
      title: 'Let’s Dance!',
      description: 'First dance, followed by a night of music, laughter and questionable dance moves!'
    }
  ];
</script>

<section id="wedding-day" class="mx-auto max-w-3xl px-6 py-24 sm:py-32">
  <div class="text-center" use:reveal>
    <p class="eyebrow">The Programme</p>
    <h2 class="heading mt-4">Our Wedding Day</h2>
  </div>

  <div class="mt-16 sm:mt-20">
    <article class="scroll-mt-24" use:reveal>
      <header class="text-center">
        <p class="eyebrow">{weddingDayInfo.day}</p>
        <p class="mt-1 text-[0.68rem] uppercase tracking-[0.28em] text-muted">{weddingDayInfo.date} 2027</p>
        <h3 class="font-display mt-5 text-4xl font-light text-ink sm:text-5xl">{weddingDayInfo.title}</h3>
        <p class="lede mx-auto mt-4 max-w-md text-sm sm:text-base">{weddingDayInfo.description}</p>
      </header>

      <ol class="mx-auto mt-10 max-w-md border-t border-line/70">
        {#each updatedItinerary as item (item.title)}
          <li class="grid grid-cols-[4.5rem_1rem_1fr] items-start gap-3 border-b border-line/70 py-5 sm:grid-cols-[6rem_1rem_1fr]">
            <span class="font-display text-xl tabular-nums text-sage sm:text-2xl">{item.time}</span>
            <span class="mt-2 h-2.5 w-2.5 rotate-45 border border-ink/70" aria-hidden="true"></span>
            <div>
              <h4 class="text-sm font-medium leading-6 text-ink sm:text-base">{item.title}</h4>
              <p class="mt-1 text-sm leading-6 text-muted">{item.description}</p>
            </div>
          </li>
        {/each}
      </ol>
      <div class="mt-8 flex justify-center">
        <AddToCalendar event={calendarEvent} filename="wedding-day.ics" label="Add to calendar" />
      </div>
    </article>
  </div>
</section>