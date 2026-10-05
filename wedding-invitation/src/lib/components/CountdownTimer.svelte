<script lang="ts">
  interface Props {
    targetIso: string;
  }

  let { targetIso }: Props = $props();

  type TimeLeft = { days: number; hours: number; minutes: number; seconds: number; reached: boolean };

  function calculateTimeLeft(target: number): TimeLeft {
    const diff = target - Date.now();
    if (diff <= 0) return { days: 0, hours: 0, minutes: 0, seconds: 0, reached: true };
    return {
      days: Math.floor(diff / 86400000),
      hours: Math.floor((diff / 3600000) % 24),
      minutes: Math.floor((diff / 60000) % 60),
      seconds: Math.floor((diff / 1000) % 60),
      reached: false
    };
  }

  const targetTime = $derived(new Date(targetIso).getTime());
  let timeLeft = $state<TimeLeft>({ days: 0, hours: 0, minutes: 0, seconds: 0, reached: false });

  $effect(() => {
    timeLeft = calculateTimeLeft(targetTime);
    const interval = setInterval(() => (timeLeft = calculateTimeLeft(targetTime)), 1000);
    return () => clearInterval(interval);
  });

  const units = $derived([
    { label: 'Days', value: timeLeft.days },
    { label: 'Hours', value: timeLeft.hours },
    { label: 'Minutes', value: timeLeft.minutes },
    { label: 'Seconds', value: timeLeft.seconds }
  ]);
</script>

{#if timeLeft.reached}
  <p class="font-display text-2xl italic text-sage-dark">We're celebrating!</p>
{:else}
  <div class="grid grid-cols-4 divide-x divide-line" role="timer" aria-live="off">
    {#each units as unit (unit.label)}
      <div class="px-1 text-center">
        <p class="font-display text-3xl tabular-nums text-ink sm:text-4xl">{String(unit.value).padStart(2, '0')}</p>
        <p class="mt-1 text-[0.55rem] font-semibold uppercase tracking-[0.25em] text-muted sm:text-[0.6rem]">{unit.label}</p>
      </div>
    {/each}
  </div>
{/if}