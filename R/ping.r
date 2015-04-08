#' Ping an Elasticsearch server.
#'
#' @export
#' @param ... Curl args passed on to \code{\link[httr]{GET}}
#' @examples \dontrun{
#' ping()
#' }
ping <- function(...) { 
  checkconn()
  es_GET_(make_url(es_get_auth()), ...)
}

checkconn <- function(...) {
  res <- tryCatch(HEAD(make_url(es_get_auth())), error = function(e) e)
  if (is(res, "error")) {
    stop("Check your connection, server may be down, url or port incorrect, or authentication wrong", call. = FALSE)
  }
}
