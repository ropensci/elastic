#' Execute a query and get the number of matches for that query.
#'
#' @export
#' @param index Index name
#' @param type Index type
#' @param metric A metric to get
#' @param raw If TRUE (default), data is parsed to list. If FALSE, then raw JSON.
#' @param callopts Curl args passed on to httr::POST.
#' @param verbose If TRUE (default) the url call used printed to console.
#' @param ... Further args passed on to elastic search HTTP API as parameters.
#'
#' @details There are a lot of terms you can use for Elasticsearch. See here
#'    \url{http://www.elasticsearch.org/guide/reference/query-dsl/} for the documentation.
#'
#' Additional parameters that can be passed in:
#' \itemize{
#'  \item metric A comma-separated list of metrics to display. Possible values: '_all',
#' 'completion', 'docs', 'fielddata', 'filter_cache', 'flush', 'get', 'id_cache', 'indexing',
#' 'merge', 'percolate', 'refresh', 'search', 'segments', 'store', 'warmer'
#'  \item completion_fields A comma-separated list of fields for completion metric (supports
#' wildcards)
#'  \item fielddata_fields A comma-separated list of fields for fielddata metric (supports
#' wildcards)
#'  \item fields A comma-separated list of fields for fielddata and completion metric (supports
#' wildcards)
#'  \item groups A comma-separated list of search groups for search statistics
#'  \item allow_no_indices Whether to ignore if a wildcard indices expression resolves into no
#' concrete indices. (This includes _all string or when no indices have been specified)
#'  \item expand_wildcards Whether to expand wildcard expression to concrete indices that are
#' open, closed or both.
#'  \item ignore_indices When performed on multiple indices, allows to ignore missing ones
#' (default: none)
#'  \item ignore_unavailable Whether specified concrete indices should be ignored when unavailable
#' (missing or closed)
#'  \item human Whether to return time and byte values in human-readable format.
#'  \item level Return stats aggregated at cluster, index or shard level. ('cluster', 'indices'
#' or 'shards', default: 'indices')
#'  \item types A comma-separated list of document types for the indexing index metric
#' }
#'
#' @examples \dontrun{
#' es_stats(index='shakespeare')
#' es_stats(index='shakespeare', metric='search')
#' es_stats(index='shakespeare', metric=c('docs','merge'))
#' es_stats(metric='get', human='true')
#' es_stats(metric='get', human='false')
#' }

es_stats <- function(index=NULL, type=NULL, metric=NULL, raw=FALSE, 
                     callopts=list(), verbose=TRUE, ...) {
  
  es_GET('_stats', index, type, metric, NULL, 'elastic_stats', raw, callopts, ...)
}
