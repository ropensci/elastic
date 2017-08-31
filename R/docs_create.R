#' Create a document
#'
#' @export
#' @param index (character) The name of the index. Required
#' @param type (character) The type of the document. Required
#' @param id (numeric/character) The document ID. Can be numeric or character. 
#' Required
#' @param body The document.
#' @param version (character) Explicit version number for concurrency control
#' @param version_type (character) Specific version type. One of internal, 
#' external, external_gte, or force
#' @param op_type (character) Operation type. One of create, or ...
#' @param routing (character) Specific routing value
#' @param parent (numeric) A parent document ID
#' @param timestamp (date) Explicit timestamp for the document
#' @param ttl (aka \dQuote{time to live}) Expiration time for the document.
#' Expired documents will be expunged automatically. The expiration date that 
#' will be set for a document with a provided ttl is relative to the timestamp 
#' of the document,  meaning it can be based on the time of indexing or on 
#' any time provided. The provided ttl must be strictly positive and can be 
#' a number (in milliseconds) or any valid time value (e.g, 86400000, 1d).
#' @param refresh (logical) Refresh the index after performing the operation
#' @param timeout (character) Explicit operation timeout, e.g,. 5m (for 
#' 5 minutes)
#' @param callopts Curl options passed on to \code{\link[httr]{PUT}}
#' @param ... Further args to query DSL
#' @references
#' \url{https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-index_.html}
#' @examples \dontrun{
#' connect()
#' if (!index_exists('plos')) {
#'   plosdat <- system.file("examples", "plos_data.json", package = "elastic")
#'   invisible(docs_bulk(plosdat))
#' }
#' 
#' docs_create(index='plos', type='article', id=1002, 
#'   body=list(id="12345", title="New title"))
#' 
#' # and the document is there now
#' docs_get(index='plos', type='article', id=1002)
#' }

docs_create <- function(index, type, id, body, version=NULL, version_type=NULL, 
  op_type=NULL, routing=NULL, parent=NULL, timestamp=NULL, ttl=NULL, 
  refresh=NULL, timeout=NULL, callopts=list(), ...) {

  url <- make_url(es_get_auth())
  url <- sprintf("%s/%s/%s/%s", url, esc(index), esc(type), esc(id))
  query <- ec(list(version=version, version_type=version_type, op_type=op_type, 
                   routing=routing, parent=parent, timestamp=timestamp, ttl=ttl,
                   refresh=refresh, timeout=timeout,
                  ...))
  if (length(query) == 0) query <- NULL
  create_PUT(url, query, body, callopts)
}

create_PUT <- function(url, query=NULL, body=NULL, callopts) {
  tt <- PUT(url, es_env$headers, content_type_json(),
            mc(make_up(), callopts), query = query, 
            body = body, encode = "json")
  geterror(tt)
  jsonlite::fromJSON(cont_utf8(tt), FALSE)
}
