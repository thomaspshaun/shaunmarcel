<script lang="ts">
  import { onMount } from "svelte";
  import {
    createTodoList,
    createTodoTask,
    deleteTodoList,
    deleteTodoTask,
    fetchTodoLists,
    fetchTodoTasks,
    moveTodoTask,
    updateTodoList,
    updateTodoTask,
    type TodoList,
    type TodoStatus,
    type TodoTask
  } from "$lib/admin-todos";

  let lists: TodoList[] = $state([]);
  let tasks: TodoTask[] = $state([]);
  let loading = $state(true);
  let saving = $state(false);
  let loadError = $state("");
  let actionError = $state("");
  let newListTitle = $state("");
  let newTaskTitles = $state<Record<string, string>>({});
  let editingListId = $state<string | null>(null);
  let editingListTitle = $state("");
  let editingTaskId = $state<string | null>(null);
  let editingTaskTitle = $state("");
  let draggedTaskId = $state<string | null>(null);
  let movingTaskId = $state<string | null>(null);

  const statusOrder: Record<TodoStatus, number> = {
    completed: 0,
    in_progress: 1,
    not_started: 2
  };

  function sortTasks(items: TodoTask[]): TodoTask[] {
    return [...items].sort(
      (a, b) => statusOrder[a.status] - statusOrder[b.status] || a.sort_order - b.sort_order
    );
  }

  function getListTasks(listId: string): TodoTask[] {
    return sortTasks(tasks.filter((task) => task.list_id === listId));
  }

  function statusLabel(status: TodoStatus): string {
    if (status === "completed") return "Completed";
    if (status === "in_progress") return "In progress";
    return "To do";
  }

  onMount(load);

  async function load() {
    loading = true;
    loadError = "";
    try {
      const [loadedLists, loadedTasks] = await Promise.all([fetchTodoLists(), fetchTodoTasks()]);
      lists = loadedLists;
      tasks = loadedTasks;
    } catch (error) {
      loadError = error instanceof Error ? error.message : "Could not load to-do lists.";
    } finally {
      loading = false;
    }
  }

  async function handleCreateList(event: Event) {
    event.preventDefault();
    const title = newListTitle.trim();
    if (!title) return;

    saving = true;
    actionError = "";
    try {
      const created = await createTodoList(title, lists.length);
      lists = [...lists, created];
      newListTitle = "";
    } catch (error) {
      actionError = error instanceof Error ? error.message : "Could not create list.";
    } finally {
      saving = false;
    }
  }

  async function handleRenameList(list: TodoList) {
    const title = editingListTitle.trim();
    if (!title || title === list.title) {
      editingListId = null;
      return;
    }

    actionError = "";
    try {
      await updateTodoList(list.id, title);
      lists = lists.map((item) => item.id === list.id ? { ...item, title } : item);
      editingListId = null;
    } catch (error) {
      actionError = error instanceof Error ? error.message : "Could not rename list.";
    }
  }

  async function handleDeleteList(list: TodoList) {
    if (!confirm(`Delete "${list.title}" and all of its tasks?`)) return;
    actionError = "";
    try {
      await deleteTodoList(list.id);
      lists = lists.filter((item) => item.id !== list.id);
      tasks = tasks.filter((task) => task.list_id !== list.id);
    } catch (error) {
      actionError = error instanceof Error ? error.message : "Could not delete list.";
    }
  }

  async function handleCreateTask(event: Event, list: TodoList) {
    event.preventDefault();
    const title = (newTaskTitles[list.id] ?? "").trim();
    if (!title) return;

    saving = true;
    actionError = "";
    try {
      const listTasks = tasks.filter((task) => task.list_id === list.id);
      const created = await createTodoTask(list.id, title, listTasks.length);
      tasks = [...tasks, created];
      newTaskTitles = { ...newTaskTitles, [list.id]: "" };
    } catch (error) {
      actionError = error instanceof Error ? error.message : "Could not add task.";
    } finally {
      saving = false;
    }
  }

  async function handleSetStatus(task: TodoTask, status: TodoStatus) {
    actionError = "";
    try {
      await updateTodoTask(task.id, { status });
      tasks = tasks.map((item) => item.id === task.id ? { ...item, status } : item);
    } catch (error) {
      actionError = error instanceof Error ? error.message : "Could not update task status.";
    }
  }

  function chooseStatus(event: MouseEvent, task: TodoTask, status: TodoStatus) {
    const menu = event.currentTarget instanceof HTMLElement
      ? event.currentTarget.closest("details")
      : null;
    if (menu) menu.open = false;
    if (task.status !== status) handleSetStatus(task, status);
  }

  function handleMoveListChange(event: Event, task: TodoTask) {
    const select = event.currentTarget;
    if (!(select instanceof HTMLSelectElement) || !select.value || select.value === task.list_id) return;
    const menu = select.closest("details");
    if (menu) menu.open = false;
    handleMoveTask(task.id, select.value, getTargetStatusOrder(task.id, select.value));
    select.value = "";
  }

  async function handleRenameTask(task: TodoTask) {
    const title = editingTaskTitle.trim();
    if (!title || title === task.title) {
      editingTaskId = null;
      return;
    }

    actionError = "";
    try {
      await updateTodoTask(task.id, { title });
      tasks = tasks.map((item) => item.id === task.id ? { ...item, title } : item);
      editingTaskId = null;
    } catch (error) {
      actionError = error instanceof Error ? error.message : "Could not rename task.";
    }
  }

  async function handleDeleteTask(task: TodoTask) {
    if (!confirm(`Delete "${task.title}"?`)) return;
    actionError = "";
    try {
      await deleteTodoTask(task.id);
      tasks = tasks.filter((item) => item.id !== task.id);
    } catch (error) {
      actionError = error instanceof Error ? error.message : "Could not delete task.";
    }
  }

  function handleTaskDragStart(event: DragEvent, task: TodoTask) {
    draggedTaskId = task.id;
    if (event.dataTransfer) {
      event.dataTransfer.effectAllowed = "move";
      event.dataTransfer.setData("text/plain", task.id);
    }
  }

  function handleTaskDragEnd() {
    draggedTaskId = null;
  }

  function handleTaskDragOver(event: DragEvent, listId: string) {
    const draggedTask = tasks.find((task) => task.id === draggedTaskId);
    if (draggedTask && draggedTask.list_id !== listId) event.preventDefault();
  }

  function getTargetStatusOrder(movingId: string, listId: string): number {
    const movingTask = tasks.find((task) => task.id === movingId);
    if (!movingTask) return 0;
    return getListTasks(listId).filter(
      (task) => task.status === movingTask.status && task.id !== movingId
    ).length;
  }

  async function handleDropOnTask(event: DragEvent, list: TodoList, targetTask: TodoTask) {
    event.preventDefault();
    event.stopPropagation();
    const movingId = draggedTaskId ?? event.dataTransfer?.getData("text/plain");
    if (!movingId || movingId === targetTask.id) return;

    const movingTask = tasks.find((task) => task.id === movingId);
    if (movingTask?.list_id !== list.id) {
      await handleMoveTask(movingId, list.id, getTargetStatusOrder(movingId, list.id));
    }
    draggedTaskId = null;
  }

  async function handleDropAtListEnd(event: DragEvent, list: TodoList) {
    event.preventDefault();
    const movingId = draggedTaskId ?? event.dataTransfer?.getData("text/plain");
    if (!movingId) return;
    const movingTask = tasks.find((task) => task.id === movingId);
    if (movingTask?.list_id !== list.id) {
      await handleMoveTask(movingId, list.id, getTargetStatusOrder(movingId, list.id));
    }
    draggedTaskId = null;
  }

  async function handleMoveTask(taskId: string, targetListId: string, targetOrder: number) {
    if (movingTaskId) return;
    const task = tasks.find((item) => item.id === taskId);
    if (!task || task.list_id === targetListId) return;

    const previousTasks = tasks;
    const sourceListId = task.list_id;
    const sourceTasks = getListTasks(sourceListId).filter((item) => item.id !== taskId);
    const targetTasks = getListTasks(targetListId);
    const targetGroup = targetTasks.filter((item) => item.status === task.status);
    const insertionIndex = Math.max(0, Math.min(targetOrder, targetGroup.length));

    const movedTask = { ...task, list_id: targetListId };
    const targetGroupStart = targetTasks.findIndex(
      (item) => statusOrder[item.status] >= statusOrder[task.status]
    );
    const overallInsertIndex = targetGroupStart === -1
      ? targetTasks.length
      : targetGroupStart + insertionIndex;
    const updatedTarget = [...targetTasks];
    updatedTarget.splice(overallInsertIndex, 0, movedTask);

    const untouched = tasks.filter(
      (item) => item.list_id !== sourceListId && item.list_id !== targetListId
    );
    tasks = [
      ...untouched,
      ...sourceTasks.map((item, index) => ({ ...item, sort_order: index })),
      ...updatedTarget.map((item, index) => ({ ...item, sort_order: index }))
    ];

    movingTaskId = taskId;
    actionError = "";
    try {
      await moveTodoTask(taskId, targetListId, insertionIndex);
    } catch (error) {
      tasks = previousTasks;
      actionError = error instanceof Error ? error.message : "Could not move task.";
    } finally {
      movingTaskId = null;
    }
  }
