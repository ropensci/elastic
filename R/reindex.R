#' @title Reindex
#'
#' @description Reindex all documents from one index to another.
#'
#' @export
#' @name reindex
#' @param conn an Elasticsearch connection object, see [connect()]
#' @param body (list/character/json) The search definition using the Query DSL 
#' and the prototype for the index request.
#' @param refresh (logical) Should the effected indexes be refreshed?
#' @param requests_per_second (integer) The throttle to set on this request in 
#' sub-requests per second. - 1 means no throttle. Default: 0
#' @param slices (integer) The number of slices this task should be divided 
#' into. Defaults to 1 meaning the task isn't sliced into subtasks. Default: 1
#' @param timeout (character) Time each individual bulk request should wait 
#' for shards that are unavailable. Default: '1m'
#' @param wait_for_active_shards (integer) Sets the number of shard copies that 
#' must be active before proceeding with the reindex operation. Defaults to 1, 
#' meaning the primary shard only. Set to all for all shard copies, otherwise 
#' set to any non-negative value less than or equal to the total number of 
#' copies for the shard (number of replicas + 1)
#' @param wait_for_completion (logical) Should the request block until the 
#' reindex is complete? Default: `TRUE`
#' @param ... Curl options, passed on to [crul::verb-POST]
#'
#' @references
#' <https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-reindex.html>
#'
#' @examples \dontrun{
#' x <- connect()
#' 
#' if (!index_exists(x, "twitter")) index_create(x, "twitter")
#' if (!index_exists(x, "new_twitter")) index_create(x, "new_twitter")
#' body <- '{
#'   "source": {
#'     "index": "twitter"
#'   },
#'   "dest": {
#'     "index": "new_twitter"
#'   }
#' }'
#' reindex(x, body = body)
#' }
reindex <- function(conn, body, refresh = NULL, requests_per_second = NULL,
                    slices = NULL, timeout = NULL, 
                    wait_for_active_shards = NULL,
                    wait_for_completion = NULL, ...) {
  
  is_conn(conn)
  url <- file.path(conn$make_url(), "_reindex")
  args <- ec(list(refresh = refresh, requests_per_second = requests_per_second,
                  slices = slices, timeout = timeout, 
                  wait_for_active_shards = wait_for_active_shards,
                  wait_for_completion = wait_for_completion))
  reindex_POST(conn, url, args, body, ...)
}

reindex_POST <- function(conn, url, args = NULL, body = list(), ...) {
  body <- check_inputs(body)
  tt <- conn$make_conn(url, json_type(), ...)$post(
    body = body, query = args, encode = 'json'
  )
  geterror(conn, tt)
  if (conn$warn) catch_warnings(tt)
  jsonlite::fromJSON(tt$parse("UTF-8"), FALSE)
}
