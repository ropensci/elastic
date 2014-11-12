#' Ping an Elasticsearch server.
#'
#' @export
#' @param ... Curl args passed on to \code{\link[httr]{GET}}
#' @examples \donttest{
#' ping()
#' }
ping <- function(...)
{
  conn <- connect()
  es_GET_(paste(conn$base, ":", conn$port, sep=""), ...)
}
