#' Elasticsearch cluster endpoints
#'
#' @name cluster
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
#' cluster_settings()
#' cluster_health()
#' cluster_state()
#' cluster_stats()
#' cluster_pending_tasks()
#'
#' # raw json data
#' cluster_health(raw = TRUE)
#' }

#' @export
#' @rdname cluster
cluster_settings <- function(index=NULL, raw=FALSE, callopts=list(), verbose=TRUE, ...){
  es_GET('_cluster/settings', index, NULL, NULL, NULL, 'elastic_cluster_settings', raw, callopts, ...)
}

#' @export
#' @rdname cluster
cluster_health <- function(index=NULL, raw=FALSE, callopts=list(), verbose=TRUE, ...){
  es_GET('_cluster/health', index, NULL, NULL, NULL, 'elastic_cluster_health', raw, callopts, ...)
}

#' @export
#' @rdname cluster
cluster_state <- function(index=NULL, raw=FALSE, callopts=list(), verbose=TRUE, ...){
  es_GET('_cluster/state', index, NULL, NULL, NULL, 'elastic_cluster_state', raw, callopts, ...)
}

#' @export
#' @rdname cluster
cluster_stats <- function(index=NULL, raw=FALSE, callopts=list(), verbose=TRUE, ...){
  es_GET('_cluster/stats', index, NULL, NULL, NULL, 'elastic_cluster_stats', raw, callopts, ...)
}

#' @export
#' @rdname cluster
cluster_reroute <- function(index=NULL, raw=FALSE, callopts=list(), verbose=TRUE, ...){
  es_GET('_cluster/reroute', index, NULL, NULL, NULL, 'elastic_cluster_reroute', raw, callopts, ...)
}

#' @export
#' @rdname cluster
cluster_pending_tasks <- function(index=NULL, raw=FALSE, callopts=list(), verbose=TRUE, ...){
  es_GET('_cluster/pending_tasks', index, NULL, NULL, NULL, 'elastic_cluster_pending_tasks', raw, callopts, ...)
}
