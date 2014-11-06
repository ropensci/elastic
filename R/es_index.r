#' Create an index.
#'
#' @import httr
#' @param index Index name
#' @param type Document type
#' @param id Document id
#' @param source Ignored for now
#' @param fields Fields to add.
#' @param exists (logical) Exists or not
#' @param raw If TRUE (default), data is parsed to list. If FALSE, then raw JSON.
#' @param callopts Curl args passed on to httr::POST.
#' @param verbose If TRUE (default) the url call used printed to console.
#' @param ... Further args passed on to elastic search HTTP API as parameters.
#' 
#' @details The function returns TRUE. Though note that this can result even 
#'    if the database does not exist in CouchDB. 
#' @references See docs for the Elasticsearch River plugin \url{#} that lets you 
#'     easily index CouchDB databases.
#' @export
#' @examples \dontrun{
#' es_index_create(index='twitter', type='tweet', id=10)
#' 
#' es_index_create(index='things', type='tweet', id=10)
#' }

es_index_create <- function(index=NULL, type=NULL, id=NULL, source=FALSE, fields=NULL, 
  exists=FALSE, raw=FALSE, callopts=list(), verbose=TRUE, ...)
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
  tt <- content(out, as="text")
  class(tt) <- "elastic_get"
  if(raw){ tt } else { es_parse(tt) }
}
