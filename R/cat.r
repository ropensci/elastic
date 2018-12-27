#' Use the cat Elasticsearch api.
#'
#' @name cat
#' @param conn an Elasticsearch connection object, see [Elasticsearch]
#' @param verbose (logical) If `TRUE` (default) the url call used printed to console
#' @param index (character) Index name
#' @param fields (character) Fields to return, only used with `fielddata`
#' @param h (character) Fields to return
#' @param help (logical) Output available columns, and their meanings
#' @param bytes (logical) Give numbers back machine friendly. Default: `FALSE`
#' @param parse (logical) Parse to a data.frame or not. Default: `FALSE`
#' @param ... Curl args passed on to [crul::HttpClient]
#'
#' @details See <https://www.elastic.co/guide/en/elasticsearch/reference/current/cat.html>
#' for the cat API documentation.
#'
#' Note how [cat_()] has an underscore at the end to avoid conflict with the function
#' [base::cat()] in base R.
#'
#' @examples \dontrun{
#' # connection setup
#' (x <- connect())
#' 
#' # list Elasticsearch cat endpoints
#' cat_(x)
#'
#' # Do other cat operations
#' cat_aliases(x)
#' cat_aliases(x, index='plos')
#' cat_allocation(x)
#' cat_allocation(x, verbose=TRUE)
#' cat_count(x)
#' cat_count(x, index='plos')
#' cat_count(x, index='gbif')
#' cat_segments(x)
#' cat_segments(x, index='gbif')
#' cat_health(x)
#' cat_indices(x)
#' cat_master(x)
#' cat_nodes(x)
#' # cat_nodeattrs(x) # not available in older ES versions
#' cat_pending_tasks(x)
#' cat_plugins(x)
#' cat_recovery(x, verbose=TRUE)
#' cat_recovery(x, index='gbif')
#' cat_thread_pool(x)
#' cat_thread_pool(x, verbose=TRUE)
#' cat_shards(x)
#' cat_fielddata(x)
#' cat_fielddata(x, fields='body')
#'
#' # capture cat data into a data.frame
#' cat_(x, parse = TRUE)
#' cat_indices(x, parse = TRUE)
#' cat_indices(x, parse = TRUE, verbose = TRUE)
#' cat_count(x, parse = TRUE)
#' cat_count(x, parse = TRUE, verbose = TRUE)
#' cat_health(x, parse = TRUE)
#' cat_health(x, parse = TRUE, verbose = TRUE)
#'
#' # Get help - what does each column mean
#' head(cat_indices(x, help = TRUE, parse = TRUE))
#' cat_health(x, help = TRUE, parse = TRUE)
#' head(cat_nodes(x, help = TRUE, parse = TRUE))
#'
#' # Get back only certain fields
#' cat_nodes(x)
#' cat_nodes(x, h = c('ip','port','heapPercent','name'))
#' cat_nodes(x, h = c('id', 'ip', 'port', 'v', 'm'))
#' cat_indices(x, verbose = TRUE)
#' cat_indices(x, verbose = TRUE, h = c('index','docs.count','store.size'))
#'
#' # Get back machine friendly numbers instead of the normal human friendly
#' cat_indices(x, verbose = TRUE, bytes = TRUE)
#'
#' # Curl options
#' library("httr")
#' cat_count(x, config=verbose(x))
#' }

#' @export
#' @rdname cat
cat_ <- function(conn, parse = FALSE, ...) {
  is_conn(conn)
  conn$stop_es_version(110, "cat_aliases")
  cat_helper(conn, '', parse = parse, ...)
}

