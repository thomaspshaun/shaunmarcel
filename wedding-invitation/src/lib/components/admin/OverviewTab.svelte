<script lang="ts">
  import UnifiedChecklist from './UnifiedChecklist.svelte';
</script>

<div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
  <h2 class="text-lg font-medium text-slate-900">Wedding Weekend Summary</h2>
  <p class="mt-1 text-sm text-slate-500">Location: Cape Town Estate &amp; Venue</p>

  <div class="mt-5 grid gap-5 sm:grid-cols-3">
    <div>
      <p class="text-xs font-semibold tracking-wide text-rose-500 uppercase">Friday — Arrival Day</p>
      <ul class="mt-2 list-disc space-y-1 pl-4 text-sm text-slate-600">
        <li>Guests arrive in Cape Town.</li>
        <li>Wedding party &amp; selected guests stay at the estate/venue; others at nearby guesthouses.</li>
        <li>Informal welcome supper — guests cover their own meals/drinks.</li>
      </ul>
    </div>
    <div>
      <p class="text-xs font-semibold tracking-wide text-rose-500 uppercase">Saturday — Wedding Day</p>
      <ul class="mt-2 list-disc space-y-1 pl-4 text-sm text-slate-600">
        <li>Late morning: simple wedding party breakfast.</li>
        <li>14:00 welcome drinks, 14:30 ceremony (~3:00pm conclude).</li>
        <li>15:00–16:30 cocktail hour &amp; photos; 16:30 seated; 16:45 entrance.</li>
        <li>Reception: dinner, speeches, dancing until late.</li>
      </ul>
    </div>
    <div>
      <p class="text-xs font-semibold tracking-wide text-rose-500 uppercase">Sunday — Farewell Breakfast</p>
      <ul class="mt-2 list-disc space-y-1 pl-4 text-sm text-slate-600">
        <li>Late morning breakfast at a local restaurant.</li>
        <li>Open to wedding party and any guests wishing to join.</li>
        <li>Guests responsible for their own meals unless stated otherwise.</li>
      </ul>
    </div>
  </div>
</div>

<div class="mt-8">
  <UnifiedChecklist
    slug="master_wedding"
    name="Master Wedding Countdown Checklist"
    category="overview"
    subtitle="Track all planning tasks from engagement through departure"
    placeholder="Add a task..."
  />
</div>
