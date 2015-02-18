#' Ping an Elasticsearch server.
#'
#' @export
#' @param ... Curl args passed on to \code{\link[httr]{GET}}
#' @examples \dontrun{
#' ping()
#' }
ping <- function(...) es_GET_(make_url(es_get_auth()), ...)
