#' Elasticsearch tasks endpoints
#'
#' @name tasks
#' @param task_id a task id
#' @param node_id a node id
#' @param nodes (character) The nodes
#' @param actions (character) Actions
#' @param parent_task_id (character) A parent task ID
#' @param detailed (character) get detailed results. Default: FALSE
#' @param group_by (character) "nodes" (default, i.e., NULL) or "parents"
#' @param wait_for_completion (logical) wait for completion. Default: FALSE
#' @param timeout (integer) timeout time
#' @param raw If TRUE (default), data is parsed to list. If FALSE, then
#' raw JSON.
#' @param ... Curl args passed on to \code{\link[httr]{GET}} or 
#' \code{\link[httr]{POST}}
#'
#' @references 
#' \url{https://www.elastic.co/guide/en/elasticsearch/reference/current/tasks.html}
#'
#' @examples \dontrun{
#' connect()
#' 
#' tasks()
#' # tasks(parent_task_id = "1234")
#' 
#' # delete a task
#' # tasks_cancel()
#' }

#' @export
#' @rdname tasks
tasks <- function(task_id = NULL, nodes = NULL, actions = NULL, 
  parent_task_id = NULL, detailed = FALSE, group_by = NULL,
  wait_for_completion = FALSE, timeout = NULL, raw = FALSE, ...) {
  
  if (!is.null(parent_task_id)) {
    parent_task_id <- paste0("parentTaskId:", parent_task_id)
  }
  args <- ec(list(
    actions = actions, nodes = nodes, parent_task_id = parent_task_id,
    detailed = if (detailed) "" else NULL, group_by = group_by,
    wait_for_completion = as_log(wait_for_completion), timeout = timeout
  ))
  task_GET(task_id, raw, args, ...)
}

#' @export
#' @rdname tasks
tasks_cancel <- function(node_id = NULL, task_id = NULL, nodes = NULL, 
  actions = NULL, parent_task_id = NULL, detailed = FALSE, group_by = NULL,
  wait_for_completion = FALSE, timeout = NULL, raw = FALSE, ...) {
  
  if (!is.null(parent_task_id)) {
    parent_task_id <- paste0("parentTaskId:", parent_task_id)
  }
  args <- ec(list(
    actions = actions, nodes = nodes, parent_task_id = parent_task_id,
    detailed = if (detailed) "" else NULL, group_by = group_by,
    wait_for_completion = wait_for_completion, timeout = timeout
  ))
  task_POST(node_id, task_id, raw, args, ...)
}



task_GET <- function(task_id = NULL, raw, args, ...) {
  url <- make_url(es_get_auth())
  url <- file.path(url, '_tasks')
  if (!is.null(task_id)) url <- file.path(url, paste0("task_id:", task_id))
  if (length(args) == 0) args <- NULL
  tt <- GET(url, query = args, make_up(), es_env$headers, ...)
  if (tt$status_code > 202) geterror(tt)
  res <- cont_utf8(tt)
  if (raw) res else jsonlite::fromJSON(res, FALSE)
}

task_POST <- function(node_id = NULL, task_id = NULL, raw, args, ...) {
  url <- make_url(es_get_auth())
  if (!is.null(node_id) && !is.null(task_id)) {
    url <- file.path(url, '_tasks', 
                     paste(node_id, task_id, sep = ":", collapse = ""), 
                     "_cancel")
  } else {
    url <- file.path(url, '_tasks', "_cancel") 
  }
  if (length(args) == 0) args <- NULL
  tt <- POST(url, query = args, make_up(), es_env$headers, ...)
  if (tt$status_code > 202) geterror(tt)
  res <- cont_utf8(tt)
  if (raw) res else jsonlite::fromJSON(res, FALSE)
}
