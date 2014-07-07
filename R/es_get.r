#' Get documents via the get API.
#' 
#' @import httr 
#' @importFrom plyr compact
#' 
#' @template all
#' @template get
#' @param exists XXX
#' @details There are a lot of terms you can use for Elasticsearch. See here 
#'    \url{http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/docs-get.html} for 
#'    the documentation.
#' @export
#' @examples \dontrun{
#' es_get(index='twitter', type='tweet', id=1)
#' es_get(index='mran', type='metadata', id='taxize')
#' es_get(index='mran', type='metadata', id='taxize', source=TRUE)
#' 
#' # Get certain fields
#' es_get(index='twitter', type='tweet', id=1, fields='user')
#' 
#' # Just test for existence of the document
#' es_get(index='twitter', type='tweet', id=1, exists=TRUE)
#' es_get(index='mran', type='metadata', id='taxize', exists=TRUE)
#' }

es_get <- function(index=NULL, type=NULL, id=NULL, source=FALSE, 
  fields=NULL, exists=FALSE, raw=FALSE, callopts=list(), verbose=TRUE, ...)
{
  conn <- es_get_auth()
  
  if(!is.null(fields)) fields <- paste(fields, collapse=",")
  
  url <- paste(conn$base, ":", conn$port, sep="")
  args <- es_compact(list(fields = fields, ...))
  url <- sprintf("%s/%s/%s/%s", url, index, type, id) 
  if(source) url <- paste(url, '_source', sep="/")
  
#   if(length(id) > 1){ # pass in request in body
#     body <- toJSON(list(ids = as.character(id)))
#   } else{ url <- sprintf("%s/%s/%s/%s", url, index, type, id) }
  
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