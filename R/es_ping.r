#' Ping an Elasticsearch server.
#' 
#' @export
#' @param raw If TRUE (default), data is parsed to list. If FALSE, then raw JSON.
#' @param callopts Curl args passed on to httr::POST.
#' @examples \dontrun{
#' es_ping()
#' }

es_ping <- function(raw=FALSE, callopts=list())
{
  tmp <- es_GET("", NULL, NULL, NULL, NULL, NULL, FALSE, callopts)
  if(raw) tmp else rjson::fromJSON(tmp)
}
