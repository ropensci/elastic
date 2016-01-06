#' Delete a document.
#'
#' @export
#' @param index (character) The name of the index. Required
#' @param type (character) The type of the document. Required
#' @param id (numeric) The document ID. Required
#' @param refresh (logical) Refresh the index after performing the operation
#' @param routing (charcter) Specific routing value
#' @param timeout (charcter) Explicit operation timeout, e.g,. 5m (for 5 minutes)
#' @param version (character) Explicit version number for concurrency control
#' @param version_type (character) Specific version type. One of internal or external
#' @param callopts Curl args passed on to \code{\link[httr]{DELETE}}
#' @param ... Further args to query DSL
#' @references
#' \url{https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-delete.html}
#' @examples \dontrun{
#' docs_delete(index='plos', type='article', id=36)
#' # docs_get(index='plos', type='article', id=36) # and the document is gone
#' }

docs_delete <- function(index, type, id, refresh=NULL, routing=NULL, timeout=NULL, version=NULL,
  version_type=NULL, callopts=list(), ...) {
  
  checkconn()
  url <- make_url(es_get_auth())
  url <- sprintf("%s/%s/%s/%s", url, esc(index), esc(type), id)
  args <- ec(list(refresh=refresh, routing=routing, timeout=timeout,
                  version=version, version_type=version_type, ...))
  if (length(args) == 0) args <- NULL
  out <- DELETE(url, query=args, mc(make_up(), callopts))
  stop_for_status(out)
  tt <- content(out, as="text")
  jsonlite::fromJSON(tt, FALSE)
}
