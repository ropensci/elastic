#' Get documents via the get API.
#' 
#' @import httr 
#' @importFrom plyr compact
#' @param conn Connection object describing base url, port, and any authentication 
#' details.
#' @param url the url, defaults to localhost (http://127.0.0.1)
#' @param port port to connect to, defaults to 5984
#' @param index Index
#' @param type Document type
#' @param id Document id
#' @param verbose Verbosity (default) or not. Ignored if parse=FALSE
#' @param ... Further args passed on to elastic search HTTP API.
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

es_get <- function(conn, index=NULL, type=NULL, id=NULL, parse=TRUE, source=FALSE, 
  fields=NULL, callopts=list(), exists=FALSE)
{
  if(length(id) > 1){ # pass in request in body
    body <- toJSON(list(ids = as.character(id)))
  }
  
  if(!is.null(fields)) fields <- paste(fields, collapse=",")
  
  url <- paste(conn$url, ":", conn$port, sep="")
  if(source) url <- paste(url, '_source', sep="/")
  args <- compact(list(fields = fields))
  
  if(exists){
    out <- HEAD(url, query=args, callopts)
    message(paste(out$headers[c('status','statusmessage')], collapse=" - "))
  } else
  {
    out <- GET(url, query=args, callopts)
    stop_for_status(out)
    
    message(out$url)
    
    if(!parse){
      tt <- content(out, as="text")
      class(tt) <- "elastic"
      return( tt )
    } else {
      parsed <- content(out)
      class(parsed) <- "elastic"
      return( parsed )
    }
  }
}


# docs <- list(list('tweet', '1'), list('mention','1'))
# docs <- lapply(docs, function(x){
#   x[[1]] <- sprintf('"_type" : "%s"', x[[1]])
#   x[[2]] <- sprintf('"_id" : "%s"', x[[2]])
#   x
# })
# jsonlite::toJSON(list(docs = docs))
#   
# es_mget <- function(conn, ..., index=NULL, type=NULL, id=NULL, parse=TRUE, fields=NULL, 
#                     callopts=list())
# {
#   base <- paste(conn$url, ":", conn$port, sep="")
#   
#   docs <- list(...)
#   
#   if(length(index)==1 & length(type)==1 & length(id) > 1){
#     body <- toJSON(list(ids = as.character(id)))
#     url <- paste(base, index, type, '_mget', sep="/")
#   } else if(length(index)==1 & length(type)>1){
#     body <- jsonlite::toJSON(list(docs = docs))
#     url <- paste(base, index, '_mget', sep="/")
#   } else if(length(index)==1 & length(type)==1 & length(id) > 1){
#     body <- toJSON(list(ids = as.character(id)))
#     url <- paste(base, index, type, '_mget', sep="/")
#   }
#   
#   args <- compact(list(fields = if(is.null(fields)) { fields} else { paste(fields, collapse=",") } ))
#   
#   out <- POST(url, body = list(docs = docs), query = args, callopts)
#   stop_for_status(out)
#   
#   message(out$url)
#   
#   if(!parse){
#     tt <- content(out, as="text")
#     class(tt) <- "elastic"
#     return( tt )
#   } else {
#     parsed <- content(out)
#     class(parsed) <- "elastic"
#     return( parsed )
#   }
# }