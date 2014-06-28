#' Wrapper around httr::GET for this package
#' 
#' @export
#' @param path Elasticsearch API endpoint path
#' @param index Elasticsearch index
#' @param type Elasticsearch type
#' @param clazz Class to outupt
#' @param raw Raw JSON results as string
#' @param callopts Curl options
#' @param ... Further args passed to Elasticsearch
es_GET <- function(path, index=NULL, type=NULL, metric=NULL, clazz=NULL, raw, callopts, ...) 
{
  conn <- es_connect()
  url <- paste(conn$base, ":", conn$port, sep="")
  if(is.null(index) && is.null(type)){ url <- paste(url, path, sep="/") } else
    if(is.null(type) && !is.null(index)){ url <- paste(url, index, path, sep="/") } else {
      url <- paste(url, index, type, path, sep="/")    
    }
  
  if(!is.null(metric)){
    url <- paste(url, paste(metric, collapse = ","), sep = "/")
  }
  
  args <- es_compact(list(...))
  tt <- GET(url, query=args, callopts)
  if(tt$status_code > 202){
    if(tt$status_code > 202) stop(tt$headers$statusmessage)
    if(content(tt)$status == "ERROR") stop(content(tt)$error_message)
  }
  res <- content(tt, as = "text")
  if(!is.null(clazz)){ 
    class(res) <- clazz
    if(raw) res else es_parse(res)
  } else { res }
}

es_compact <- function (l) Filter(Negate(is.null), l)