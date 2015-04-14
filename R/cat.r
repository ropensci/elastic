#' Use the cat Elasticsearch api.
#'
#' @name cat
#' @param verbose If TRUE (default) the url call used printed to console.
#' @param index Index name
#' @param fields Fields to return, only used with \code{fielddata}
#' @param ... Curl args passed on to \code{\link[httr]{GET}}
#'
#' @details See \url{http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cat.html}
#' for the cat API documentation.
#'
#' Note how \code{\link{cat_}} has an underscore at the end to avoid conflict with the function
#' \code{\link{cat}} in base R.
#'
#' @examples \dontrun{
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
#'
#' # capture cat data into a data.frame
#' cat_(parse = TRUE)
#' cat_indices(parse = TRUE)
#' cat_indices(parse = TRUE, verbose = TRUE)
#' cat_count(parse = TRUE)
#' cat_count(parse = TRUE, verbose = TRUE)
#' cat_health(parse = TRUE)
#' cat_health(parse = TRUE, verbose = TRUE)
#'
#' # Curl options
#' library("httr")
#' cat_count(config=verbose())
#' }

#' @export
#' @rdname cat
cat_ <- function(verbose=FALSE, index=NULL, fields=NULL, parse=FALSE, ...) {
  cat_helper('', v=verbose, i=index, f=fields, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_aliases <- function(verbose=FALSE, index=NULL, fields=NULL, parse=FALSE, ...) {
  cat_helper('aliases', v=verbose, i=index, f=fields, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_allocation <- function(verbose=FALSE, index=NULL, fields=NULL, parse=FALSE, ...) {
  cat_helper('allocation', v=verbose, i=index, f=fields, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_count <- function(verbose=FALSE, index=NULL, fields=NULL, parse=FALSE, ...) {
  cat_helper('count', v=verbose, i=index, f=fields, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_segments <- function(verbose=FALSE, index=NULL, fields=NULL, parse=FALSE, ...) {
  cat_helper('segments', v=verbose, i=index, f=fields, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_health <- function(verbose=FALSE, index=NULL, fields=NULL, parse=FALSE, ...) {
  cat_helper('health', v=verbose, i=index, f=fields, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_indices <- function(verbose=FALSE, index=NULL, fields=NULL, parse=FALSE, ...) {
  cat_helper('indices', v=verbose, i=index, f=fields, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_master <- function(verbose=FALSE, index=NULL, fields=NULL, parse=FALSE, ...) {
  cat_helper('master', v=verbose, i=index, f=fields, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_nodes <- function(verbose=FALSE, index=NULL, fields=NULL, parse=FALSE, ...) {
  cat_helper('nodes', v=verbose, i=index, f=fields, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_pending_tasks <- function(verbose=FALSE, index=NULL, fields=NULL, parse=FALSE, ...) {
  cat_helper('pending_tasks', v=verbose, i=index, f=fields, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_plugins <- function(verbose=FALSE, index=NULL, fields=NULL, parse=FALSE, ...) {
  cat_helper('plugins', v=verbose, i=index, f=fields, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_recovery <- function(verbose=FALSE, index=NULL, fields=NULL, parse=FALSE, ...) {
  cat_helper('recovery', v=verbose, i=index, f=fields, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_thread_pool <- function(verbose=FALSE, index=NULL, fields=NULL, parse=FALSE, ...) {
  cat_helper('thread_pool', v=verbose, i=index, f=fields, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_shards <- function(verbose=FALSE, index=NULL, fields=NULL, parse=FALSE, ...) {
  cat_helper('shards', v=verbose, i=index, f=fields, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_fielddata <- function(verbose=FALSE, index=NULL, fields=NULL, parse=FALSE, ...) {
  cat_helper('fielddata', v=verbose, i=index, f=fields, parse=parse, ...)
}


cat_helper <- function(what='', v=FALSE, i=NULL, f=NULL, parse=FALSE, ...) {
  checkconn()
  url <- make_url(es_get_auth())
  if (!is.null(f)) f <- paste(f, collapse = ",")
  url <- sprintf("%s/_cat/%s", url, what)
  if (!is.null(i)) url <- paste0(url, '/', i)
  args <- ec(list(v = if(v) '' else NULL, fields = f))
  out <- GET(url, query = args, make_up(), ...)
  if (out$status_code > 202) geterror(out)
  dat <- content(out, as = "text")
  if (identical(dat, "")) {
    message("Nothing to print")
  } else {
    if (parse) {
      cat_pretty(dat, v)
    } else {
      base::cat(dat)
    }
  }
}

cat_pretty <- function(x, verbose = FALSE) {
  read.table(text = x, sep = "", header = verbose)
}
