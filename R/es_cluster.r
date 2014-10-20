#' Elasticsearch cluster endpoints
#'
#' @export
#'
#' @param what Which cluster endpiont to use, one of health, state, stats, reroute, settings, or
#' pending_tasks.
#' @param index Index
#' @param raw If TRUE (default), data is parsed to list. If FALSE, then raw JSON.
#' @param callopts Curl args passed on to httr::POST.
#' @param verbose If TRUE (default) the url call used printed to console.
#' @param ... Further args passed on to elastic search HTTP API as parameters.
#'
#' @details
#' Additional parameters that can be passed in:
#' \itemize{
#'   \item metric A comma-separated list of metrics to display. Possible values: '_all',
#' 'completion', 'docs', 'fielddata', 'filter_cache', 'flush', 'get', 'id_cache', 'indexing',
#' 'merge', 'percolate', 'refresh', 'search', 'segments', 'store', 'warmer'
#'   \item completion_fields A comma-separated list of fields for completion metric (supports
#' wildcards)
#'   \item fielddata_fields A comma-separated list of fields for fielddata metric (supports
#' wildcards)
#'   \item fields A comma-separated list of fields for fielddata and completion metric (supports
#' wildcards)
#'   \item groups A comma-separated list of search groups for search statistics
#'   \item allow_no_indices Whether to ignore if a wildcard indices expression resolves into no
#' concrete indices. (This includes _all string or when no indices have been specified)
#'   \item expand_wildcards Whether to expand wildcard expression to concrete indices that are
#' open, closed or both.
#'   \item ignore_indices When performed on multiple indices, allows to ignore missing ones
#' (default: none)
#'   \item ignore_unavailable Whether specified concrete indices should be ignored when unavailable
#' (missing or closed)
#'   \item human Whether to return time and byte values in human-readable format.
#'   \item level Return stats aggregated at cluster, index or shard level. ('cluster', 'indices'
#' or 'shards', default: 'indices')
#'   \item types A comma-separated list of document types for the indexing index metric
#' }
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
