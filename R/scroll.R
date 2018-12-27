#' Scroll search function
#'
#' @export
#'
#' @param conn an Elasticsearch connection object, see [Elasticsearch]
#' @param x (character) For `scroll`, a single scroll id; for
#' `scroll_clear`, one or more scroll id's
#' @param time_scroll (character) Specify how long a consistent view of the
#' index should be maintained for scrolled search, e.g., "30s", "1m".
#' See [units-time].
#' @param raw (logical) If `FALSE` (default), data is parsed to list.
#' If `TRUE`, then raw JSON.
#' @param asdf (logical) If `TRUE`, use [jsonlite::fromJSON()]
#' to parse JSON directly to a data.frame. If `FALSE` (Default), list
#' output is given.
#' @param stream_opts (list) A list of options passed to
#' [jsonlite::stream_out()] - Except that you can't pass `x` as
#' that's the data that's streamed out, and pass a file path sinstead of a
#' connection to \code{con}. \code{pagesize} param doesn't do much as
#' that's more or less controlled by paging with ES.
#' @param all (logical) If `TRUE` (default) then all search contexts
#' cleared.  If `FALSE`, scroll id's must be passed to `x`
#' @param ... Curl args passed on to [httr::POST()]
#'
#' @seealso [Search()]
#' @references
#' <https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-scroll.html>
#'
#' @return `scroll()` returns a list, identical to what
#' [Search()] returns. With attribute `scroll` that is the
#' scroll value set via the `time_scroll` parameter
#'
#' `scroll_clear()` returns a boolean (`TRUE` on success)
#'
#' @section Scores:
#' Scores will be the same for all documents that are returned from a
#' scroll request. Dems da rules.
#'
#' @section Inputs:
#' Inputs to `scroll()` can be one of:
#'
#' - list - This usually will be the output of [Search()], but
#'  you could in theory make a list yourself with the appropriate elements
#' - character - A scroll ID - this is typically the scroll id output
#'  from a call to [Search()], accessed like \code{res$`_scroll_id`}
#'
#' All other classes passed to `scroll()` will fail with message
#'
#' Lists passed to `scroll()` without a `_scroll_id` element will
#' trigger an error.
#'
#' From lists output form [Search()] there should be an attribute
#' ("scroll") that is the `scroll` value set in the [Search()]
#' request - if that attribute is missing from the list, we'll attempt to
#' use the `time_scroll` parameter value set in the 
#' `scroll()` function call
#'
#' The output of `scroll()` has the scroll time value as an attribute so
#' the output can be passed back into `scroll()` to continue.
#'
#' @section Clear scroll:
#' Search context are automatically removed when the scroll timeout has
#' been exceeded.  Keeping scrolls open has a cost, so scrolls should be
#' explicitly cleared as soon  as the scroll is not being used anymore
#' using `scroll_clear`
#'
#' @section Sliced scrolling:
#' For scroll queries that return a lot of documents it is possible to split
#' the scroll in multiple slices which can be consumed independently.
#'
#' See the example in this man file.
#'
#' @section Aggregations:
#' If the request specifies aggregations, only the initial search response
#' will contain the aggregations results.
#'
#' @examples \dontrun{
#' # connection setup
#' (con <- connect())
#' 
#' # Basic usage - can use across all indices
#' res <- Search(con, time_scroll="1m")
#' scroll(con, res)$`_scroll_id`
#'
#' # use on a specific index - and specify a query
#' res <- Search(con, index = 'shakespeare', q="a*", time_scroll="1m")
#' res$`_scroll_id`
#'
#' # Setting "sort=_doc" to turn off sorting of results - faster
#' res <- Search(con, index = 'shakespeare', q="a*", time_scroll="1m",
#'   body = '{"sort": ["_doc"]}')
#' res$`_scroll_id`
#'
#' # Pass scroll_id to scroll function
#' scroll(con, res$`_scroll_id`)
#'
#' # Get all results - one approach is to use a while loop
#' res <- Search(con, index = 'shakespeare', q="a*", time_scroll="5m",
#'   body = '{"sort": ["_doc"]}')
#' out <- res$hits$hits
#' hits <- 1
#' while(hits != 0){
#'   res <- scroll(con, res$`_scroll_id`, time_scroll="5m")
#'   hits <- length(res$hits$hits)
#'   if(hits > 0)
#'     out <- c(out, res$hits$hits)
#' }
#' length(out)
#' res$hits$total
#' out[[1]]
#'
#' # clear scroll
#' ## individual scroll id
#' res <- Search(con, index = 'shakespeare', q="a*", time_scroll="5m",
#'   body = '{"sort": ["_doc"]}')
#' scroll_clear(con, res$`_scroll_id`)
#'
#' ## many scroll ids
#' res1 <- Search(con, index = 'shakespeare', q="c*", time_scroll="5m",
#'   body = '{"sort": ["_doc"]}')
#' res2 <- Search(con, index = 'shakespeare', q="d*", time_scroll="5m",
#'   body = '{"sort": ["_doc"]}')
#' nodes_stats(con, metric = "indices")$nodes[[1]]$indices$search$open_contexts
#' scroll_clear(con, c(res1$`_scroll_id`, res2$`_scroll_id`))
#' nodes_stats(con, metric = "indices")$nodes[[1]]$indices$search$open_contexts
#'
#' ## all scroll ids
#' res1 <- Search(con, index = 'shakespeare', q="f*", time_scroll="1m",
#'   body = '{"sort": ["_doc"]}')
#' res2 <- Search(con, index = 'shakespeare', q="g*", time_scroll="1m",
#'   body = '{"sort": ["_doc"]}')
#' res3 <- Search(con, index = 'shakespeare', q="k*", time_scroll="1m",
#'   body = '{"sort": ["_doc"]}')
#' scroll_clear(con, all = TRUE)
#'
#' ## sliced scrolling
#' body1 <- '{
#'   "slice": {
#'     "id": 0,
#'     "max": 2
#'   },
#'   "query": {
#'     "match" : {
#'       "text_entry" : "a*"
#'     }
#'   }
#' }'
#'
#' body2 <- '{
#'   "slice": {
#'     "id": 1,
#'     "max": 2
#'   },
#'   "query": {
#'     "match" : {
#'       "text_entry" : "a*"
#'     }
#'   }
#' }'
#'
#' res1 <- Search(con, index = 'shakespeare', time_scroll="1m", body = body1)
#' res2 <- Search(con, index = 'shakespeare', time_scroll="1m", body = body2)
#' scroll(con, res1$`_scroll_id`)
#' scroll(con, res2$`_scroll_id`)
#'
#' out1 <- list()
#' hits <- 1
#' while(hits != 0){
#'   tmp1 <- scroll(con, res1$`_scroll_id`)
#'   hits <- length(tmp1$hits$hits)
#'   if(hits > 0)
#'     out1 <- c(out1, tmp1$hits$hits)
#' }
#'
#' out2 <- list()
#' hits <- 1
#' while(hits != 0){
#'   tmp2 <- scroll(con, res2$`_scroll_id`)
#'   hits <- length(tmp2$hits$hits)
#'   if(hits > 0)
#'     out2 <- c(out2, tmp2$hits$hits)
#' }
#'
#' c(
#'  lapply(out1, "[[", "_source"),
#'  lapply(out2, "[[", "_source")
#' )
#'
#'
#' # using jsonlite::stream_out
#' res <- Search(con, time_scroll = "1m")
#' file <- tempfile()
#' scroll(con, 
#'   x = res$`_scroll_id`,
#'   stream_opts = list(file = file)
#' )
#' jsonlite::stream_in(file(file))
#' unlink(file)
#'
#' ## stream_out and while loop
#' (file <- tempfile())
#' res <- Search(con, index = "shakespeare", time_scroll = "5m",
#'   size = 1000, stream_opts = list(file = file))
#' while(!inherits(res, "warning")) {
#'   res <- tryCatch(scroll(
#'     conn = con,
#'     x = res$`_scroll_id`,
#'     time_scroll = "5m",
#'     stream_opts = list(file = file)
#'   ), warning = function(w) w)
#' }
#' NROW(df <- jsonlite::stream_in(file(file)))
#' head(df)
#' }
scroll <- function(conn, x, time_scroll = "1m", raw = FALSE, asdf = FALSE,
                   stream_opts = list(), ...) {
  UseMethod("scroll", x)
}

