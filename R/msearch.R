#' @title Multi-search
#'
#' @description Performs multiple searches, defined in a file
#'
#' @export
#' @param conn an Elasticsearch connection object, see [connect()]
#' @param x (character) A file path
#' @param raw (logical) Get raw JSON back or not.
#' @param asdf (logical) If `TRUE`, use [jsonlite::fromJSON()]
#' to parse JSON directly to a data.frame. If `FALSE` (Default), list 
#' output is given.
#' @param ... Curl args passed on to [crul::verb-POST]
#'
#' @details This function behaves similarly to [docs_bulk()] - 
#' performs searches based on queries defined in a file.
#' @seealso [Search_uri()] [Search()]
#' @examples \dontrun{
#' x <- connect()
#' 
#' msearch1 <- system.file("examples", "msearch_eg1.json", package = "elastic")
#' readLines(msearch1)
#' msearch(x, msearch1)
#'
#' tf <- tempfile(fileext = ".json")
#' cat('{"index" : "shakespeare"}', file = tf, sep = "\n")
#' cat('{"query" : {"match_all" : {}}, "from" : 0, "size" : 5}',  sep = "\n",
#'    file = tf, append = TRUE)
#' readLines(tf)
#' msearch(x, tf)
#' }
msearch <- function(conn, x, raw = FALSE, asdf = FALSE, ...) {
  if (!file.exists(x)) stop("file ", x, " does not exist", call. = FALSE)
  url <- file.path(conn$make_url(), '_msearch')
  cli <- conn$make_conn(url)
  tt <- cli$post(body = crul::upload(x, "application/json"), encode = "json")
  geterror(tt)
  res <- tt$parse("UTF-8")
  if (raw) res else jsonlite::fromJSON(res, asdf)
}
