#' @title Multi-search
#' 
#' @description Performs multiple searches, defined in a file
#'
#' @export
#' @param x (character) A file path 
#' @param raw (logical) Get raw JSON back or not.
#' @param asdf (logical) If \code{TRUE}, use \code{\link[jsonlite]{fromJSON}} to parse JSON
#' directly to a data.frame. If \code{FALSE} (Default), list output is given.
#' @param ... Curl args passed on to \code{\link[httr]{POST}}
#' 
#' @details This function behaves similarly to \code{\link{docs_bulk}} - performs
#' searches based on queries defined in a file.
#' @seealso \code{\link{Search_uri}} \code{\link{Search}}
#' @examples \dontrun{
#' connect()
#' msearch1 <- system.file("examples", "msearch_eg1.json", package = "elastic")
#' readLines(msearch1)
#' msearch(msearch1)
#' 
#' cat('{"index" : "shakespeare"}', file = "~/mysearch.json", sep = "\n")
#' cat('{"query" : {"match_all" : {}}, "from" : 0, "size" : 5}',  sep = "\n",
#'    file = "~/mysearch.json", append = TRUE)
#' msearch("~/mysearch.json")
#' }
msearch <- function(x, raw = FALSE, asdf = FALSE, ...) {
  checkconn()
  if (!file.exists(x)) stop("file ", x, " does not exist", call. = FALSE)
  conn <- es_get_auth()
  url <- paste0(conn$base, ":", conn$port, '/_msearch')
  tt <- POST(url, make_up(), ..., body = upload_file(x, type = "application/json"), encode = "json")
  geterror(tt)
  res <- content(tt, as = "text")
  if (raw) res else jsonlite::fromJSON(res, asdf)
}
