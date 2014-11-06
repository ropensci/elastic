#' Clear either all caches or specific cached associated with one ore more indices.
#' 
#' @export
#' 
#' @param index The name of the index to scope the operation
#' @param filter (logical) Clear filter caches
#' @param filter_keys (character) A vector of keys to clear when using the \code{filter_cache} 
#' parameter (default: all)
#' @param fielddata (logical) Clear field data
#' @param query_cache (logical) Clear query caches
#' @param id_cache (logical) Clear ID caches for parent/child
#' @param callopts Curl args passed on to httr::POST.
#' @references 
#' \url{http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-analyze.html} 
#' @examples \donttest{
#' es_clear_cache()
#' es_clear_cache(index = "plos")
#' es_clear_cache(index = "shakespeare")
#' es_clear_cache(index = c("plos","shakespeare"))
#' es_clear_cache(filter = TRUE)
#' library('httr')
#' es_clear_cache(callopts=verbose())
#' }
es_clear_cache <- function(index=NULL, filter=FALSE, filter_keys=NULL, fielddata=FALSE, 
  query_cache=FALSE, id_cache=FALSE, callopts=list())
{
  conn <- es_connect()
  if(!is.null(index)) 
    url <- sprintf("%s:%s/%s/_cache/clear", conn$base, conn$port, cl(index)) 
  else 
    url <- sprintf("%s:%s/_cache/clear", conn$base, conn$port)
  args <- ec(list(filter=as_log(filter), filter_keys=filter_keys, fielddata=as_log(fielddata), 
                  query_cache=as_log(query_cache), id_cache=as_log(id_cache)))
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
