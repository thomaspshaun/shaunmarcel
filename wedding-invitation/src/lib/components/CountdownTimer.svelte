<script lang="ts">
  interface Props {
    targetIso: string;
  }

  let { targetIso }: Props = $props();

  type TimeLeft = {
    days: number;
    hours: number;
    minutes: number;
    seconds: number;
    reached: boolean;
  };

  function calculateTimeLeft(target: number): TimeLeft {
    const diff = target - Date.now();

    if (diff <= 0) {
      return { days: 0, hours: 0, minutes: 0, seconds: 0, reached: true };
    }

    const days = Math.floor(diff / (1000 * 60 * 60 * 24));
    const hours = Math.floor((diff / (1000 * 60 * 60)) % 24);
    const minutes = Math.floor((diff / (1000 * 60)) % 60);
    const seconds = Math.floor((diff / 1000) % 60);

    return { days, hours, minutes, seconds, reached: false };
  }

  const targetTime = $derived(new Date(targetIso).getTime());
  let timeLeft = $state<TimeLeft>({ days: 0, hours: 0, minutes: 0, seconds: 0, reached: false });

  $effect(() => {
    timeLeft = calculateTimeLeft(targetTime);

    const interval = setInterval(() => {
      timeLeft = calculateTimeLeft(targetTime);
    }, 1000);

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
  <p class="text-lg font-medium text-rose-600">We're celebrating!</p>
{:else}
  <div class="grid grid-cols-4 gap-3 sm:gap-4" role="timer" aria-live="polite">
    {#each units as unit (unit.label)}
      <div class="rounded-2xl bg-white/80 px-2 py-3 text-center shadow-sm ring-1 ring-rose-100 sm:px-4 sm:py-4">
        <p class="font-mono text-xl font-semibold tabular-nums text-slate-900 sm:text-3xl">
          {String(unit.value).padStart(2, '0')}
        </p>
        <p class="mt-1 text-[10px] uppercase tracking-[0.2em] text-slate-500 sm:text-xs">{unit.label}</p>
      </div>
    {/each}
  </div>
{/if}
