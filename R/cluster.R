#' Elasticsearch cluster endpoints
#'
#' @name cluster
#' @param conn an Elasticsearch connection object, see [Elasticsearch]
#' @param index Index
#' @param metrics One or more of version, master_node, nodes, routing_table,
#' metadata, and blocks. See Details.
#' @param level Can be one of cluster, indices or shards. Controls the details level of the
#' health information returned. Defaults to cluster.
#' @param wait_for_status One of green, yellow or red. Will wait (until the timeout 
#' provided) until the status of the cluster changes to the one provided or better, i.e. 
#' green > yellow > red. By default, will not wait for any status.
#' @param wait_for_relocating_shards A number controlling to how many relocating shards 
#' to wait for. Usually will be 0 to indicate to wait till all relocations have happened. 
#' Defaults to not wait.
#' @param wait_for_active_shards A number controlling to how many active shards to wait for. 
#' Defaults to not wait.
#' @param wait_for_nodes The request waits until the specified number N of nodes is 
#' available. It also accepts >=N, <=N, >N and <N. Alternatively, it is possible to use 
#' ge(N), le(N), gt(N) and lt(N) notation.
#' @param timeout A time based parameter controlling how long to wait if one of the 
#' wait_for_XXX are provided. Defaults to 30s.
#' @param body Query, either a list or json.
#' @param raw If `TRUE` (default), data is parsed to list. If `FALSE`, then raw JSON.
#' @param callopts Curl args passed on to [httr::POST()]
#' @param verbose If `TRUE` (default) the url call used printed to console.
#' @param ... Further args passed on to elastic search HTTP API as parameters.
#'
#' @details
#' metrics param options:
#' 
#' - version Shows the cluster state version.
#' - master_node Shows the elected master_node part of the response
#' - nodes Shows the nodes part of the response
#' - routing_table Shows the routing_table part of the response. If you supply
#'  a comma separated list of indices, the returned output will only contain the
#'  indices listed.
#' - metadata Shows the metadata part of the response. If you supply a comma
#'  separated list of indices, the returned output will only contain the indices
#'  listed.
#' - blocks Shows the blocks part of the response
#'
#' Additional parameters that can be passed in:
#' 
#' - metric A comma-separated list of metrics to display. Possible values: '_all',
#' 'completion', 'docs', 'fielddata', 'filter_cache', 'flush', 'get', 'id_cache', 'indexing',
#' 'merge', 'percolate', 'refresh', 'search', 'segments', 'store', 'warmer'
#' - completion_fields A comma-separated list of fields for completion metric (supports
#' wildcards)
#' - fielddata_fields A comma-separated list of fields for fielddata metric (supports
#' wildcards)
#' - fields A comma-separated list of fields for fielddata and completion metric (supports
#' wildcards)
#' - groups A comma-separated list of search groups for search statistics
#' - allow_no_indices Whether to ignore if a wildcard indices expression resolves into no
#' concrete indices. (This includes _all string or when no indices have been specified)
#' - expand_wildcards Whether to expand wildcard expression to concrete indices that are
#' open, closed or both.
#' - ignore_indices When performed on multiple indices, allows to ignore missing ones
#' (default: none)
#' - ignore_unavailable Whether specified concrete indices should be ignored when unavailable
#' (missing or closed)
#' - human Whether to return time and byte values in human-readable format.
#' - level Return stats aggregated at cluster, index or shard level. ('cluster', 'indices'
#' or 'shards', default: 'indices')
#' - types A comma-separated list of document types for the indexing index metric
#'
#' @examples \dontrun{
#' # connection setup
#' (x <- connect())
#' 
#' cluster_settings(x)
#' cluster_health(x)
#'
#' cluster_state(x)
#' cluster_state(x, metrics = "version")
#' cluster_state(x, metrics = "nodes")
#' cluster_state(x, metrics = c("version", "nodes"))
#' cluster_state(x, metrics = c("version", "nodes", 'blocks'))
#' cluster_state(x, "shakespeare", metrics = "metadata")
#' cluster_state(x, c("shakespeare", "flights"), metrics = "metadata")
#'
#' cluster_stats(x)
#' cluster_pending_tasks(x)
#' 
#' body <- '{
#'   "commands": [ 
#'     {
#'       "move": {
#'         "index" : "test", "shard" : 0,
#'         "from_node" : "node1", "to_node" : "node2"
#'       }
#'     },
#'     {
#'       "allocate_replica" : {
#'         "index" : "test", "shard" : 1, "node" : "node3"
#'       }
#'     }
#'   ]
#' }'
#' # cluster_reroute(x, body =  body)
#'
#' cluster_health(x)
#' # cluster_health(x, wait_for_status = "yellow", timeout = "3s")
#' }

#' @export
#' @rdname cluster
cluster_settings <- function(conn, index=NULL, raw=FALSE, callopts=list(), 
  verbose=TRUE, ...) {

  is_conn(conn)
  es_GET(conn, '_cluster/settings', index, NULL, NULL, NULL, 
    'elastic_cluster_settings', raw, callopts, ...)
}

#' @export
#' @rdname cluster
cluster_health <- function(conn, index=NULL, level = NULL, 
  wait_for_status = NULL, wait_for_relocating_shards = NULL, 
  wait_for_active_shards = NULL, wait_for_nodes = NULL, timeout = NULL, 
  raw=FALSE, callopts=list(), verbose=TRUE, ...) {
  
  is_conn(conn)
  url <- file.path(conn$make_url(), '_cluster/health')
  if (!is.null(index)) {
    url <- file.path(url, paste0(index, collapse = ","))
  }
  args <- ec(list(level = level, wait_for_status = wait_for_status, 
                  wait_for_relocating_shards = wait_for_relocating_shards, 
                  wait_for_active_shards = wait_for_active_shards, 
                  wait_for_nodes = wait_for_nodes, timeout = timeout))
  es_GET_(conn, url, args, callopts, ...)
}

#' @export
#' @rdname cluster
cluster_state <- function(conn, index=NULL, metrics=NULL, raw=FALSE, 
  callopts=list(), verbose=TRUE, ...) {

  is_conn(conn)
  path <- '_cluster/state'
  if (!is.null(metrics)) {
    path <- file.path(path, paste0(metrics, collapse = ","))
  }
  if (!is.null(index)) {
    path <- file.path(path, paste0(index, collapse = ","))
  }
  es_GET(conn, path, NULL, NULL, NULL, NULL, 'elastic_cluster_state', 
    raw, callopts, ...)
}

#' @export
#' @rdname cluster
cluster_stats <- function(conn, index=NULL, raw=FALSE, callopts=list(), 
  verbose=TRUE, ...) {

  is_conn(conn)
  es_GET(conn, '_cluster/stats', index, NULL, NULL, NULL, 
    'elastic_cluster_stats', raw, callopts, ...)
}

#' @export
#' @rdname cluster
cluster_reroute <- function(conn, body, raw=FALSE, callopts=list(), ...) {
  is_conn(conn)
  es_POST(conn, '_cluster/reroute', query = body, raw = raw, callopts = callopts, 
    ...)
}

#' @export
#' @rdname cluster
cluster_pending_tasks <- function(conn, index=NULL, raw=FALSE, 
  callopts=list(), verbose=TRUE, ...){

  is_conn(conn)
  es_GET(conn, '_cluster/pending_tasks', index, NULL, NULL, NULL, 
    'elastic_cluster_pending_tasks', raw, callopts, ...)
}
