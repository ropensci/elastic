#' Create a document
#'
#' @export
#' @param conn an Elasticsearch connection object, see [connect()]
#' @param index (character) The name of the index. Required
#' @param id (numeric/character) The document ID. Can be numeric or character.
#' Optional. if not provided, Elasticsearch creates the ID for you as a UUID.
#' @param body The document
#' @param type (character) The type of the document. optional
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
#' @param callopts Curl options passed on to [crul::HttpClient]
#' @param ... Further args to query DSL
#' @references
#' <https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-index_.html>
#' @examples \dontrun{
#' (x <- connect())
#'
#' if (!index_exists(x, 'plos')) {
#'   plosdat <- system.file("examples", "plos_data.json",
#'     package = "elastic")
#'   plosdat <- type_remover(plosdat)
#'   invisible(docs_bulk(x, plosdat))
#' }
#'
#' # give a document id
#' z <- docs_create(x, index = 'plos', id = 1002,
#'   body = list(id = "12345", title = "New title"))
#' z
#' # and the document is there now
#' docs_get(x, index = 'plos', id = 1002)
#'
#' # let Elasticsearch create the document id for you
#' z <- docs_create(x, index='plos', body=list(id="6789", title="Some title"))
#' z
#' # and the document is there now
#' docs_get(x, index='plos', id=z$`_id`)
#' }

docs_create <- function(conn, index, body, type = NULL, id = NULL,
  version=NULL, version_type=NULL, op_type=NULL, routing=NULL,
  parent=NULL, timestamp=NULL, ttl=NULL, refresh=NULL, timeout=NULL,
  callopts=list(), ...) {

  is_conn(conn)
  url <- conn$make_url()
  if (conn$es_ver() < 600 && is.null(type)) {
    stop("'type' is required for ES <= v6", call.=FALSE)
  }
  type <- if (!is.null(type)) esc(type) else "_doc"
  if (is.null(id)) {
    method <- 'POST'
    url <- file.path(url, esc(index), type)
  } else {
    method <- 'PUT'
    url <- file.path(url, esc(index), type, esc(id))
  }
  query <- ec(list(version=version, version_type=version_type, op_type=op_type,
    routing=routing, parent=parent, timestamp=timestamp,
    ttl=ttl, refresh=refresh, timeout=timeout, ...))
  if (length(query) == 0) query <- NULL
  create_docs(conn, method, url, query, body, callopts)
}

create_docs <- function(conn, method, url, query=NULL, body=NULL, callopts) {
  cli <- conn$make_conn(url, json_type(), callopts)
  tt <- cli$verb(method, query = query, body = body, encode = "json")
  geterror(conn, tt)
  jsonlite::fromJSON(tt$parse("UTF-8"), FALSE)
}
