#' Ping an Elasticsearch server.
#'
#' @export
#' @param conn an Elasticsearch connection object, see [Elasticsearch]
#' @param ... Curl args passed on to [crul::verb-GET]
#' @seealso [connect()]
#' @examples \dontrun{
#' x <- connect()
#' ping(x)
#' # ideally call ping on the connetion object itself
#' x$ping()
#' }
ping <- function(conn, ...) {
  .Deprecated(msg = "call ping() on the connection object; 
this standalone function will be removed in the next version")
  conn$ping(...)
}