#' @export
scroll.default <- function(conn, x, time_scroll = "1m", raw = FALSE, asdf = FALSE,
                           stream_opts = list(), ...) {
  stop("no 'scroll()' method for ", class(x), call. = FALSE)
}

#' @export
scroll.list <- function(conn, x, time_scroll = "1m", raw = FALSE, asdf = FALSE,
                        stream_opts = list(), force_scroll = FALSE, ...) {
  scroll_ <- NULL
  if (!is.null(x$`_scroll_id`)) {
    scroll_ <- attr(x, "scroll")
  } else {
    stop("when passing a list, there must be a `_scroll_id` element",
         call. = FALSE)
  }
  if (is.null(scroll_)) {
    message("didn't find 'scroll' value in attributes, using 'scroll' param")
    scroll_ <- time_scroll
  }
  if (force_scroll) scroll_ <- time_scroll
  scroll(conn, x$`_scroll_id`, time_scroll = scroll_, raw = raw,
                   asdf = asdf, stream_opts = stream_opts, ...)
}

#' @export
scroll.character <- function(conn, x, time_scroll = "1m", raw = FALSE, asdf = FALSE,
                             stream_opts = list(), ...) {

  calls <- names(list(...))
  if ("scroll" %in% calls) {
    stop("The parameter `scroll` has been removed - use `time_scroll`")
  }
  if (conn$es_ver() < 200) {
    body <- x
    args <- list(scroll = time_scroll)
  } else {
    body <- list(scroll = time_scroll, scroll_id = x)
    args <- list()
  }
  tmp <- scroll_POST(
    conn = conn,
    path = "_search/scroll",
    args = args,
    body = body,
    raw = raw,
    asdf = asdf,
    stream_opts = stream_opts, ...)
  attr(tmp, "scroll") <- time_scroll
  return(tmp)
}

#' @export
#' @rdname scroll
scroll_clear <- function(conn, x = NULL, all = FALSE, ...) {
  if (all) {
    path <- "_search/scroll/_all"
    body <- NULL
  } else {
    if (is.null(x)) stop("if all=FALSE, x must not be NULL",
                                 call. = FALSE)
    path <- "_search/scroll"
    body <- list(scroll_id = x)
  }
  scroll_DELETE(conn, path, body = body, ...)
}
