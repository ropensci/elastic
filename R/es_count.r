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
#' \url{http://www.elasticsearch.org/guide/reference/query-dsl/} for the documentation.
#' See docs for the count API here 
#' \url{http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-count.html}
#' @examples \dontrun{
#' es_count()
#' es_count(index='plos')
#' es_count(index='plos', type='article')
#' es_count(index='shakespeare')
#' es_count(index='plos,shakespeare', q="a*")
#' es_count(index='plos,shakespeare', q="z*")
#' }

es_count <- function(index=NULL, type=NULL, callopts=list(), verbose=TRUE, ...)
{
  out <- elastic_GET(path = '_count', index, type, NULL, NULL, NULL, FALSE, callopts, ...)
  jsonlite::fromJSON(out, FALSE)$count
}