#' @export
#' @rdname cat
cat_aliases <- function(conn, verbose=FALSE, index=NULL, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
  is_conn(conn)
  conn$stop_es_version(110, "cat_aliases")
  cat_helper(conn, 'aliases', v=verbose, i=index, h=h, help=help, bytes=bytes, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_allocation <- function(conn, verbose=FALSE, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
  is_conn(conn)
  conn$stop_es_version(110, "cat_aliases")
  cat_helper(conn, 'allocation', v=verbose, h=h, help=help, bytes=bytes, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_count <- function(conn, verbose=FALSE, index=NULL, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
  is_conn(conn)
  conn$stop_es_version(110, "cat_aliases")
  cat_helper(conn, 'count', v=verbose, i=index, h=h, help=help, bytes=bytes, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_segments <- function(conn, verbose=FALSE, index=NULL, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
  is_conn(conn)
  conn$stop_es_version(110, "cat_aliases")
  cat_helper(conn, 'segments', v=verbose, i=index, h=h, help=help, bytes=bytes, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_health <- function(conn, verbose=FALSE, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
  is_conn(conn)
  conn$stop_es_version(110, "cat_aliases")
  cat_helper(conn, 'health', v=verbose, h=h, help=help, bytes=bytes, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_indices <- function(conn, verbose=FALSE, index=NULL, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
  is_conn(conn)
  conn$stop_es_version(110, "cat_aliases")
  cat_helper(conn, 'indices', v=verbose, i=index, h=h, help=help, bytes=bytes, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_master <- function(conn, verbose=FALSE, index=NULL, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
  is_conn(conn)
  conn$stop_es_version(110, "cat_aliases")
  cat_helper(conn, 'master', v=verbose, i=index, h=h, help=help, bytes=bytes, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_nodes <- function(conn, verbose=FALSE, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
  is_conn(conn)
  conn$stop_es_version(110, "cat_aliases")
  cat_helper(conn, 'nodes', v=verbose, h=h, help=help, bytes=bytes, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_nodeattrs <- function(conn, verbose=FALSE, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
  is_conn(conn)
  conn$stop_es_version(110, "cat_nodeattrs")
  is_conn(conn)
  conn$stop_es_version(160, "cat_nodeattrs")
  cat_helper(conn, 'nodeattrs', v=verbose, h=h, help=help, bytes=bytes, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_pending_tasks <- function(conn, verbose=FALSE, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
  is_conn(conn)
  conn$stop_es_version(110, "cat_aliases")
  cat_helper(conn, 'pending_tasks', v=verbose, h=h, help=help, bytes=bytes, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_plugins <- function(conn, verbose=FALSE, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
  is_conn(conn)
  conn$stop_es_version(110, "cat_aliases")
  cat_helper(conn, 'plugins', v=verbose, h=h, help=help, bytes=bytes, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_recovery <- function(conn, verbose=FALSE, index=NULL, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
  is_conn(conn)
  conn$stop_es_version(110, "cat_aliases")
  cat_helper(conn, 'recovery', v=verbose, i=index, h=h, help=help, bytes=bytes, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_thread_pool <- function(conn, verbose=FALSE, index=NULL, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
  is_conn(conn)
  conn$stop_es_version(110, "cat_aliases")
  cat_helper(conn, 'thread_pool', v=verbose, i=index, h=h, help=help, bytes=bytes, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_shards <- function(conn, verbose=FALSE, index=NULL, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
  is_conn(conn)
  conn$stop_es_version(110, "cat_aliases")
  cat_helper(conn, 'shards', v=verbose, i=index, h=h, help=help, bytes=bytes, parse=parse, ...)
}

#' @export
#' @rdname cat
cat_fielddata <- function(conn, verbose=FALSE, index=NULL, fields=NULL, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
  is_conn(conn)
  conn$stop_es_version(110, "cat_aliases")
  cat_helper(conn, 'fielddata', v=verbose, i=index, f=fields, h=h, help=help, bytes=bytes, parse=parse, ...)
}

## FIXME - maybe, maybe not incorporate these
# cat_repositories <- function(conn, verbose=FALSE, index=NULL, fields=NULL, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
#   cat_helper(conn, 'repositories', v=verbose, i=index, f=fields, h=h, help=help, bytes=bytes, parse=parse, ...)
# }
#
# cat_snapshots <- function(conn, repository, verbose=FALSE, index=NULL, fields=NULL, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
#   cat_helper(conn, 'snapshots', v=verbose, i=index, f=fields, h=h, help=help, bytes=bytes, parse=parse, r=repository, ...)
# }


cat_helper <- function(conn, what='', v=FALSE, i=NULL, f=NULL, h=NULL, help=FALSE, bytes=FALSE, parse=FALSE, ...) {
  stopifnot(is.logical(v), is.logical(help), is.logical(parse), is.logical(bytes))
  help_or_verbose(v, help)
  url <- conn$make_url()
  if (!is.null(f)) f <- paste(f, collapse = ",")
  url <- sprintf("%s/_cat/%s", url, what)
  if (!is.null(i)) url <- paste0(url, '/', i)
  args <- ec(list(v = lnull(v), help = lnull(help), fields = f,
                  h = asnull(paste0(h, collapse = ",")),
                  bytes = ifbytes(bytes)))
  cli <- crul::HttpClient$new(url = url,
    headers = c(conn$headers, json_type()), 
    opts = c(conn$opts, ...),
    auth = crul::auth(conn$user, conn$pwd)
  )
  out <- cli$get(query = args)
  if (out$status_code > 202) geterror(out)
  dat <- out$parse("UTF-8")
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