</script>

<section class="mt-8 space-y-6" aria-labelledby="todo-heading">
  <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
    <h2 id="todo-heading" class="text-lg font-medium text-slate-900">To-do lists</h2>
    <p class="mt-1 text-sm text-slate-500">
      Create lists, add tasks, and track progress. Drag tasks to move them between lists;
      the options menu includes keyboard-friendly controls.
    </p>
    <form onsubmit={handleCreateList} class="mt-5 flex flex-wrap gap-2">
      <label class="sr-only" for="new-todo-list">List name</label>
      <input
        id="new-todo-list"
        bind:value={newListTitle}
        maxlength="120"
        placeholder="New list name"
        class="min-w-[12rem] flex-1 rounded-xl border border-slate-300 px-4 py-2.5 text-sm focus:border-rose-400 focus:outline-none"
      />
      <button
        type="submit"
        disabled={!newListTitle.trim() || saving}
        class="rounded-full bg-rose-500 px-5 py-2.5 text-sm font-medium text-white hover:bg-rose-600 disabled:cursor-not-allowed disabled:opacity-60"
      >Add list</button>
    </form>
  </div>

  {#if actionError}
    <p class="rounded-lg bg-red-50 p-3 text-sm text-red-700" role="alert">{actionError}</p>
  {/if}
  {#if loading}
    <p class="text-sm text-slate-500">Loading to-do lists...</p>
  {:else if loadError}
    <p class="rounded-lg bg-red-50 p-3 text-sm text-red-700" role="alert">{loadError}</p>
  {:else if lists.length === 0}
    <p class="rounded-2xl border border-dashed border-slate-300 bg-white p-8 text-center text-sm text-slate-500">
      No lists yet. Create one to get started.
    </p>
  {:else}
    <div class="grid gap-6 lg:grid-cols-2">
      {#each lists as list (list.id)}
        {@const listTasks = getListTasks(list.id)}
        <section class="overflow-visible rounded-2xl border border-slate-200 bg-white shadow-sm" aria-label={list.title}>
          <div class="flex items-center gap-3 border-b border-slate-100 px-5 py-4">
            {#if editingListId === list.id}
              <form
                class="flex min-w-0 flex-1 gap-2"
                onsubmit={(event) => { event.preventDefault(); handleRenameList(list); }}
              >
                <label class="sr-only" for={`list-title-${list.id}`}>List name</label>
                <input
                  id={`list-title-${list.id}`}
                  bind:value={editingListTitle}
                  maxlength="120"
                  class="min-w-0 flex-1 rounded-lg border border-slate-300 px-3 py-2 text-sm font-semibold text-slate-900 focus:border-rose-400 focus:outline-none"
                />
                <button class="text-sm font-medium text-rose-600 hover:underline" type="submit">Save</button>
                <button class="text-sm text-slate-500 hover:underline" type="button" onclick={() => editingListId = null}>Cancel</button>
              </form>
            {:else}
              <h3 class="min-w-0 flex-1 truncate text-base font-semibold text-slate-900">{list.title}</h3>
              <button
                type="button"
                onclick={() => { editingListId = list.id; editingListTitle = list.title; }}
                class="text-sm text-slate-500 hover:text-slate-900"
              >Rename</button>
            {/if}
            <button type="button" onclick={() => handleDeleteList(list)} class="text-sm text-red-600 hover:underline">Delete</button>
          </div>

          <ul
            class="min-h-12 divide-y divide-slate-100 px-5 py-2"
            ondragover={(event) => handleTaskDragOver(event, list.id)}
            ondrop={(event) => handleDropAtListEnd(event, list)}
          >
            {#if listTasks.length === 0}
              <li class="py-2 text-center text-xs text-slate-400">Drop a task here or add one below</li>
            {/if}
            {#each listTasks as task (task.id)}
              <li
                class="grid grid-cols-[auto_auto_minmax(0,1fr)_auto] items-center gap-2 rounded-lg px-2 py-2 {task.status === 'completed'
                  ? 'bg-green-50'
                  : task.status === 'in_progress'
                    ? 'bg-amber-50'
                    : 'bg-white'} {draggedTaskId === task.id ? 'opacity-40' : ''}"
                draggable={movingTaskId === null}
                ondragstart={(event) => handleTaskDragStart(event, task)}
                ondragend={handleTaskDragEnd}
                ondragover={(event) => handleTaskDragOver(event, list.id)}
                ondrop={(event) => handleDropOnTask(event, list, task)}
              >
                <span class="cursor-grab select-none px-1 text-slate-300" aria-hidden="true" title="Drag to another list">⠿</span>
                <details class="relative shrink-0">
                  <summary
                    class="flex h-8 w-8 cursor-pointer list-none items-center justify-center rounded-full focus:outline-none focus:ring-2 focus:ring-rose-300"
                    aria-label={`Change status for ${task.title}. Current status: ${statusLabel(task.status)}`}
                    title={`Status: ${statusLabel(task.status)}`}
                  >
                    <span
                      class="h-3 w-3 rounded-full {task.status === 'completed'
                        ? 'bg-green-500'
                        : task.status === 'in_progress'
                          ? 'bg-amber-500'
                          : 'border border-slate-300 bg-white'}"
                      aria-hidden="true"
                    ></span>
                  </summary>
                  <div class="absolute left-0 z-30 mt-1 w-36 rounded-xl border border-slate-200 bg-white p-1 shadow-lg">
                    {#each [{ value: 'completed', label: 'Completed' }, { value: 'in_progress', label: 'In progress' }, { value: 'not_started', label: 'To do' }] as option (option.value)}
                      <button
                        type="button"
                        disabled={movingTaskId !== null}
                        onclick={(event) => chooseStatus(event, task, option.value as TodoStatus)}
                        class="flex w-full items-center gap-2 rounded-lg px-3 py-2 text-left text-sm hover:bg-slate-50 disabled:opacity-50"
                      >
                        <span
                          class="h-2.5 w-2.5 rounded-full {option.value === 'completed'
                            ? 'bg-green-500'
                            : option.value === 'in_progress'
                              ? 'bg-amber-500'
                              : 'border border-slate-300 bg-white'}"
                          aria-hidden="true"
                        ></span>
                        {option.label}
                        {#if task.status === option.value}<span class="ml-auto" aria-label="Current status">✓</span>{/if}
                      </button>
                    {/each}
                  </div>
                </details>

                {#if editingTaskId === task.id}
                  <form
                    class="flex min-w-0 flex-1 gap-2"
                    onsubmit={(event) => { event.preventDefault(); handleRenameTask(task); }}
                  >
                    <label class="sr-only" for={`task-title-${task.id}`}>Task name</label>
                    <input
                      id={`task-title-${task.id}`}
                      bind:value={editingTaskTitle}
                      maxlength="240"
                      class="min-w-0 flex-1 rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-rose-400 focus:outline-none"
                    />
                    <button class="text-sm font-medium text-rose-600 hover:underline" type="submit">Save</button>
                    <button class="text-sm text-slate-500 hover:underline" type="button" onclick={() => editingTaskId = null}>Cancel</button>
                  </form>
                {:else}
                  <span class="min-w-0 break-words text-sm {task.status === 'completed'
                    ? 'text-slate-400 line-through'
                    : task.status === 'in_progress'
                      ? 'text-amber-900'
                      : 'text-slate-800'}">{task.title}</span>
                {/if}
                <details class="relative shrink-0">
                  <summary
                    class="flex h-8 w-8 cursor-pointer list-none items-center justify-center rounded-full text-lg text-slate-500 hover:bg-black/5 focus:outline-none focus:ring-2 focus:ring-rose-300"
                    aria-label={`More options for ${task.title}`}
                    title="Task options"
                  >⋯</summary>
                  <div class="absolute right-0 z-30 mt-1 max-h-[70vh] w-48 overflow-y-auto rounded-xl border border-slate-200 bg-white p-1 shadow-lg">
                    <button
                      type="button"
                      onclick={() => { editingTaskId = task.id; editingTaskTitle = task.title; }}
                      class="block w-full rounded-lg px-3 py-2 text-left text-sm hover:bg-slate-50"
                    >Edit task</button>
                    {#if lists.length > 1}
                      <label class="block px-3 pt-2 text-xs font-medium text-slate-500" for={`move-task-${task.id}`}>Move to list</label>
                      <select
                        id={`move-task-${task.id}`}
                        value=""
                        disabled={movingTaskId !== null}
                        onchange={(event) => handleMoveListChange(event, task)}
                        class="m-2 w-[calc(100%-1rem)] rounded-lg border border-slate-200 bg-white px-2 py-2 text-sm text-slate-700 disabled:opacity-50"
                      >
                        <option value="">Choose list...</option>
                        {#each lists as destination (destination.id)}
                          {#if destination.id !== task.list_id}
                            <option value={destination.id}>{destination.title}</option>
                          {/if}
                        {/each}
                      </select>
                    {/if}
                    <button
                      type="button"
                      onclick={() => handleDeleteTask(task)}
                      class="block w-full rounded-lg px-3 py-2 text-left text-sm text-red-600 hover:bg-red-50"
                    >Delete task</button>
                  </div>
                </details>
              </li>
            {/each}
          </ul>

          <form onsubmit={(event) => handleCreateTask(event, list)} class="flex gap-2 border-t border-slate-100 bg-slate-50/70 px-5 py-4">
            <label class="sr-only" for={`new-task-${list.id}`}>Add a task to {list.title}</label>
            <input
              id={`new-task-${list.id}`}
              value={newTaskTitles[list.id] ?? ""}
              oninput={(event) => newTaskTitles = { ...newTaskTitles, [list.id]: event.currentTarget.value }}
              maxlength="240"
              placeholder="Add a task..."
              class="min-w-0 flex-1 rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm focus:border-rose-400 focus:outline-none"
            />
            <button
              type="submit"
              disabled={!(newTaskTitles[list.id] ?? "").trim() || saving}
              class="rounded-lg px-3 py-2 text-sm font-medium text-rose-700 hover:bg-rose-50 disabled:cursor-not-allowed disabled:opacity-50"
            >Add</button>
          </form>
        </section>
      {/each}
    </div>
  {/if}
</section>
