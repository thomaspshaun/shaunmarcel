import { supabase } from "$lib/supabase";

export type TodoStatus = "not_started" | "in_progress" | "completed";

export interface TodoList {
  id: string;
  title: string;
  sort_order: number;
  created_at: string;
}

export interface TodoTask {
  id: string;
  list_id: string;
  title: string;
  status: TodoStatus;
  sort_order: number;
  created_at: string;
}

export async function fetchTodoLists(): Promise<TodoList[]> {
  const { data, error } = await supabase
    .from("admin_todo_lists")
    .select("*")
    .order("sort_order", { ascending: true })
    .order("created_at", { ascending: true });
  if (error) throw new Error(`Could not load to-do lists: ${error.message}`);
  return data ?? [];
}

export async function fetchTodoTasks(): Promise<TodoTask[]> {
  const { data, error } = await supabase
    .from("admin_todo_items")
    .select("*")
    .order("sort_order", { ascending: true })
    .order("created_at", { ascending: true });
  if (error) throw new Error(`Could not load tasks: ${error.message}`);
  return data ?? [];
}

export async function createTodoList(title: string, sortOrder: number): Promise<TodoList> {
  const { data, error } = await supabase
    .from("admin_todo_lists")
    .insert({ title, sort_order: sortOrder })
    .select("*")
    .single();
  if (error || !data) throw new Error(`Could not create list${error ? `: ${error.message}` : ""}`);
  return data;
}

export async function updateTodoList(id: string, title: string): Promise<void> {
  const { error } = await supabase.from("admin_todo_lists").update({ title }).eq("id", id);
  if (error) throw new Error(`Could not update list: ${error.message}`);
}

export async function deleteTodoList(id: string): Promise<void> {
  const { error } = await supabase.from("admin_todo_lists").delete().eq("id", id);
  if (error) throw new Error(`Could not delete list: ${error.message}`);
}

export async function createTodoTask(
  listId: string,
  title: string,
  sortOrder: number
): Promise<TodoTask> {
  const { data, error } = await supabase
    .from("admin_todo_items")
    .insert({ list_id: listId, title, sort_order: sortOrder })
    .select("*")
    .single();
  if (error || !data) throw new Error(`Could not add task${error ? `: ${error.message}` : ""}`);
  return data;
}

export async function updateTodoTask(
  id: string,
  changes: { title?: string; status?: TodoStatus }
): Promise<void> {
  const { error } = await supabase.from("admin_todo_items").update(changes).eq("id", id);
  if (error) throw new Error(`Could not update task: ${error.message}`);
}

export async function moveTodoTask(
  id: string,
  targetListId: string,
  targetOrder: number
): Promise<void> {
  const { error } = await supabase.rpc("move_admin_todo_item", {
    p_item_id: id,
    p_target_list_id: targetListId,
    p_target_order: targetOrder
  });
  if (error) throw new Error(`Could not move task: ${error.message}`);
}

export async function deleteTodoTask(id: string): Promise<void> {
  const { error } = await supabase.from("admin_todo_items").delete().eq("id", id);
  if (error) throw new Error(`Could not delete task: ${error.message}`);
}
