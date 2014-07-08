#' Get counts of the number of records per index.
#'
#' @export
#'
#' @param index Index, defaults to all indices
#' @param type Document type
#' @param callopts Curl args passed on to httr::GET.
#' @param verbose If TRUE (default) the url call used printed to console.
#' @param ... Further args passed on to elastic search HTTP API as parameters.
#'
#' @details There are a lot of terms you can use for Elasticsearch. See here
#'    \url{http://www.elasticsearch.org/guide/reference/query-dsl/} for the documentation.
#'
#' @examples \dontrun{
#' es_count()
#' es_count(index='mran')
#' es_count(index='mran', type='metadata')
#' es_count(index='twitter')
#' }

es_count <- function(index=NULL, type=NULL, callopts=list(), verbose=TRUE, ...)
{
  out <- es_GET('_count', index, type, NULL, NULL, NULL, FALSE, callopts, ...)
  rjson::fromJSON(out)$count
}