#' Use the cat Elasticsearch api.
#' 
#' @export
#' @import httr 
#' 
#' @param what What to print, one of '', aliases, allocation, count, segments, health, indices, 
#' master, nodes, pending_tasks, plugins, recovery, thread_pool, or shards. 
#' @param verbose If TRUE (default) the url call used printed to console.
#' @param index Index name
#' 
#' @details See \url{http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cat.html} 
#' for the cat API documentation.
#'
#' @examples \dontrun{
#' es_cat()
#' es_cat('aliases')
#' es_cat('aliases', index='mran')
#' es_cat('allocation')
#' es_cat('allocation', verbose=TRUE)
#' es_cat('count')
#' es_cat('count', index='mran')
#' es_cat('count', index='twitter')
#' es_cat('segments')
#' es_cat('segments', index='mran')
#' es_cat('health')
#' es_cat('indices')
#' es_cat('indices', index='movies')
#' es_cat('indices', index='mran')
#' es_cat('indices', index='mran', verbose=TRUE)
#' es_cat('master')
#' es_cat('nodes')
#' es_cat('pending_tasks')
#' es_cat('plugins')
#' es_cat('recovery')
#' es_cat('recovery', index='mran')
#' es_cat('thread_pool')
#' es_cat('shards')
#' }

es_cat <- function(what='', verbose=FALSE, index=NULL)
{
  conn <- es_get_auth()
  if(!is.null(fields)) fields <- paste(fields, collapse=",")
  url <- sprintf("%s:%s/_cat/%s", conn$base, conn$port, what)
  if(!is.null(index)) url <- paste0(url, '/', index)  
  args <- es_compact(list(v = if(verbose) '' else NULL))
  out <- GET(url, query=args)
  stop_for_status(out)
  if(verbose) message(URLdecode(out$url))
  dat <- content(out, as = "text")
  if(identical(dat, "")) message("Nothing to print") else cat(dat)
}