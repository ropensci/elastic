#' Use the cat Elasticsearch api.
#'
#' @name cat
#' @param verbose (logical) If \code{TRUE} (default) the url call used printed to console
#' @param index (character) Index name
#' @param fields (character) Fields to return, only used with \code{fielddata}
#' @param h (character) Fields to return
#' @param help (logical) Output available columns, and their meanings
#' @param bytes (logical) Give numbers back machine friendly. Default: \code{FALSE}
#' @param parse (logical) Parse to a data.frame or not. Default: \code{FALSE}
#' @param ... Curl args passed on to \code{\link[httr]{GET}}
#'
#' @details See \url{https://www.elastic.co/guide/en/elasticsearch/reference/current/cat.html}
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
#' # cat_nodeattrs() # not available in older ES versions
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
#' # Get help - what does each column mean
#' head(cat_indices(help = TRUE, parse = TRUE))
#' cat_health(help = TRUE, parse = TRUE)
#' head(cat_nodes(help = TRUE, parse = TRUE))
#'
#' # Get back only certain fields
#' cat_nodes()
#' cat_nodes(h = c('ip','port','heapPercent','name'))
#' cat_nodes(h = c('id', 'ip', 'port', 'v', 'm'))
#' cat_indices(verbose = TRUE)
#' cat_indices(verbose = TRUE, h = c('index','docs.count','store.size'))
#'
#' # Get back machine friendly numbers instead of the normal human friendly
#' cat_indices(verbose = TRUE, bytes = TRUE)
#'
#' # Curl options
#' library("httr")
#' cat_count(config=verbose())
#' }

#' @export
#' @rdname cat
cat_ <- function(parse = FALSE, ...) {
  stop_es_version(110, "cat_aliases")
  cat_helper('', parse = parse, ...)
}

#' @export
#' @rdname cat
cat_aliases <- function(verbose=FALSE, index=NULL, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
  stop_es_version(110, "cat_aliases")
  cat_helper('aliases', v=verbose, i=index, h=h, help=help, bytes=bytes, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_allocation <- function(verbose=FALSE, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
  stop_es_version(110, "cat_aliases")
  cat_helper('allocation', v=verbose, h=h, help=help, bytes=bytes, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_count <- function(verbose=FALSE, index=NULL, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
  stop_es_version(110, "cat_aliases")
  cat_helper('count', v=verbose, i=index, h=h, help=help, bytes=bytes, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_segments <- function(verbose=FALSE, index=NULL, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
  stop_es_version(110, "cat_aliases")
  cat_helper('segments', v=verbose, i=index, h=h, help=help, bytes=bytes, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_health <- function(verbose=FALSE, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
  stop_es_version(110, "cat_aliases")
  cat_helper('health', v=verbose, h=h, help=help, bytes=bytes, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_indices <- function(verbose=FALSE, index=NULL, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
  stop_es_version(110, "cat_aliases")
  cat_helper('indices', v=verbose, i=index, h=h, help=help, bytes=bytes, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_master <- function(verbose=FALSE, index=NULL, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
  stop_es_version(110, "cat_aliases")
  cat_helper('master', v=verbose, i=index, h=h, help=help, bytes=bytes, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_nodes <- function(verbose=FALSE, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
  stop_es_version(110, "cat_aliases")
  cat_helper('nodes', v=verbose, h=h, help=help, bytes=bytes, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_nodeattrs <- function(verbose=FALSE, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
  stop_es_version(110, "cat_nodeattrs")
  stop_es_version(160, "cat_nodeattrs")
  cat_helper('nodeattrs', v=verbose, h=h, help=help, bytes=bytes, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_pending_tasks <- function(verbose=FALSE, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
  stop_es_version(110, "cat_aliases")
  cat_helper('pending_tasks', v=verbose, h=h, help=help, bytes=bytes, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_plugins <- function(verbose=FALSE, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
  stop_es_version(110, "cat_aliases")
  cat_helper('plugins', v=verbose, h=h, help=help, bytes=bytes, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_recovery <- function(verbose=FALSE, index=NULL, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
  stop_es_version(110, "cat_aliases")
  cat_helper('recovery', v=verbose, i=index, h=h, help=help, bytes=bytes, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_thread_pool <- function(verbose=FALSE, index=NULL, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
  stop_es_version(110, "cat_aliases")
  cat_helper('thread_pool', v=verbose, i=index, h=h, help=help, bytes=bytes, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_shards <- function(verbose=FALSE, index=NULL, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
  stop_es_version(110, "cat_aliases")
  cat_helper('shards', v=verbose, i=index, h=h, help=help, bytes=bytes, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_fielddata <- function(verbose=FALSE, index=NULL, fields=NULL, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
  stop_es_version(110, "cat_aliases")
  cat_helper('fielddata', v=verbose, i=index, f=fields, h=h, help=help, bytes=bytes, parse=parse, ...)
}

## FIXME - maybe, maybe not incorporate these
# cat_repositories <- function(verbose=FALSE, index=NULL, fields=NULL, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
#   cat_helper('repositories', v=verbose, i=index, f=fields, h=h, help=help, bytes=bytes, parse=parse, ...)
# }
#
# cat_snapshots <- function(repository, verbose=FALSE, index=NULL, fields=NULL, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
#   cat_helper('snapshots', v=verbose, i=index, f=fields, h=h, help=help, bytes=bytes, parse=parse, r=repository, ...)
# }


cat_helper <- function(what='', v=FALSE, i=NULL, f=NULL, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
  checkconn()
  stopifnot(is.logical(v), is.logical(help), is.logical(parse), is.logical(bytes))
  help_or_verbose(v, help)
  url <- make_url(es_get_auth())
  if (!is.null(f)) f <- paste(f, collapse = ",")
  url <- sprintf("%s/_cat/%s", url, what)
  if (!is.null(i)) url <- paste0(url, '/', i)
  # if (!is.null(r)) url <- paste0(url, '/', r)
  args <- ec(list(v = lnull(v), help = lnull(help), fields = f,
                  h = asnull(paste0(h, collapse = ",")),
                  bytes = ifbytes(bytes)))
  out <- GET(url, query = args, make_up(), ...)
  if (out$status_code > 202) geterror(out)
  dat <- content(out, as = "text")
  if (identical(dat, "")) {
    message("Nothing to print")
  } else {
    if (parse) {
      cat_pretty(dat, v, help)
    } else {
      base::cat(dat)
    }
  }
}

cat_pretty <- function(x, verbose = FALSE, help = FALSE) {
  if (help) {
    read.table(text = x, sep = "|", stringsAsFactors = FALSE)
  } else {
    read.delim(text = x, sep = "", header = verbose, stringsAsFactors = FALSE)
  }
}

help_or_verbose <- function(x, y) {
  if (x) {
    if (y) {
      stop("Can only set verbose or help, not both")
    }
  }
}

lnull <- function(x) {
  if (x) {
    ''
  } else {
    NULL
  }
}

asnull <- function(x) {
  if (nchar(x) == 0 || is.null(x)) {
    NULL
  } else {
    x
  }
}

ifbytes <- function(x) {
  if (x) {
    "b"
  } else {
    NULL
  }
}
