#' Use the bulk API to insert or delete documents.
#' 
#' @import httr
#' @importFrom plyr compact
#' @importFrom rjson toJSON
#' @importFrom RJSONIO toJSON
#' 
#' @template all
#' @template get
#' @param type_id List of vectors of length 2, each with an element for type and id.
#' @param index_type_id List of vectors of length 3, each with an element for index, 
#' type, and id.
#' @details There are a lot of terms you can use for Elasticsearch. See here 
#'    \url{http://www.elasticsearch.org/guide/reference/query-dsl/} for the documentation.
#' @export
#' @examples \dontrun{
#' init <- es_connect()
#' es_bulk(init, index="twitter", type="tweet", id=1:2)
#' }

es_bulk <- function(conn, index=NULL, type=NULL, id=NULL, type_id=NULL, index_type_id=NULL,
  source=NULL, fields=NULL, raw=FALSE, callopts=list(), verbose=TRUE, ...)
{
  message("not done yet")
  # base <- paste(conn$url, ":", conn$port, sep="")
  # fields <- if(is.null(fields)) { fields} else { paste(fields, collapse=",") } 
  # args <- compact(list(...))
  
  # # One index, one type, one to many ids
  # if(length(index)==1 & length(unique(type))==1 & length(id) > 1){
    
  #   body <- rjson::toJSON(list("ids" = id))
  #   url <- paste(base, index, type, '_mget', sep="/")
  #   out <- POST(url, body = body, multipart = FALSE, callopts, query = args)
    
  # } 
  # # One index, many types, one to many ids
  # else if(length(index)==1 & length(type)>1 | !is.null(type_id)){
    
  #   # check for 2 elements in each element
  #   assert_that(all(sapply(type_id, function(x) length(x) == 2)))
  #   docs <- lapply(type_id, function(x){
  #     list(`_type` = x[[1]], `_id` = x[[2]])
  #   })
  #   docs <- lapply(docs, function(y) c(y, "_source" = source, "_fields" = fields))
  #   tt <- RJSONIO::toJSON(list("docs" = docs))
  #   url <- paste(base, index, '_mget', sep="/")
  #   out <- POST(url, body = tt, multipart = FALSE, callopts, query = args)
    
  # } 
  # # Many indeces, many types, one to many ids
  # else if(length(index)>1 | !is.null(index_type_id)){
    
  #   # check for 3 elements in each element
  #   assert_that(all(sapply(index_type_id, function(x) length(x) == 3)))
  #   docs <- lapply(index_type_id, function(x){
  #     list(`_index` = x[[1]], `_type` = x[[2]], `_id` = x[[3]])
  #   })
  #   tt <- rjson::toJSON(list("docs" = docs))
  #   url <- paste(base, '_mget', sep="/")
  #   out <- POST(url, body = tt, multipart = FALSE, callopts, query = args)

  # }
  
  # stop_for_status(out)
  # if(verbose) message(URLdecode(out$url))
  # tt <- content(out, as="text")
  # class(tt) <- "elastic_mget"
  
  # if(raw){ tt } else { es_parse(tt) }
}