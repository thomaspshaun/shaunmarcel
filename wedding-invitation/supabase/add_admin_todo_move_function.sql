CREATE OR REPLACE FUNCTION public.move_admin_todo_item(
  p_item_id uuid,
  p_target_list_id uuid,
  p_target_order integer
)
RETURNS void
LANGUAGE plpgsql
SET search_path = public
AS $$
DECLARE
  v_source_list_id uuid;
  v_current_list_id uuid;
  v_item_status text;
  v_current_status text;
  v_target_order integer;
  v_target_count integer;
  v_item_id uuid;
  v_row record;
  v_sort_order integer;
  v_group_order integer;
  v_item_rank integer;
  v_row_rank integer;
  v_row_status text;
  v_inserted boolean;
BEGIN
  SELECT list_id
       , status
  INTO v_source_list_id
       , v_item_status
  FROM public.admin_todo_items
  WHERE id = p_item_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Task not found';
  END IF;

  PERFORM id
  FROM public.admin_todo_lists
  WHERE id IN (v_source_list_id, p_target_list_id)
  ORDER BY id
  FOR UPDATE;

  SELECT list_id
       , status
  INTO v_current_list_id
       , v_current_status
  FROM public.admin_todo_items
  WHERE id = p_item_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Task not found';
  END IF;

  IF v_current_list_id <> v_source_list_id THEN
    RAISE EXCEPTION 'Task list changed; refresh and try again';
  END IF;
  IF v_current_status <> v_item_status THEN
    RAISE EXCEPTION 'Task status changed; refresh and try again';
  END IF;
  IF v_source_list_id = p_target_list_id THEN
    RAISE EXCEPTION 'Choose a different list to move this task';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.admin_todo_lists WHERE id = p_target_list_id
  ) THEN
    RAISE EXCEPTION 'Destination list not found';
  END IF;

  SELECT count(*)::integer
  INTO v_target_count
  FROM public.admin_todo_items
  WHERE list_id = p_target_list_id
    AND id <> p_item_id
    AND status = v_item_status;

  v_target_order := GREATEST(0, LEAST(COALESCE(p_target_order, v_target_count), v_target_count));

  IF v_source_list_id <> p_target_list_id THEN
    v_sort_order := 0;
    FOR v_item_id IN
      SELECT id
      FROM public.admin_todo_items
      WHERE list_id = v_source_list_id AND id <> p_item_id
      ORDER BY
        CASE status WHEN 'completed' THEN 0 WHEN 'in_progress' THEN 1 ELSE 2 END,
        sort_order, created_at, id
    LOOP
      UPDATE public.admin_todo_items SET sort_order = v_sort_order WHERE id = v_item_id;
      v_sort_order := v_sort_order + 1;
    END LOOP;
  END IF;

  UPDATE public.admin_todo_items
  SET list_id = p_target_list_id, sort_order = -1
  WHERE id = p_item_id;

  v_sort_order := 0;
  v_group_order := 0;
  v_item_rank := CASE v_item_status WHEN 'completed' THEN 0 WHEN 'in_progress' THEN 1 ELSE 2 END;
  v_inserted := false;
  FOR v_row IN
    SELECT id, status
    FROM public.admin_todo_items
    WHERE list_id = p_target_list_id AND id <> p_item_id
    ORDER BY
      CASE status WHEN 'completed' THEN 0 WHEN 'in_progress' THEN 1 ELSE 2 END,
      sort_order, created_at, id
  LOOP
    v_item_id := v_row.id;
    v_row_status := v_row.status;
    v_row_rank := CASE v_row_status WHEN 'completed' THEN 0 WHEN 'in_progress' THEN 1 ELSE 2 END;

    IF NOT v_inserted
      AND (v_row_rank > v_item_rank OR (v_row_rank = v_item_rank AND v_group_order = v_target_order))
    THEN
      UPDATE public.admin_todo_items SET sort_order = v_sort_order WHERE id = p_item_id;
      v_sort_order := v_sort_order + 1;
      v_inserted := true;
    END IF;

    UPDATE public.admin_todo_items SET sort_order = v_sort_order WHERE id = v_item_id;
    v_sort_order := v_sort_order + 1;
    IF v_row_rank = v_item_rank THEN
      v_group_order := v_group_order + 1;
    END IF;
  END LOOP;

  IF NOT v_inserted THEN
    UPDATE public.admin_todo_items SET sort_order = v_sort_order WHERE id = p_item_id;
  END IF;
END;
$$;

REVOKE ALL ON FUNCTION public.move_admin_todo_item(uuid, uuid, integer) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.move_admin_todo_item(uuid, uuid, integer) TO authenticated;
