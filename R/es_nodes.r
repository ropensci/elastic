#' Elasticsearch nodes endpoints.
#'
#' @import httr
#' @export
#'
#' @param what One of stats, info, hot_threads, or shutdown
#' @param node The node
#' @param metric A metric to get
#' @param raw If TRUE (default), data is parsed to list. If FALSE, then raw JSON.
#' @param callopts Curl args passed on to httr::POST.
#' @param verbose If TRUE (default) the url call used printed to console.
#' @param ... Further args passed on to elastic search HTTP API as parameters.
#'
#' @details There are a lot of terms you can use for Elasticsearch. See here
#'    \url{http://www.elasticsearch.org/guide/reference/query-dsl/} for the documentation.
#' 
#' By default, all stats are returned. You can limit this by combining any of indices, os, process,
#' jvm, network, transport, http, fs, breaker and thread_pool. With the metric parameter you can 
#' select zero or more of:
#' 
#' \itemize{
#'  \item indices Indices stats about size, document count, indexing and deletion times, search 
#'  times, field cache size, merges and flushes
#'  \item fs File system information, data path, free disk space, read/write stats
#'  \item http HTTP connection information
#'  \item jvm JVM stats, memory pool information, garbage collection, buffer pools
#'  \item network TCP information
#'  \item os Operating system stats, load average, cpu, mem, swap
#'  \item process Process statistics, memory consumption, cpu usage, open file descriptors
#'  \item thread_pool Statistics about each thread pool, including current size, queue and rejected 
#'  tasks
#'  \item transport Transport statistics about sent and received bytes in cluster communication
#'  \item breaker Statistics about the field data circuit breaker
#' }
#'
#' @examples \dontrun{
#' es_nodes('stats')
#' es_nodes('stats', node='0KQ7ut7dTKqnzJJeDVCUug')
#' es_nodes('stats', metric='get')
#' es_nodes('stats', metric='jvm')
#' es_nodes('stats', metric=c('os','process'))
#' es_nodes('info')
#' es_nodes('info', metric='process')
#' }
#' 
#' @examples \donttest{
#' es_nodes('shutdown')
#' es_nodes('hot_threads')
#' }

es_nodes <- function(what='stats', node=NULL, metric=NULL, raw=FALSE, callopts=list(), verbose=TRUE, ...)
{
  what2 <- switch(what,
                  stats = '_nodes/stats',
                  info = '_nodes/info',
                  hot_threads = '_nodes/hot_threads',
                  shutdown = '_nodes/shutdown')
  es_GET(what2, NULL, NULL, NULL, node, sprintf('elastic_nodes_%s', what), raw, callopts, ...)
}
