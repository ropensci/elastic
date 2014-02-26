#' Full text search of any CouchDB databases using Elasticsearch.
#' 
#' @import httr 
#' @importFrom plyr compact
#' @param conn Connection object describing base url, port, and any authentication 
#' details.
#' @param index Index
#' @param type Document type
#' @param raw If FALSE (default), data is parsed to list. If TRUE, then raw JSON.
#' @param verbose Verbosity (default) or not. Ignored if parse=FALSE
#' @param callopts Curl args passed on to httr::POST.
#' @param ... Further args passed on to elastic search HTTP API.
#' @details There are a lot of terms you can use for Elasticsearch. See here 
#'    \url{http://www.elasticsearch.org/guide/reference/query-dsl/} for the documentation.
#' @export
#' @examples \dontrun{
#' init <- es_connect()
#' es_search(init, index="twitter")
#' es_search(init, index="twitter", type="tweet")
#' es_search(init, index="twitter", type="mention")
#' es_search(init, index="twitter", type="tweet", q="what")
#' es_search(init, index="twitter", type="tweet", sort="message")
#' 
#' # Get raw data
#' es_search(init, index="twitter", type="tweet", raw=TRUE)
#' }

es_search <- function(conn, index=NULL, type=NULL, raw=FALSE, verbose=TRUE, callopts=list(), ...)
{
  base <- paste(conn$url, ":", conn$port, sep="")
  if(is.null(type)){ url <- paste(base, index, "_search", sep="/") } else {
    url <- paste(base, index, type, "_search", sep="/")    
  }
  args <- compact(list(...))
  out <- GET(url, query=args)
  stop_for_status(out)
  if(verbose) message(URLdecode(out$url))
  tt <- content(out, as="text")
  class(tt) <- "elastic_search"
  if(raw){ tt } else { es_parse(tt, verbose=verbose) }
}