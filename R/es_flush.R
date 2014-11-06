#' Explicitly flush one or more indices.
#' 
#' @export
#' 
#' @param index The name of the index to scope the operation
#' @param force (logical) Whether a flush should be forced even if it is not necessarily needed 
#' ie. if no changes will be committed to the index.
#' @param full (logical) If set to TRUE a new index writer is created and settings that have been 
#' changed related to the index writer will be refreshed.
#' @param wait_if_ongoing If TRUE, the flush operation will block until the flush can be executed 
#' if another flush operation is already executing. The default is false and will cause an 
#' exception to be thrown on the shard level if another flush operation is already running. 
#' [1.4.0.Beta1]
#' @param callopts Curl args passed on to httr::POST.
#' @references 
#' \url{http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-flush.html} 
#' @details From the ES website:
#' The flush process of an index basically frees memory from the index by flushing data to the 
#' index storage and clearing the internal transaction log. By default, Elasticsearch uses memory 
#' heuristics in order to automatically trigger flush operations as required in order to clear 
#' memory.
#' @examples \donttest{
#' es_flush()
#' es_flush(index = "plos")
#' es_flush(index = "shakespeare")
#' es_flush(index = c("plos","shakespeare"))
#' es_flush(wait_if_ongoing = TRUE)
#' library('httr')
#' es_flush(callopts=verbose())
#' }
es_flush <- function(index=NULL, force=FALSE, full=FALSE, wait_if_ongoing=FALSE, callopts=list())
{
  conn <- es_connect()
  if(!is.null(index)) 
    url <- sprintf("%s:%s/%s/_flush", conn$base, conn$port, cl(index)) 
  else 
    url <- sprintf("%s:%s/_flush", conn$base, conn$port)
  args <- ec(list(force=as_log(force), full=as_log(full), wait_if_ongoing=as_log(wait_if_ongoing)))
  cc_POST(url, args, callopts)
}

cc_POST <- function(url, args, callopts, ...){
  tt <- POST(url, body=args, callopts, encode = "json")
  if(tt$status_code > 202){
    if(tt$status_code > 202) stop(tt$headers$statusmessage)
    if(content(tt)$status == "ERROR") stop(content(tt)$error_message)
  }
  res <- content(tt, as = "text")
  jsonlite::fromJSON(res, FALSE)
}

as_log <- function(x){
  stopifnot(is.logical(x))
  if(x) 'true' else NULL
}
