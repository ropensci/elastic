#' Get documents via the get API.
#' 
#' @import httr 
#' @importFrom plyr compact
#' @param conn Connection object describing base url, port, and any authentication 
#' details.
#' @param index Index
#' @param type Document type
#' @param id Document id
#' @param source XXX
#' @param fields Fields to return from the response object.
#' @param exists XXX
#' @param raw If TRUE (default), data is parsed to list. If FALSE, then raw JSON.
#' @param callopts Curl args passed on to httr::POST.
#' @param verbose If TRUE (default) the url call used printed to console.
#' @param ... Further args passed on to elastic search HTTP API as parameters.
#' @details There are a lot of terms you can use for Elasticsearch. See here 
#'    \url{http://www.elasticsearch.org/guide/reference/query-dsl/} for the documentation.
#' @export
#' @examples \dontrun{
#' init <- es_connect()
#' es_get(init, index='twitter', type='tweet', id=1)
#' 
#' # Get certain fields
#' es_get(init, index='twitter', type='tweet', id=1, fields='user')
#' 
#' # Just test for existence of the document
#' es_get(init, index='twitter', type='tweet', id=1, exists=TRUE)
#' 
#' # Just get source (NOT WORKING RIGHT NOW)
#' es_get(init, index='twitter', type='tweet', id=1, source=TRUE)
#' }

es_get <- function(conn, index=NULL, type=NULL, id=NULL, source=FALSE, 
  fields=NULL, exists=FALSE, raw=FALSE, callopts=list(), verbose=TRUE, ...)
{
  if(length(id) > 1){ # pass in request in body
    body <- toJSON(list(ids = as.character(id)))
  }
  
  if(!is.null(fields)) fields <- paste(fields, collapse=",")
  
  url <- paste(conn$url, ":", conn$port, sep="")
  if(source) url <- paste(url, '_source', sep="/")
  args <- compact(list(fields = fields, ...))
  
  if(exists){
    out <- HEAD(url, query=args, callopts)
    message(paste(out$headers[c('status','statusmessage')], collapse=" - "))
  } else
  {
    out <- GET(url, query=args, callopts)
    stop_for_status(out)
    if(verbose) message(URLdecode(out$url))
    tt <- content(out, as="text")
    class(tt) <- "elastic_get"
    if(raw){ tt } else { es_parse(tt) }
  }
}