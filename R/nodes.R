#' Elasticsearch nodes endpoints.
#'
#' @name nodes
#' @param conn an Elasticsearch connection object, see [Elasticsearch]
#' @param node The node
#' @param metric A metric to get. See Details.
#' @param fields You can get information about field data memory usage on
#' node level or on index level
#' @param threads (character) Number of hot threads to provide. Default: 3
#' @param interval (character) The interval to do the second sampling of
#' threads. Default: 500ms
#' @param type (character) The type to sample, defaults to cpu, but supports
#' wait and block to see hot threads that are in wait or block state.
#' @param raw If `TRUE` (default), data is parsed to list. If `FALSE`, then
#' raw JSON.
#' @param ... Curl args passed on to \code{\link[httr]{GET}}
#'
#' @details
#' <https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-nodes-stats.html>
#'
#' By default, all stats are returned. You can limit this by combining any of
#' indices, os, process, jvm, network, transport, http, fs, breaker and
#' thread_pool. With the metric parameter you can select zero or more of:
#'
#' - indices Indices stats about size, document count, indexing and
#'  deletion times, search times, field cache size, merges and flushes
#' - os retrieve information that concern the operating system
#' - fs File system information, data path, free disk space,
#'  read/write stats
#' - http HTTP connection information
#' - jvm JVM stats, memory pool information, garbage collection,
#'  buffer pools
#' - network TCP information
#' - os Operating system stats, load average, cpu, mem, swap
#' - process Process statistics, memory consumption, cpu usage, open
#'  file descriptors
#' - thread_pool Statistics about each thread pool, including current
#'  size, queue and rejected tasks
#' - transport Transport statistics about sent and received bytes in
#'  cluster communication
#' - breaker Statistics about the field data circuit breaker
#'
#' [nodes_hot_threads()] returns plain text, so [base::cat()]
#' is used to print to the console.
#'
#' @examples \dontrun{
#' # connection setup
#' (x <- connect())
#' 
#' (out <- nodes_stats(x))
#' nodes_stats(x, node = names(out$nodes))
#' nodes_stats(x, metric='get')
#' nodes_stats(x, metric='jvm')
#' nodes_stats(x, metric=c('os','process'))
#' nodes_info(x)
#' nodes_info(x, metric='process')
#' nodes_info(x, metric='jvm')
#' nodes_info(x, metric='http')
#' nodes_info(x, metric='network')
#' }

#' @export
#' @rdname nodes
nodes_stats <- function(conn, node=NULL, metric=NULL, raw=FALSE, fields=NULL, 
  ...) {

  node_GET(conn, 'stats', metric, node, raw, ec(list(fields = fields)), ...)
}

#' @export
#' @rdname nodes
nodes_info <- function(conn, node=NULL, metric=NULL, raw=FALSE, ...) {
  node_GET(conn, '', metric, node, raw, list(), ...)
}

#' @export
#' @rdname nodes
nodes_hot_threads <- function(conn, node=NULL, metric=NULL, threads=3,
  interval='500ms', type=NULL, raw=FALSE, ...) {

  args <- list(threads = threads, interval = interval, type = type)
  cat(node_GET(conn, 'hot_threads', metric, node, raw = TRUE, args, ...))
}

node_GET <- function(conn, path, metric, node, raw, args, ...) {
  url <- conn$make_url()
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
  tt <- conn$make_conn(url, ...)$get(query = args)
  # tt <- GET(url, query = args, make_up(), es_env$headers, ...)
  if (tt$status_code > 202) geterror(tt)
  res <- tt$parse("UTF-8")
  if (raw) res else jsonlite::fromJSON(res, FALSE)
}
