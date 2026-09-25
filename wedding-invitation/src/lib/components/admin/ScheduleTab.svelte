<script lang="ts">
  import ScheduleEditor from './ScheduleEditor.svelte';
  import UnifiedChecklist from './UnifiedChecklist.svelte';
</script>

<div class="space-y-8">
  <ScheduleEditor />

  <UnifiedChecklist
    slug="ceremony"
    name="Ceremony Checklist"
    category="ceremony"
    subtitle="Track all ceremony-day tasks and timings"
    placeholder="Add a task..."
  />
</div>
