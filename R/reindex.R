#' @title Reindex
#'
#' @description Reindex all documents from one index to another.
#'
#' @export
#' @name reindex
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
#' reindex is complete? Default: \code{TRUE}
#' @param ... Curl options, passed on to \code{\link[httr]{POST}}
#'
#' @references
#' \url{https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-reindex.html}
#'
#' @examples \dontrun{
#' if (!index_exists("twitter")) index_create("twitter")
#' if (!index_exists("new_twitter")) index_create("new_twitter")
#' body <- '{
#'   "source": {
#'     "index": "twitter"
#'   },
#'   "dest": {
#'     "index": "new_twitter"
#'   }
#' }'
#' reindex(body = body)
#' }
reindex <- function(body, refresh = NULL, requests_per_second = NULL,
                    slices = NULL, timeout = NULL, 
                    wait_for_active_shards = NULL,
                    wait_for_completion = NULL, ...) {
  
  url <- file.path(make_url(es_get_auth()), "_reindex")
  args <- ec(list(refresh = refresh, requests_per_second = requests_per_second,
                  slices = slices, timeout = timeout, 
                  wait_for_active_shards = wait_for_active_shards,
                  wait_for_completion = wait_for_completion))
  reindex_POST(url, args, body, ...)
}

reindex_POST <- function(url, args = NULL, body = list(), ...) {
  body <- check_inputs(body)
  tt <- POST(url, body = body, query = args, encode = 'json', 
             make_up(), content_type_json(), es_env$headers, ...)
  geterror(tt)
  jsonlite::fromJSON(cont_utf8(tt), FALSE)
}
