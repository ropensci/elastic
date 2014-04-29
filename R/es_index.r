#' Start or stop indexing a document or many documents.
#'
#' @import httr
#' @param dbname Database name. (character)
#' @param endpoint the endpoint, defaults to localhost (http://127.0.0.1)
#' @param port port to connect to, defaults to 9200
#' @param what One of start (default) of stop.
#' @details The function returns TRUE. Though note that this can result even 
#'    if the database does not exist in CouchDB. 
#' @references See docs for the Elasticsearch River plugin \url{#} that lets you 
#'     easily index CouchDB databases.
#' @export
#' @examples \dontrun{
#' init <- es_connect()
#' es_index(init, index='twitter', type='tweet', id=10)
#' }

es_index <- function(conn, index=NULL, type=NULL, id=NULL, source=FALSE, fields=NULL, 
  exists=FALSE, raw=FALSE, callopts=list(), verbose=TRUE, ...)
{
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