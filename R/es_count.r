#' Execute a query and get the number of matches for that query.
#'
#' @import httr
#' @export
#'
#' @template all
#' @template get
#' @param exists XXX
#'
#' @details There are a lot of terms you can use for Elasticsearch. See here
#'    \url{http://www.elasticsearch.org/guide/reference/query-dsl/} for the documentation.
#'
#' @examples \dontrun{
#' es_count(index='mran')
#' es_count(index='mran', type='metadata')
#' es_count(index='twitter')
#' }

es_count <- function(index=NULL, type=NULL, callopts=list(), verbose=TRUE, ...)
{
  out <- es_GET('_count', index, type, NULL, NULL, NULL, FALSE, callopts, ...)
  rjson::fromJSON(out)$count
}