#' Delete documents by query
#' 
#' delete documents by query via a POST request
#'
#' @export
#' @param conn an Elasticsearch connection object, see [connect()]
#' @param index (character) The name of the index. Required
#' @param body (character/json) query to be passed on to POST request body
#' @param type (character) The type of the document. optional
#' @param refresh (logical) Refresh the index after performing the operation
#' @param routing (character) Specific routing value
#' @param timeout (character) Explicit operation timeout, e.g,. 5m (for 5 
#' minutes)
#' @param conflicts (character) If you’d like to count version conflicts 
#' rather than cause them to abort then set `conflicts=proceed`
#' @param scroll_size (integer) By default uses scroll batches of 1000. 
#' Change batch size with this parameter.
#' @param wait_for_completion (logical) If `wait_for_completion=FALSE` then 
#' Elasticsearch will perform some preflight checks, launch the request, and 
#' then return a task which can be used with Tasks APIs to cancel or get the 
#' status of the task. Elasticsearch will also create a record of this task 
#' as a document at .tasks/task/${taskId}. This is yours to keep or remove 
#' as you see fit. When you are done with it, delete it so Elasticsearch 
#' can reclaim the space it uses. Default: `TRUE`
#' @param wait_for_active_shards (logical) controls how many copies of a 
#' shard must be active before proceeding with the request. 
#' @param scroll (integer) control how long the "search context" is kept 
#' alive, eg `scroll='10m'`, by default it’s 5 minutes (`5m`)
#' @param requests_per_second (integer) any positive decimal number 
#' (1.4, 6, 1000, etc); throttles rate at which `_delete_by_query` issues 
#' batches of delete operations by padding each batch with a wait time. 
#' The throttling can be disabled by setting `requests_per_second=-1`
#' @param ... Curl args passed on to [crul::verb-POST]
#' @references
#' <https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-delete-by-query.html>
#' @examples \dontrun{
#' (x <- connect())
#' x$ping()
#' 
#' plosdat <- system.file("examples", "plos_data.json", package = "elastic")
#' if (!index_exists(x, "plos")) invisible(docs_bulk(x, plosdat))
#' 
#' # delete with fuzzy matching
#' body <- '{
#'   "query": { 
#'     "match": {
#'       "title": {
#'         "query": "cells",
#'         "fuzziness": 1
#'       }
#'     }
#'   }
#' }'
#' docs_delete_by_query(x, index='plos', body = body) 
#' 
#' # delete with no fuzziness
#' if (index_exists(x, "plos")) index_delete(x, 'plos')
#' invisible(docs_bulk(x, plosdat))
#' count(x, "plos")
#' body <- '{
#'   "query": { 
#'     "match": {
#'       "title": {
#'         "query": "cells",
#'         "fuzziness": 0
#'       }
#'     }
#'   }
#' }'
#' docs_delete_by_query(x, index='plos', body = body)
#' 
#' # delete all docs with match_all query
#' if (index_exists(x, "plos")) index_delete(x, 'plos')
#' invisible(docs_bulk(x, plosdat))
#' body <- '{
#'   "query": { 
#'     "match_all": {}
#'   }
#' }'
#' docs_delete_by_query(x, index='plos', body = body)
#' 
#' # put plos back in 
#' if (index_exists(x, "plos")) index_delete(x, 'plos')
#' invisible(docs_bulk(x, plosdat))
#' 
#' # delete docs from more than one index
#' foo <- system.file("examples/foo.json", package = "elastic")
#' if (!index_exists(x, "foo")) invisible(docs_bulk(x, foo))
#' bar <- system.file("examples/bar.json", package = "elastic")
#' if (!index_exists(x, "bar")) invisible(docs_bulk(x, bar))
#' 
#' body <- '{
#'   "query": { 
#'     "match_all": {}
#'   }
#' }'
#' docs_delete_by_query(x, index=c('foo','bar'), 
#'   body = body, verbose = TRUE)
#' }
docs_delete_by_query <- function(conn, index, body, type = NULL, 
  conflicts=NULL, routing=NULL, scroll_size=NULL, refresh=NULL, 
  wait_for_completion=NULL, wait_for_active_shards=NULL, timeout=NULL, 
  scroll=NULL, requests_per_second=NULL, ...) {
  
  is_conn(conn)
  args <- ec(list(conflicts=conflicts, routing=routing, 
    scroll_size=scroll_size, refresh=refresh, 
    wait_for_completion=wait_for_completion, 
    wait_for_active_shards=wait_for_active_shards, timeout=timeout, 
    scroll=scroll, requests_per_second=requests_per_second))
  if (length(args) == 0) args <- NULL
  jsonlite::fromJSON(es_POST(conn, "_delete_by_query", 
    index, type, NULL, FALSE, callopts, body, args, ...), 
  FALSE)
}
