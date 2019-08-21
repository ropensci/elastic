#' Validate a search
#'
#' @export
#' @param conn an Elasticsearch connection object, see [connect()]
#' @param index Index name. Required.
#' @param type Document type. Optional.
#' @param ... Additional args passed on to [Search()]
#' @seealso [Search()]
#' @examples \dontrun{
#' x <- connect()
#' 
#' if (!index_exists(x, "twitter")) index_create(x, "twitter")
#' docs_create(x, 'twitter', type='tweet', id=1, body = list(
#'    "user" = "foobar", 
#'    "post_date" = "2014-01-03",
#'    "message" = "trying out Elasticsearch"
#'  )
#' )
#' validate(x, "twitter", q='user:foobar')
#' validate(x, "twitter", "tweet", q='user:foobar')
#' 
#' body <- '{
#' "query" : {
#'   "bool" : {
#'     "must" : {
#'       "query_string" : {
#'         "query" : "*:*"
#'       }
#'     },
#'     "filter" : {
#'       "term" : { "user" : "kimchy" }
#'     }
#'   }
#' }
#' }'
#' validate(x, "twitter", body = body)
#' }
validate <- function(conn, index, type = NULL, ...) {
  is_conn(conn)
  Search(conn, index, type, search_path = "_validate/query",
    track_total_hits = NULL, ...)
}
