<script lang="ts">
  import ScheduleEditor from './ScheduleEditor.svelte';
  import GenericChecklist from './GenericChecklist.svelte';
</script>

<div class="space-y-8">
  <ScheduleEditor />

  <GenericChecklist
    tableName="ceremony_checklist"
    title="Ceremony Checklist"
    subtitle="Track all ceremony-day tasks and timings"
    placeholder="Add a task..."
  />
</div>
