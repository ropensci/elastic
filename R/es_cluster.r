#' Elasticsearch cluster endpoints
#'
#' @export
#'
#' @template all
#' @param what Which cluster endpiont to use, one of health, state, stats, reroute, settings, or
#' pending_tasks. 
#'
#' @examples \dontrun{
#' es_cluster(what='health')
#' es_cluster('state')
#' es_cluster('settings')
#' es_cluster('stats')
#' es_cluster('pending_tasks')
#'
#' # raw json data
#' es_cluster('health', raw=TRUE)
#' }
#'
#' @examples \donttest{
#' es_cluster(what='reroute')
#' }

es_cluster <- function(what='health', index=NULL, raw=FALSE, callopts=list(), verbose=TRUE, ...)
{
  what2 <- switch(what,
         health = '_cluster/health',
         state = '_cluster/state',
         stats = '_cluster/stats',
         reroute = '_cluster/reroute',
         settings = '_cluster/settings',
         pending_tasks = '_cluster/pending_tasks')
  elastic_GET(what2, index, NULL, NULL, NULL, sprintf('elastic_cluster_%s', what), raw, callopts, ...)
}
