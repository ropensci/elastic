#' Elasticsearch nodes endpoints.
#'
#' @import httr
#'
#' @template all
#' @template get
#'
#' @details There are a lot of terms you can use for Elasticsearch. See here
#'    \url{http://www.elasticsearch.org/guide/reference/query-dsl/} for the documentation.
#'
#' @examples \dontrun{
#' es_nodes()
#' }

es_nodes <- function(what='health', index=NULL, raw=FALSE, callopts=list(), verbose=TRUE, ...)
{
  message("not working yet...")
#   what2 <- switch(what, 
#                   health = '_cluster/health',
#                   state = '_cluster/state',
#                   stats = '_cluster/stats',
#                   reroute = '_cluster/reroute',
#                   settings = '_cluster/settings',
#                   pending_tasks = '_cluster/pending_tasks')
#   es_GET(what2, index, NULL, NULL, sprintf('elastic_cluster_%s', what), raw, callopts, ...)
}