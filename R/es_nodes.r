#' Elasticsearch nodes endpoints.
#'
#' @import httr
#' @export
#'
#' @template all
#' @template get
#'
#' @details There are a lot of terms you can use for Elasticsearch. See here
#'    \url{http://www.elasticsearch.org/guide/reference/query-dsl/} for the documentation.
#'
#' @examples \dontrun{
#' es_nodes('stats')
#' es_nodes('stats', metric='get')
#' es_nodes('stats', metric=c('os','process'))
#' es_nodes('info')
#' }
#' 
#' @examples \donttest{
#' es_nodes('shutdown')
#' es_nodes('hot_threads')
#' }

es_nodes <- function(what='stats', index=NULL, metric=NULL, raw=FALSE, callopts=list(), verbose=TRUE, ...)
{
  what2 <- switch(what,
                  stats = '_nodes/stats',
                  info = '_nodes/info',
                  hot_threads = '_nodes/hot_threads',
                  shutdown = '_nodes/shutdown')
  es_GET(what2, index, NULL, metric, sprintf('elastic_nodes_%s', what), raw, callopts, ...)
}
