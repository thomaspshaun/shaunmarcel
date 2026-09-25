<script lang="ts">
  import ChecklistSection from './ChecklistSection.svelte';
  import NotesFields from './NotesFields.svelte';
  import { fridaySupperFields, sundayBreakfastFields } from '$lib/planner-templates';
</script>

<div class="space-y-10">
  <section>
    <h2 class="text-lg font-medium text-slate-900">Friday — Arrival Day</h2>
    <div class="mt-3 grid gap-4 lg:grid-cols-2">
      <ChecklistSection section="friday_arrival" title="Arrival Plan" />
      <div class="space-y-4">
        <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
          <h3 class="text-base font-medium text-slate-900">Welcome Supper Details</h3>
          <div class="mt-3">
            <NotesFields fields={fridaySupperFields} />
          </div>
          <p class="mt-3 text-xs text-slate-500">Note: guests pay for their own meals and beverages.</p>
        </div>
        <ChecklistSection section="friday_supper" title="Welcome Supper Checklist" />
      </div>
    </div>
  </section>

  <section>
    <h2 class="text-lg font-medium text-slate-900">Saturday — Wedding Day Run Sheet</h2>
    <div class="mt-3 grid gap-4 lg:grid-cols-2">
      <ChecklistSection section="saturday_morning" title="Morning" />
      <ChecklistSection section="saturday_afternoon" title="Afternoon — Drinks, Ceremony & Cocktail Hour" />
    </div>
    <div class="mt-4">
      <ChecklistSection section="saturday_reception" title="Reception — Seating Through Evening Celebration" />
    </div>
  </section>

  <section>
    <h2 class="text-lg font-medium text-slate-900">Sunday — Farewell Breakfast</h2>
    <div class="mt-3 grid gap-4 lg:grid-cols-2">
      <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
        <h3 class="text-base font-medium text-slate-900">Farewell Gathering Details</h3>
        <div class="mt-3">
          <NotesFields fields={sundayBreakfastFields} />
        </div>
      </div>
      <ChecklistSection section="sunday_farewell" title="Checklist & Wrap-Up" />
    </div>
    <p class="mt-3 text-xs text-slate-500">
      Attendance for the farewell breakfast is tracked per-guest on the Guests tab (Sunday Breakfast column).
    </p>
  </section>
</div>
