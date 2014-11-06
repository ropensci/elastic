#' Start or stop indexing a document or many documents.
#' 
#' @export
#' @param index Index name
#' @param raw If TRUE (default), data is parsed to list. If FALSE, then raw JSON.
#' @param callopts Curl args passed on to httr::POST.
#' @param verbose If TRUE (default) the url call used printed to console.
#' @param ... Further args passed on to elastic search HTTP API as parameters.
#' 
#' @details The function returns TRUE. Though note that this can result even 
#'    if the database does not exist in CouchDB. 
#' @references See docs for the Elasticsearch River plugin \url{#} that lets you 
#'     easily index CouchDB databases.
#' 
#' @examples \dontrun{
#' es_index_delete(index='plos')
#' }

es_index_delete <- function(index, raw=FALSE, callopts=list(), verbose=TRUE)
{
  conn <- es_connect()
  url <- paste0(conn$base, ":", conn$port, "/", index)
  out <- DELETE(url, callopts)
  stop_for_status(out)
  if(verbose) message(URLdecode(out$url))
  tt <- structure(content(out, as="text"), class="index_delete")
  if(raw){ tt } else { es_parse(tt) }
}
