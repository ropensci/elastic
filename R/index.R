#' Elasticsearch indices APIs
#'
#' @references
#' \url{http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices.html}
#' @author Scott Chamberlain <myrmecocystus@@gmail.com>
#' @name index
#' 
#' @param index (character) A character vector of index names
#' @param features (character) A character vector of features. One or more of settings, mappings, 
#' warmers or aliases
#' @param raw If TRUE (default), data is parsed to list. If FALSE, then raw JSON.
#' @param callopts Curl args passed on to \code{\link[httr]{POST}}, \code{\link[httr]{GET}}, 
#' \code{\link[httr]{PUT}}, \code{\link[httr]{HEAD}}, or \code{\link[httr]{DELETE}}
#' @param verbose If TRUE (default) the url call used printed to console.
#' @param ... Further args passed on to elastic search HTTP API as parameters.
#' @param type (character) Document type
#' @param id Document id
#' @param fields (character) Fields to add.
#' @param metric (character) A character vector of metrics to display. Possible values: "_all", 
#' "completion", "docs", "fielddata", "filter_cache", "flush", "get", "id_cache", "indexing", 
#' "merge", "percolate", "refresh", "search", "segments", "store", "warmer".
#' @param completion_fields (character) A character vector of fields for completion metric 
#' (supports wildcards)
#' @param fielddata_fields (character) A character vector of fields for fielddata metric
#' (supports wildcards)
#' @param groups (character) A character vector of search groups for search statistics.
#' @param level (character) Return stats aggregated on "cluster", "indices" (default) or "shards"
#' @param active_only (logical) Display only those recoveries that are currently on-going. 
#' Default: FALSE
#' @param detailed (logical) Whether to display detailed information about shard recovery. 
#' Default: FALSE
#' @param max_num_segments (character) The number of segments the index should be merged into. 
#' Default: "dynamic"
#' @param only_expunge_deletes (logical) Specify whether the operation should only expunge 
#' deleted documents
#' @param flush (logical) Specify whether the index should be flushed after performing the 
#' operation. Default: TRUE
#' @param wait_for_merge (logical) Specify whether the request should block until the merge 
#' process is finished. Default: TRUE
#' @param wait_for_completion (logical) Should the request wait for the upgrade to complete. 
#' Default: FALSE
#' 
#' @examples \donttest{
#' # get information on an index
#' index_get(index='shakespeare')
#' index_get(index='shakespeare', features=c('settings','mappings'))
#' index_get(index='shakespeare', features='aliases')
#' index_get(index='shakespeare', features='warmers')
#' 
#' # check for index existence
#' index_exists(index='shakespeare')
#' index_exists(index='plos')
#' 
#' # delete an index
#' index_delete(index='plos')
#' 
#' # create an index
#' index_create(index='twitter', type='tweet', id=10)
#' index_create(index='things', type='tweet', id=10)
#' 
#' # close an index
#' index_close('plos')
#' 
#' # open an index
#' index_open('plos')
#' 
#' # Get status of an index
#' index_status('plos')
#' index_status(c('plos','gbif'))
#' 
#' # Get stats on an index
#' index_stats('plos')
#' index_stats(c('plos','gbif'))
#' index_stats(c('plos','gbif'), metric='refresh')
#' index_stats('shakespeare', metric='completion')
#' index_stats('shakespeare', metric='completion', completion_fields = "completion")
#' index_stats('shakespeare', metric='fielddata')
#' index_stats('shakespeare', metric='fielddata', fielddata_fields = "evictions")
#' index_stats('plos', level="indices")
#' index_stats('plos', level="cluster")
#' index_stats('plos', level="shards")
#' 
#' # Get segments information that a Lucene index (shard level) is built with
#' index_segments()
#' index_segments('plos')
#' index_segments(c('plos','gbif'))
#' 
#' # Get recovery information that provides insight into on-going index shard recoveries
#' index_recovery()
#' index_recovery('plos')
#' index_recovery(c('plos','gbif'))
#' index_recovery("plos", detailed = TRUE)
#' index_recovery("plos", active_only = TRUE)
#' 
#' # Optimize an index, or many indices
#' index_optimize('plos')
#' index_optimize(c('plos','gbif'))
#' 
#' # Upgrade one or more indices to the latest format. The upgrade process converts any 
#' # segments written with previous formats.
#' index_upgrade('plos')
#' index_upgrade(c('plos','gbif'))
#' }
NULL

#' @export
#' @rdname index
index_get <- function(index=NULL, features=NULL, raw=FALSE, callopts=list(), verbose=TRUE, ...)
{
  conn <- es_connect()
  url <- paste0(conn$base, ":", conn$port)
  index_GET(url, index, features, raw, callopts)
}

