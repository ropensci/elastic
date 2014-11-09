#' Elasticsearch indices APIs
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
#' @param active_only (logical) Display only those recoveries that are currently on-going 
#' (default: FALSE)
#' @param detailed (logical) Whether to display detailed information about shard recovery 
#' (default: FALSE)
#' 
#' @examples \donttest{
#' # get information on an index
#' es_index_get(index='shakespeare')
#' es_index_get(index='shakespeare', features=c('settings','mappings'))
#' es_index_get(index='shakespeare', features='aliases')
#' es_index_get(index='shakespeare', features='warmers')
#' 
#' # check for index existence
#' es_index_exists(index='shakespeare')
#' es_index_exists(index='plos')
#' 
#' # delete an index
#' es_index_delete(index='plos')
#' 
#' # create an index
#' es_index_create(index='twitter', type='tweet', id=10)
#' es_index_create(index='things', type='tweet', id=10)
#' 
#' # close an index
#' es_index_close('plos')
#' 
#' # open an index
#' es_index_open('plos')
#' 
#' # Get status of an index
#' es_index_status('plos')
#' es_index_status(c('plos','gbif'))
#' 
#' # Get stats on an index
#' es_index_stats('plos')
#' es_index_stats(c('plos','gbif'))
#' es_index_stats(c('plos','gbif'), metric='refresh')
#' es_index_stats('shakespeare', metric='completion')
#' es_index_stats('shakespeare', metric='completion', completion_fields = "completion")
#' es_index_stats('shakespeare', metric='fielddata')
#' es_index_stats('shakespeare', metric='fielddata', fielddata_fields = "evictions")
#' es_index_stats('plos', level="indices")
#' es_index_stats('plos', level="cluster")
#' es_index_stats('plos', level="shards")
#' 
#' # Get segments information that a Lucene index (shard level) is built with
#' es_index_segments()
#' es_index_segments('plos')
#' es_index_segments(c('plos','gbif'))
#' 
#' # Get recovery information that provides insight into on-going index shard recoveries
#' es_index_recovery()
#' es_index_recovery('plos')
#' es_index_recovery(c('plos','gbif'))
#' es_index_recovery("plos", detailed = TRUE)
#' es_index_recovery("plos", active_only = TRUE)
#' }
#' 
#' @references
#' \url{http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices.html}
#' @author Scott Chamberlain <myrmecocystus@@gmail.com>
#' @name index
NULL

#' @export
#' @rdname index
es_index_get <- function(index=NULL, features=NULL, raw=FALSE, callopts=list(), verbose=TRUE, ...)
{
  conn <- es_connect()
  url <- paste0(conn$base, ":", conn$port)
  index_GET(url, index, features, raw, callopts)
}

#' @export
#' @rdname index
es_index_exists <- function(index, callopts=list())
{
  conn <- es_connect()
  url <- paste0(conn$base, ":", conn$port, "/", index)
  res <- HEAD(url, callopts)
  if(res$status_code == 200) TRUE else FALSE
}

#' @export
#' @rdname index
es_index_delete <- function(index, raw=FALSE, callopts=list(), verbose=TRUE)
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
es_index_create <- function(index=NULL, type=NULL, id=NULL, fields=NULL, raw=FALSE, 
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
es_index_close <- function(index, callopts=list())
{
  close_open(index, "_close", callopts)
}

#' @export
#' @rdname index
es_index_open <- function(index, callopts=list())
{
  close_open(index, "_open", callopts)
}

#' @export
#' @rdname index
es_index_stats <- function(index=NULL, metric=NULL, completion_fields=NULL, fielddata_fields=NULL,
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
es_index_status <- function(index = NULL, callopts=list()) es_GET_wrap1(index, "_status", callopts = callopts)

#' @export
#' @rdname index
es_index_segments <- function(index = NULL, callopts=list()) es_GET_wrap1(index, "_segments", callopts = callopts)

#' @export
#' @rdname index
es_index_recovery <- function(index = NULL, detailed = FALSE, active_only = FALSE, callopts=list()){
  args <- ec(list(detailed = as_log(detailed), active_only = as_log(active_only)))
  es_GET_wrap1(index, "_recovery", args, callopts)
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

e_url <- function(x) paste0(x$base, ":", x$port)
