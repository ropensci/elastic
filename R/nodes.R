#' Elasticsearch nodes endpoints.
#'
#' @name nodes
#' @param node The node
#' @param metric A metric to get
#' @param fields You can get information about field data memory usage on node level or on
#' index level
#' @param threads (character) Number of hot threads to provide. Default: 3
#' @param interval (character) The interval to do the second sampling of threads. Default: 500ms
#' @param type (character) The type to sample, defaults to cpu, but supports wait and block to
#' see hot threads that are in wait or block state.
#' @param raw If TRUE (default), data is parsed to list. If FALSE, then raw JSON.
#' @param verbose If TRUE (default) the url call used printed to console
#' @param ... Curl args passed on to \code{\link[httr]{GET}}
#'
#' @details 
#' \url{https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-nodes-stats.html}
#'
#' By default, all stats are returned. You can limit this by combining any of indices, os, process,
#' jvm, network, transport, http, fs, breaker and thread_pool. With the metric parameter you can
#' select zero or more of:
#'
#' \itemize{
#'  \item indices Indices stats about size, document count, indexing and deletion times, search
#'  times, field cache size, merges and flushes
#'  \item os retrieve information that concern the operating system
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
#' \code{\link{nodes_hot_threads}} returns plain text, so \code{\link{cat}} is used to print
#' to the console.
#'
#' @examples \dontrun{
#' (out <- nodes_stats())
#' nodes_stats(node = names(out$nodes))
#' nodes_stats(metric='get')
#' nodes_stats(metric='jvm')
#' nodes_stats(metric=c('os','process'))
#' nodes_info()
#' nodes_info(metric='process')
#' nodes_info(metric='jvm')
#' nodes_info(metric='http')
#' nodes_info(metric='network')
#' nodes_hot_threads()
#' }

#' @export
#' @rdname nodes
nodes_stats <- function(node=NULL, metric=NULL, raw=FALSE, fields=NULL, verbose=TRUE, ...){
  node_GET('stats', metric, node, raw, ec(list(fields = fields)), ...)
}

#' @export
#' @rdname nodes
nodes_info <- function(node=NULL, metric=NULL, raw=FALSE, verbose=TRUE, ...){
  node_GET('', metric, node, raw, list(), ...)
}

#' @export
#' @rdname nodes
nodes_hot_threads <- function(node=NULL, metric=NULL, threads=3, interval='500ms', type=NULL,
  raw=FALSE, verbose=TRUE, ...) {
  args <- list(threads = threads, interval = interval, type = type)
  cat(node_GET('hot_threads', metric, node, raw = TRUE, args, ...))
}

node_GET <- function(path, metric, node, raw, args, ...) {
  checkconn()
  url <- make_url(es_get_auth())
  url <- file.path(url, '_nodes')
  if (!is.null(node)) {
    url <- paste(url, paste(node, collapse = ","), path, sep = "/")
  } else { 
    url <- paste(url, path, sep = "/") 
  }
  if (!is.null(metric)) {
    url <- paste(url, paste(metric, collapse = ","), sep = "/")
  }

  args <- ec(args)
  if (length(args) == 0) args <- NULL
  tt <- GET(url, query = args, make_up(), ...)
  if (tt$status_code > 202) geterror(tt)
  res <- content(tt, "text")
  if (raw) res else jsonlite::fromJSON(res, FALSE)
}

node_POST <- function(path, node, raw, args, ...) {
  checkconn()
  url <- make_url(es_get_auth())
  if (!is.null(node)) {
    url <- paste(url, sprintf("_cluster/nodes/%s/%s", paste(node, collapse = ","), path), sep = "/")
  } else { 
    url <- paste(url, path, sep = "/") 
  }
  
  args <- ec(args)
  if (length(args) == 0) args <- NULL
  tt <- POST(url, query = args, make_up(), ...)
  if (tt$status_code > 202) geterror(tt)
  res <- content(tt, "text")
  if (raw) res else jsonlite::fromJSON(res, FALSE)
}
