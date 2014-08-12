#' Execute a query and get the number of matches for that query.
#'
#' @import httr
#' @export
#'
#' @template all
#' @template get
#' @param metric A comma-separated list of metrics to display. Possible values: '_all',
#' 'completion', 'docs', 'fielddata', 'filter_cache', 'flush', 'get', 'id_cache', 'indexing',
#' 'merge', 'percolate', 'refresh', 'search', 'segments', 'store', 'warmer'
#' @param completion_fields A comma-separated list of fields for completion metric (supports
#' wildcards)
#' @param fielddata_fields A comma-separated list of fields for fielddata metric (supports
#' wildcards)
#' @param fields A comma-separated list of fields for fielddata and completion metric (supports
#' wildcards)
#' @param groups A comma-separated list of search groups for search statistics
#' @param allow_no_indices Whether to ignore if a wildcard indices expression resolves into no
#' concrete indices. (This includes _all string or when no indices have been specified)
#' @param expand_wildcards Whether to expand wildcard expression to concrete indices that are
#' open, closed or both.
#' @param ignore_indices When performed on multiple indices, allows to ignore missing ones
#' (default: none)
#' @param ignore_unavailable Whether specified concrete indices should be ignored when unavailable
#' (missing or closed)
#' @param human Whether to return time and byte values in human-readable format.
#' @param level Return stats aggregated at cluster, index or shard level. ('cluster', 'indices'
#' or 'shards', default: 'indices')
#' @param types A comma-separated list of document types for the indexing index metric
#'
#' @details There are a lot of terms you can use for Elasticsearch. See here
#'    \url{http://www.elasticsearch.org/guide/reference/query-dsl/} for the documentation.
#'
#' @examples \dontrun{
#' es_stats(index='mran')
#' es_stats(index='mran', metric='search')
#' es_stats(index='mran', metric=c('docs','merge'))
#' es_stats(metric='get', human='true')
#' es_stats(metric='get', human='false')
#' }

es_stats <- function(index=NULL, type=NULL, metric=NULL, raw=FALSE, callopts=list(), verbose=TRUE, ...)
{
  es_GET('_stats', index, type, metric, 'elastic_stats', raw, callopts, ...)
}
