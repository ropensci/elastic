#' Get documents via the get API.
#' 
#' @import httr 
#' @importFrom plyr compact
#' 
#' @template all
#' @template get
#' @param exists XXX
#' @details There are a lot of terms you can use for Elasticsearch. See here 
#'    \url{http://www.elasticsearch.org/guide/reference/query-dsl/} for the documentation.
#' @export
#' @examples \dontrun{
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

es_get <- function(index=NULL, type=NULL, id=NULL, source=FALSE, 
  fields=NULL, exists=FALSE, raw=FALSE, callopts=list(), verbose=TRUE, ...)
{
  conn <- es_get_auth()
  
  if(!is.null(fields)) fields <- paste(fields, collapse=",")
  
  url <- paste(conn$base, ":", conn$port, sep="")
  if(source) url <- paste(url, '_source', sep="/")
  args <- compact(list(fields = fields, id=id, ...))
  
  if(length(id) > 1){ # pass in request in body
    body <- toJSON(list(ids = as.character(id)))
  } else{ url <- sprintf("%s/%s/%s", url, type, id) }
  
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