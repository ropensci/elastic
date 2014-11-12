#' Elasticsearch nodes endpoints.
#'
#' @name nodes
#' @param node The node
#' @param metric A metric to get
#' @param raw If TRUE (default), data is parsed to list. If FALSE, then raw JSON.
#' @param callopts Curl args passed on to httr::POST.
#' @param verbose If TRUE (default) the url call used printed to console.
#' @param ... Further args passed on to elastic search HTTP API as parameters.
#'
#' @details \url{http://bit.ly/11gezop}
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
#' (out <- nodes_stats())
#' nodes_stats(node = names(out$nodes))
#' nodes_stats(metric='get')
#' nodes_stats(metric='jvm')
#' nodes_stats(metric=c('os','process'))
#' nodes_info()
#' nodes_info(metric='process')
#' }
#' 
#' @examples \donttest{
#' nodes_shutdown()
#' nodes_hot_threads()
#' }

#' @export
#' @rdname nodes
nodes_stats <- function(node=NULL, metric=NULL, raw=FALSE, callopts=list(), verbose=TRUE, ...){
  es_GET('_nodes/stats', NULL, NULL, NULL, node, 'elastic_nodes_stats', raw, callopts, ...)
}

#' @export
#' @rdname nodes
nodes_info <- function(node=NULL, metric=NULL, raw=FALSE, callopts=list(), verbose=TRUE, ...){
  es_GET('_nodes/info', NULL, NULL, NULL, node, 'elastic_nodes_info', raw, callopts, ...)
}

#' @export
#' @rdname nodes
nodes_hot_threads <- function(node=NULL, metric=NULL, raw=FALSE, callopts=list(), verbose=TRUE, ...){
  es_GET('_nodes/hot_threads', NULL, NULL, NULL, node, 'elastic_nodes_hot_threads', raw, callopts, ...)
}

#' @export
#' @rdname nodes
nodes_shutdown <- function(node=NULL, metric=NULL, raw=FALSE, callopts=list(), verbose=TRUE, ...){
  es_GET('_nodes/shutdown', NULL, NULL, NULL, node, 'elastic_nodes_shutdown', raw, callopts, ...)
}
