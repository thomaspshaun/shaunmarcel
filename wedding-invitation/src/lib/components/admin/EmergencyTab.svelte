<script lang="ts">
  import GenericChecklist from './GenericChecklist.svelte';
  import NotesFields from './NotesFields.svelte';
  import { emergencyContactFields, quickReferenceFields } from '$lib/planner-templates';
</script>

<div class="grid gap-6 lg:grid-cols-2">
  <GenericChecklist
    tableName="emergency_kit_checklist"
    title="Wedding Emergency Kit"
    subtitle="Stock emergency supplies and pack essentials"
    placeholder="Add an item..."
  />

  <div class="space-y-6">
    <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
      <h3 class="text-base font-medium text-slate-900">Vendor Contacts (Mobile Numbers)</h3>
      <div class="mt-3">
        <NotesFields fields={emergencyContactFields} />
      </div>
    </div>

    <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
      <h3 class="text-base font-medium text-slate-900">Important Numbers — Quick Reference</h3>
      <div class="mt-3">
        <NotesFields fields={quickReferenceFields} />
      </div>
    </div>
  </div>
</div>
