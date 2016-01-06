#' Validate a search
#'
#' @export
#' @param index Index name. Required.
#' @param type Document type. Optional.
#' @param ... Additional args passed on to \code{\link{Search}}
#' @seealso \code{\link{Search}}
#' @examples \dontrun{
#' if (!index_exists("twitter")) index_create("twitter")
#' docs_create('twitter', type='tweet', id=1, body = list(
#'    "user" = "foobar", 
#'    "post_date" = "2014-01-03",
#'    "message" = "trying out Elasticsearch"
#'  )
#' )
#' validate("twitter", q='user:foobar')
#' validate("twitter", "tweet", q='user:foobar')
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
#' validate("twitter", body = body)
#' }
validate <- function(index, type = NULL, ...) {
  Search(index, type, search_path = "_validate/query", ...)
}
