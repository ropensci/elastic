#' Ping an Elasticsearch server.
#'
#' @export
#' @param ... Curl args passed on to [httr::GET()]
#' @seealso [connect()]
#' @examples \dontrun{
#' ping()
#' }
ping <- function(...) { 
  es_GET_(make_url(es_get_auth()), ...)
}

checkconn <- function(...) {
  res <- tryCatch(HEAD(make_url(es_get_auth()), make_up(), es_env$headers, ...), error = function(e) e)
  if (inherits(res, "error")) {
    stop("Check your connection, server may be down, url or port incorrect, or authentication wrong", call. = FALSE)
  }
}
