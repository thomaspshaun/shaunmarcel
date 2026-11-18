<script lang="ts">
  import { onMount } from "svelte";
  import {
    createTodoList,
    createTodoTask,
    deleteTodoList,
    deleteTodoTask,
    fetchTodoLists,
    fetchTodoTasks,
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
</script>

<section class="mt-8 space-y-6" aria-labelledby="todo-heading">
  <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
    <h2 id="todo-heading" class="text-lg font-medium text-slate-900">To-do lists</h2>
    <p class="mt-1 text-sm text-slate-500">Create lists, add tasks, and track each task's progress.</p>
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
        {@const listTasks = tasks.filter((task) => task.list_id === list.id)}
        <section class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm" aria-label={list.title}>
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

          <ul class="divide-y divide-slate-100 px-5">
            {#each listTasks as task (task.id)}
              <li class="flex items-center gap-3 py-3">
                <label class="sr-only" for={`task-status-${task.id}`}>Status for {task.title}</label>
                <select
                  id={`task-status-${task.id}`}
                  value={task.status}
                  onchange={(event) => handleSetStatus(task, event.currentTarget.value as TodoStatus)}
                  class="max-w-[9.5rem] rounded-lg border px-2 py-2 text-xs font-medium focus:outline-none focus:ring-2 focus:ring-rose-200 {task.status === 'completed'
                    ? 'border-green-200 bg-green-50 text-green-800'
                    : task.status === 'in_progress'
                      ? 'border-amber-200 bg-amber-50 text-amber-800'
                      : 'border-slate-200 bg-white text-slate-700'}"
                >
                  <option value="not_started">Not started</option>
                  <option value="in_progress">In progress</option>
                  <option value="completed">Completed</option>
                </select>

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
                  <span class="min-w-0 flex-1 break-words text-sm {task.status === 'completed'
                    ? 'text-slate-400 line-through'
                    : task.status === 'in_progress'
                      ? 'text-amber-900'
                      : 'text-slate-800'}">{task.title}</span>
                  <button
                    type="button"
                    onclick={() => { editingTaskId = task.id; editingTaskTitle = task.title; }}
                    class="text-sm text-slate-500 hover:text-slate-900"
                    aria-label={`Edit ${task.title}`}
                  >Edit</button>
                {/if}
                <button
                  type="button"
                  onclick={() => handleDeleteTask(task)}
                  class="text-lg leading-none text-slate-400 hover:text-red-600"
                  aria-label={`Delete ${task.title}`}
                >×</button>
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
