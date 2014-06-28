#' Execute a query and get the number of matches for that query.
#' 
#' @import httr
#' @export
#' 
#' @template all
#' @template get
#' @param exists XXX
#' 
#' @details There are a lot of terms you can use for Elasticsearch. See here 
#'    \url{http://www.elasticsearch.org/guide/reference/query-dsl/} for the documentation.
#' 
#' @examples \dontrun{
#' es_count(index='mran')
#' es_count(index='mran', raw=TRUE)
#' es_count(index='twitter')
#' }

es_count <- function(index=NULL, type=NULL, raw=FALSE, callopts=list(), verbose=TRUE, ...)
{
  out <- es_GET('_count', NULL, index, type, raw, callopts, ...)
  rjson::fromJSON(out)$count
}

#' Get a list of your indices, just the names.
#' 
#' See \code{es_status} for more details on indices.
#' 
#' @param ... Further args passed on to elastic search HTTP API as parameters.
#' @param callopts Curl args passed on to httr::POST.
#' @param raw If TRUE (default), data is parsed to list. If FALSE, then raw JSON.
#' @param verbose If TRUE (default) the url call used printed to console.
#' 
#' @seealso \link{es_status}
#' @examples \dontrun{
#' es_aliases()
#' es_aliases(raw=TRUE)
#' }

es_aliases <- function(callopts=list(), raw=FALSE, verbose=TRUE, ...)
{
  out <- es_GET('_aliases', NULL, NULL, NULL, raw, callopts, ...)
  if(raw) out else names(rjson::fromJSON(out))
}

#' Get a list of your indices, just the names.
#' 
#' See \code{es_status} for more details on indices.
#' 
#' @examples \dontrun{
#' es_status()
#' }

es_status <- function(callopts=list(), raw=FALSE, verbose=TRUE, ...)
{
  es_GET('_status', NULL, NULL, 'elastic_status', raw, callopts, ...)
}

#' Get info on your Elasticsearch cluster
#' 
#' Calls \link{es_connect} internally
#' 
#' @export
#' @examples \dontrun{
#' es_info()
#' }

es_info <- function(){
  es_connect()
}