#' @export
#' @rdname index
index_exists <- function(index, callopts=list())
{
  conn <- es_connect()
  url <- paste0(conn$base, ":", conn$port, "/", index)
  res <- HEAD(url, callopts)
  if(res$status_code == 200) TRUE else FALSE
}

#' @export
#' @rdname index
index_delete <- function(index, raw=FALSE, callopts=list(), verbose=TRUE)
{
  conn <- es_connect()
  url <- paste0(conn$base, ":", conn$port, "/", index)
  out <- DELETE(url, callopts)
  stop_for_status(out)
  if(verbose) message(URLdecode(out$url))
  tt <- structure(content(out, as="text"), class="index_delete")
  if(raw){ tt } else { es_parse(tt) }
}

#' @export
#' @rdname index
index_create <- function(index=NULL, type=NULL, id=NULL, fields=NULL, raw=FALSE, 
  callopts=list(), verbose=TRUE, ...)
{
  conn <- es_connect()
  
  if(length(id) > 1){ # pass in request in body
    body <- toJSON(list(ids = as.character(id)))
  }
  
  if(!is.null(fields)) fields <- paste(fields, collapse=",")
  url <- paste(conn$url, ":", conn$port, sep="")
  
  out <- PUT(url, query=list(), callopts)
  stop_for_status(out)
  if(verbose) message(URLdecode(out$url))
  tt <- structure(content(out, as="text"), class="elastic_create")
  if(raw){ tt } else { es_parse(tt) }
}

#' @export
#' @rdname index
index_close <- function(index, callopts=list())
{
  close_open(index, "_close", callopts)
}

#' @export
#' @rdname index
index_open <- function(index, callopts=list())
{
  close_open(index, "_open", callopts)
}

#' @export
#' @rdname index
index_stats <- function(index=NULL, metric=NULL, completion_fields=NULL, fielddata_fields=NULL,
  fields=NULL, groups=NULL, level='indices', callopts=list())
{
  conn <- es_connect()
  url <- if(is.null(index)) file.path(e_url(conn), "_stats") else file.path(e_url(conn), cl(index), "_stats")
  url <- if(!is.null(metric)) file.path(url, cl(metric)) else url
  args <- ec(list(completion_fields=completion_fields, fielddata_fields=fielddata_fields,
                  fields=fields, groups=groups, level=level))
  es_GET_(url, args, callopts)
}

#' @export
#' @rdname index
index_status <- function(index = NULL, callopts=list()) es_GET_wrap1(index, "_status", callopts = callopts)

#' @export
#' @rdname index
index_segments <- function(index = NULL, callopts=list()) es_GET_wrap1(index, "_segments", callopts = callopts)

#' @export
#' @rdname index
index_recovery <- function(index = NULL, detailed = FALSE, active_only = FALSE, callopts=list()){
  args <- ec(list(detailed = as_log(detailed), active_only = as_log(active_only)))
  es_GET_wrap1(index, "_recovery", args, callopts)
}

#' @export
#' @rdname index
index_optimize <- function(index = NULL, max_num_segments = NULL, only_expunge_deletes = FALSE, 
  flush = TRUE, wait_for_merge = TRUE, callopts=list())
{
  args <- ec(list(max_num_segments = max_num_segments, 
                  only_expunge_deletes = as_log(only_expunge_deletes), 
                  flush = as_log(flush), 
                  wait_for_merge = as_log(wait_for_merge)
  ))
  es_POST_(index, "_optimize", args, callopts)
}

#' @export
#' @rdname index
index_upgrade <- function(index = NULL, wait_for_completion = FALSE, callopts=list())
{
  args <- ec(list(wait_for_completion = as_log(wait_for_completion)))
  es_POST_(index, "_upgrade", args, callopts)
}

close_open <- function(index, which, callopts){
  conn <- es_connect()
  url <- sprintf("%s:%s/%s/%s", conn$base, conn$port, index, which)
  out <- POST(url, callopts)
  stop_for_status(out)
  content(out)
}

es_GET_wrap1 <- function(index, which, args=list(), callopts){
  conn <- es_connect()
  url <- if(is.null(index)) file.path(e_url(conn), which) else file.path(e_url(conn), cl(index), which)
  es_GET_(url, args, callopts)
}

es_POST_ <- function(index, which, args=list(), callopts){
  conn <- es_connect()
  url <- if(is.null(index)) file.path(e_url(conn), which) else file.path(e_url(conn), cl(index), which)
  tt <- POST(url, query=args, callopts)
  if(tt$status_code > 202) stop(content(tt)$error)
  jsonlite::fromJSON(content(tt, "text"), FALSE)
}

e_url <- function(x) paste0(x$base, ":", x$port)
