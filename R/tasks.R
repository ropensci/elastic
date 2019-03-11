#' Elasticsearch tasks endpoints
#'
#' @name tasks
#' @param conn an Elasticsearch connection object, see [connect()]
#' @param task_id a task id
#' @param node_id a node id
#' @param nodes (character) The nodes
#' @param actions (character) Actions
#' @param parent_task_id (character) A parent task ID
#' @param detailed (character) get detailed results. Default: `FALSE`
#' @param group_by (character) "nodes" (default, i.e., NULL) or "parents"
#' @param wait_for_completion (logical) wait for completion. Default: `FALSE`
#' @param timeout (integer) timeout time
#' @param raw If `TRUE` (default), data is parsed to list. If `FALSE`, then
#' raw JSON.
#' @param ... Curl args passed on to [crul::verb-GET] or 
#' [crul::verb-POST]
#'
#' @references 
#' <https://www.elastic.co/guide/en/elasticsearch/reference/current/tasks.html>
#'
#' @examples \dontrun{
#' x <- connect()
#' 
#' tasks(x)
#' # tasks(x, parent_task_id = "1234")
#' 
#' # delete a task
#' # tasks_cancel(x)
#' }

#' @export
#' @rdname tasks
tasks <- function(conn, task_id = NULL, nodes = NULL, actions = NULL, 
  parent_task_id = NULL, detailed = FALSE, group_by = NULL,
  wait_for_completion = FALSE, timeout = NULL, raw = FALSE, ...) {
  
  is_conn(conn)
  if (!is.null(parent_task_id)) {
    parent_task_id <- paste0("parentTaskId:", parent_task_id)
  }
  args <- ec(list(
    actions = actions, nodes = nodes, parent_task_id = parent_task_id,
    detailed = if (detailed) "" else NULL, group_by = group_by,
    wait_for_completion = as_log(wait_for_completion), timeout = timeout
  ))
  task_GET(conn, task_id, raw, args, ...)
}

#' @export
#' @rdname tasks
tasks_cancel <- function(conn, node_id = NULL, task_id = NULL, nodes = NULL, 
  actions = NULL, parent_task_id = NULL, detailed = FALSE, group_by = NULL,
  wait_for_completion = FALSE, timeout = NULL, raw = FALSE, ...) {
  
  is_conn(conn)
  if (!is.null(parent_task_id)) {
    parent_task_id <- paste0("parentTaskId:", parent_task_id)
  }
  args <- ec(list(
    actions = actions, nodes = nodes, parent_task_id = parent_task_id,
    detailed = if (detailed) "" else NULL, group_by = group_by,
    wait_for_completion = wait_for_completion, timeout = timeout
  ))
  task_POST(conn, node_id, task_id, raw, args, ...)
}



task_GET <- function(conn, task_id = NULL, raw, args, ...) {
  url <- file.path(conn$make_url(), '_tasks')
  if (!is.null(task_id)) url <- file.path(url, paste0("task_id:", task_id))
  if (length(args) == 0) args <- NULL
  tt <- conn$make_conn(url, list(), ...)$get(query = args)
  if (tt$status_code > 202) geterror(conn, tt)
  res <- tt$parse("UTF-8")
  if (raw) res else jsonlite::fromJSON(res, FALSE)
}

task_POST <- function(conn, node_id = NULL, task_id = NULL, raw, args, ...) {
  url <- conn$make_url()
  if (!is.null(node_id) && !is.null(task_id)) {
    url <- file.path(url, '_tasks', 
                     paste(node_id, task_id, sep = ":", collapse = ""), 
                     "_cancel")
  } else {
    url <- file.path(url, '_tasks', "_cancel") 
  }
  if (length(args) == 0) args <- NULL
  tt <- conn$make_conn(url, list(), ...)$post(query = args)
  if (tt$status_code > 202) geterror(conn, tt)
  res <- tt$parse("UTF-8")
  if (raw) res else jsonlite::fromJSON(res, FALSE)
}
