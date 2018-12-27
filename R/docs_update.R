#' Update a document
#'
#' @export
#' @param conn an Elasticsearch connection object, see [connect()]
#' @param index (character) The name of the index. Required
#' @param type (character) The type of the document. Required
#' @param id (numeric/character) The document ID. Can be numeric or character. 
#' Required
#' @param body The document, either a list or json
#' @param version (character) Explicit version number for concurrency control
#' @param version_type (character) Specific version type. One of internal, 
#' external, external_gte, or force
#' @param fields A comma-separated list of fields to return in the response
#' @param parent ID of the parent document. Is is only used for routing and
#' when for the upsert request
#' @param refresh Refresh the index after performing the operation. See
#' <http://bit.ly/2ezW9Zr> for details
#' @param retry_on_conflict Specify how many times should the operation be
#' retried when a conflict occurs (default: 0)
#' @param routing (character) Specific routing value
#' @param timeout (character) Explicit operation timeout, e.g,. 5m (for 
#' 5 minutes)
#' @param timestamp (date) Explicit timestamp for the document
#' @param ttl (aka \dQuote{time to live}) Expiration time for the document.
#' Expired documents will be expunged automatically. The expiration date that 
#' will be set for a document with a provided ttl is relative to the timestamp 
#' of the document,  meaning it can be based on the time of indexing or on 
#' any time provided. The provided ttl must be strictly positive and can be 
#' a number (in milliseconds) or any valid time value (e.g, 86400000, 1d).
#' @param wait_for_active_shards The number of shard copies required to be 
#' active before proceeding with the update operation. 
#' See <http://bit.ly/2fbqkZ1> for details.
#' @param source Allows to control if and how the updated source should be 
#' returned in the response. By default the updated source is not returned. 
#' See <http://bit.ly/2efmYiE> filtering for details
#' @param detect_noop (logical) Specifying `TRUE` will cause Elasticsearch 
#' to check if there are changes and, if there aren't, turn the update request
#' into a noop.
#' @param callopts Curl options passed on to [crul::HttpClient]
#' @param ... Further args to query DSL
#' @references <http://bit.ly/2eVYqLz>
#' @examples \dontrun{
#' (x <- connect())
#' if (!index_exists(x, 'plos')) {
#'   plosdat <- system.file("examples", "plos_data.json", package = "elastic")
#'   invisible(docs_bulk(x, plosdat))
#' }
#' 
#' docs_create(x, index='plos', type='article', id=1002, 
#'   body=list(id="12345", title="New title"))
#' # and the document is there now
#' docs_get(x, index='plos', type='article', id=1002) 
#' # update the document
#' docs_update(x, index='plos', type='article', id=1002, 
#'   body = list(doc = list(title = "Even newer title again")))
#' # get it again, notice changes
#' docs_get(x, index='plos', type='article', id=1002) 
#' 
#' if (!index_exists(x, 'stuffthings')) {
#'   index_create(x, "stuffthings")
#' }
#' docs_create(x, index='stuffthings', type='thing', id=1, 
#'   body=list(name = "foo", what = "bar"))
#' docs_update(x, index='stuffthings', type='thing', id=1, 
#'   body = list(doc = list(name = "hello", what = "bar")), 
#'   source = 'name')
#' }

docs_update <- function(conn, index, type, id, body, fields=NULL, source=NULL, 
  version=NULL, version_type=NULL, routing=NULL, parent=NULL, timestamp=NULL, 
  ttl=NULL, refresh=NULL, timeout=NULL, retry_on_conflict=NULL, 
  wait_for_active_shards=NULL, detect_noop=NULL, callopts=list(), ...) {

  is_conn(conn)
  url <- conn$make_url()
  url <- sprintf("%s/%s/%s/%s/_update", url, esc(index), esc(type), esc(id))
  query <- ec(
    list(
      version=version, version_type=version_type, routing=routing,
      parent=parent, timestamp=timestamp, ttl=ttl, refresh=refresh, 
      timeout=timeout, fields=fields, `_source`=cl(source), 
      retry_on_conflict=retry_on_conflict, 
      wait_for_active_shards=wait_for_active_shards, ...
    )
  )
  if (length(query) == 0) query <- NULL
  if (!is.null(detect_noop)) {
    if (is.logical(detect_noop)) body$detect_noop <- detect_noop
  }
  update_POST(conn, url, query, body, callopts)
}

update_POST <- function(conn, url, query=NULL, body=NULL, callopts) {
  cli <- conn$make_conn(url, json_type(), callopts)
  tt <- cli$post(query = query, body = body, encode = "json")
  geterror(tt)
  jsonlite::fromJSON(tt$parse("UTF-8"), FALSE)
}

# other params to consider -----------
# @param consistency Explicit write consistency setting for the operation,
# valid choices are: 'one', 'quorum', 'all'
# @param script The URL-encoded script definition (instead of using request
# body)
# @param script_id The id of a stored script
# @param scripted_upsert True if the script referenced in script or
# script_id should be called to perform inserts - defaults to false
# @param lang The script language (default: groovy)
