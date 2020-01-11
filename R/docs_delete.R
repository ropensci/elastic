#' Delete a document
#'
#' @export
#' @param conn an Elasticsearch connection object, see [connect()]
#' @param index (character) The name of the index. Required
#' @param id (numeric/character) The document ID. Can be numeric or character. 
#' Required
#' @param type (character) The type of the document. optional
#' @param refresh (logical) Refresh the index after performing the operation
#' @param routing (character) Specific routing value
#' @param timeout (character) Explicit operation timeout, e.g,. 5m (for 5 
#' minutes)
#' @param version (character) Explicit version number for concurrency control
#' @param version_type (character) Specific version type. One of internal 
#' or external
#' @param callopts Curl args passed on to [crul::HttpClient]
#' @param ... Further args to query DSL
#' @references
#' <https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-delete.html>
#' @examples \dontrun{
#' (x <- connect())
#' x$ping()
#' 
#' if (!index_exists(x, "plos")) {
#'  plosdat <- system.file("examples", "plos_data.json",
#'     package = "elastic")
#'  plosdat <- type_remover(plosdat)
#'  docs_bulk(x, plosdat)
#' }
#'
#' # delete a document
#' if (!docs_get(x, index='plos', id=36, exists=TRUE)) {
#'   docs_create(x, index='plos', id=36, 
#'     body = list(id="12345", title="New title")
#'   )
#' }
#' docs_get(x, index='plos', id=36)
#' docs_delete(x, index='plos', id=36)
#' # docs_get(x, index='plos', id=36) # and the document is gone
#' }

docs_delete <- function(conn, index, id, type = NULL, refresh=NULL,
  routing=NULL, timeout=NULL, version=NULL, version_type=NULL,
  callopts=list(), ...) {
  
  is_conn(conn)
  url <- conn$make_url()
  type <- if (!is.null(type)) esc(type) else "_doc"
  url <- sprintf("%s/%s/%s/%s", url, esc(index), type, esc(id))
  args <- ec(list(refresh=refresh, routing=routing, timeout=timeout,
                  version=version, version_type=version_type, ...))
  if (length(args) == 0) args <- NULL
  cli <- conn$make_conn(url, list(), callopts)
  res <- cli$delete(query = args)
  geterror(conn, res)
  jsonlite::fromJSON(res$parse("UTF-8"), FALSE)
}
