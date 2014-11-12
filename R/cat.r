#' Use the cat Elasticsearch api.
#' 
#' @export
#' @name cat
#' @param verbose If TRUE (default) the url call used printed to console.
#' @param index Index name
#' @param fields Fields to return, only used with \code{fielddata}
#' 
#' @details See \url{http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cat.html} 
#' for the cat API documentation.
#'
#' @examples \donttest{
#' # list Elasticsearch cat endpoints
#' cat_() 
#' 
#' # Do other cat operations
#' cat_aliases()
#' cat_aliases(index='plos')
#' cat_allocation()
#' cat_allocation(verbose=TRUE)
#' cat_count()
#' cat_count(index='plos')
#' cat_count(index='gbif')
#' cat_segments()
#' cat_segments(index='gbif')
#' cat_health()
#' cat_indices()
#' cat_master()
#' cat_nodes()
#' cat_pending_tasks()
#' cat_plugins()
#' cat_recovery(verbose=TRUE)
#' cat_recovery(index='gbif')
#' cat_thread_pool()
#' cat_thread_pool(verbose=TRUE)
#' cat_shards()
#' cat_fielddata()
#' cat_fielddata(fields='body')
#' }

#' @export
#' @rdname cat
cat_ <- function(verbose=FALSE, index=NULL, fields=NULL) cat_helper('', v=verbose, i=index, f=fields)

#' @export
#' @rdname cat
cat_aliases <- function(verbose=FALSE, index=NULL, fields=NULL) cat_helper('aliases', v=verbose, i=index, f=fields)

#' @export
#' @rdname cat
cat_allocation <- function(verbose=FALSE, index=NULL, fields=NULL) cat_helper('allocation', v=verbose, i=index, f=fields)

#' @export
#' @rdname cat
cat_count <- function(verbose=FALSE, index=NULL, fields=NULL) cat_helper('count', v=verbose, i=index, f=fields)

#' @export
#' @rdname cat
cat_segments <- function(verbose=FALSE, index=NULL, fields=NULL) cat_helper('segments', v=verbose, i=index, f=fields)

#' @export
#' @rdname cat
cat_health <- function(verbose=FALSE, index=NULL, fields=NULL) cat_helper('health', v=verbose, i=index, f=fields)

#' @export
#' @rdname cat
cat_indices <- function(verbose=FALSE, index=NULL, fields=NULL) cat_helper('indices', v=verbose, i=index, f=fields)

#' @export
#' @rdname cat
cat_master <- function(verbose=FALSE, index=NULL, fields=NULL) cat_helper('master', v=verbose, i=index, f=fields)

#' @export
#' @rdname cat
cat_nodes <- function(verbose=FALSE, index=NULL, fields=NULL) cat_helper('nodes', v=verbose, i=index, f=fields)

#' @export
#' @rdname cat
cat_pending_tasks <- function(verbose=FALSE, index=NULL, fields=NULL) cat_helper('pending_tasks', v=verbose, i=index, f=fields)

#' @export
#' @rdname cat
cat_plugins <- function(verbose=FALSE, index=NULL, fields=NULL) cat_helper('plugins', v=verbose, i=index, f=fields)

#' @export
#' @rdname cat
cat_recovery <- function(verbose=FALSE, index=NULL, fields=NULL) cat_helper('recovery', v=verbose, i=index, f=fields)

#' @export
#' @rdname cat
cat_thread_pool <- function(verbose=FALSE, index=NULL, fields=NULL) cat_helper('thread_pool', v=verbose, i=index, f=fields)

#' @export
#' @rdname cat
cat_shards <- function(verbose=FALSE, index=NULL, fields=NULL) cat_helper('shards', v=verbose, i=index, f=fields)

#' @export
#' @rdname cat
cat_fielddata <- function(verbose=FALSE, index=NULL, fields=NULL) cat_helper('fielddata', v=verbose, i=index, f=fields)


cat_helper <- function(what='', v=FALSE, i=NULL, f=NULL)
{
  conn <- es_get_auth()
  if(!is.null(f)) f <- paste(f, collapse=",")
  url <- sprintf("%s:%s/_cat/%s", conn$base, conn$port, what)
  if(!is.null(i)) url <- paste0(url, '/', i)  
  args <- ec(list(v = if(v) '' else NULL, fields=f))
  out <- GET(url, query=args)
  stop_for_status(out)
  if(v) message(URLdecode(out$url))
  dat <- content(out, as = "text")
  if(identical(dat, "")) message("Nothing to print") else base::cat(dat)
}
