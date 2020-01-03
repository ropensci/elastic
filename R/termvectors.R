#' Termvectors
#'
#' @export
#' @param conn an Elasticsearch connection object, see [connect()]
#' @param index (character) The index in which the document resides.
#' @param type (character) The type of the document. optional
#' @param id (character) The id of the document, when not specified a doc
#' param should be supplied.
#' @param body (character) Define parameters and or supply a document to get
#' termvectors for
#' @param field_statistics (character) Specifies if document count, sum
#' of document frequencies and sum of total term frequencies should be
#' returned. Default: `TRUE`
#' @param fields (character) A comma-separated list of fields to return.
#' @param offsets (character) Specifies if term offsets should be returned.
#' Default: `TRUE`
#' @param parent (character) Parent id of documents.
#' @param payloads (character) Specifies if term payloads should be returned.
#' Default: `TRUE`
#' @param positions (character) Specifies if term positions should be returned.
#' Default: `TRUE`
#' @param preference (character) Specify the node or shard the operation
#' should be performed on (Default: `random`).
#' @param realtime (character) Specifies if request is real-time as opposed to
#' near-real-time (Default: `TRUE`).
#' @param routing (character) Specific routing value.
#' @param term_statistics (character) Specifies if total term frequency and
#' document frequency should be returned. Default: `FALSE`
#' @param version (character) Explicit version number for concurrency control
#' @param version_type (character) Specific version type, valid choices are:
#' 'internal', 'external', 'external_gte', 'force'
#' @param pretty (logical) pretty print. Default: `TRUE`
#' @param ... Curl args passed on to [crul::verb-POST]
#'
#' @references
#' <http://www.elastic.co/guide/en/elasticsearch/reference/current/docs-termvectors.html>
#'
#' @details Returns information and statistics on terms in the fields of a
#' particular document. The document could be stored in the index or
#' artificially provided by the user (Added in 1.4). Note that for
#' documents stored in the index, this is a near realtime API as the term
#' vectors are not available until the next refresh.
#' 
#' @seealso [mtermvectors()]
#'
#' @examples \dontrun{
#' x <- connect()
#' 
#' if (!index_exists(x, 'plos')) {
#'   plosdat <- system.file("examples", "plos_data_notypes.json",
#'     package = "elastic")
#'   invisible(docs_bulk(x, plosdat))
#' }
#' if (!index_exists(x, 'omdb')) {
#'   omdb <- system.file("examples", "omdb_notypes.json", package = "elastic")
#'   invisible(docs_bulk(x, omdb))
#' }
#'
#' body <- '{
#'   "fields" : ["title"],
#'   "offsets" : true,
#'   "positions" : true,
#'   "term_statistics" : true,
#'   "field_statistics" : true
#' }'
#' termvectors(x, 'plos', id = 29, body = body)
#'
#' body <- '{
#'   "fields" : ["Plot"],
#'   "offsets" : true,
#'   "positions" : true,
#'   "term_statistics" : true,
#'   "field_statistics" : true
#' }'
#' termvectors(x, 'omdb', id = Search(x, "omdb", size=1)$hits$hits[[1]]$`_id`,
#' body = body)
#' }
termvectors <- function(conn, index, type = NULL, id = NULL, body = list(),
  pretty = TRUE, field_statistics = TRUE, fields = NULL, offsets = TRUE,
  parent = NULL, payloads = TRUE, positions = TRUE, realtime = TRUE,
  preference = 'random', routing = NULL, term_statistics = FALSE,
  version = NULL, version_type = NULL, ...) {

  is_conn(conn)
  args <- ec(list(pretty = as_log(pretty), realtime = as_log(realtime), 
                  preference = preference, routing = routing, 
                  version = version, version_type = version_type))
  if (length(body) == 0) {
    body <- ec(list(fields = fields, field_statistics = field_statistics,
                    offsets = offsets, parent = parent, payloads = payloads,
                    positions = positions, term_statistics = term_statistics))
  }
  tv_POST(conn,
    if (conn$es_ver() > 200) "_termvectors" else "_termvector",
    index, type, id, args, body, ...
  )
}

# helpers ------------------------
tv_POST <- function(conn, path, index, type, id, args, body, ...) {
  url <- construct_url(conn$make_url(), path, index, type, id)
  cli <- conn$make_conn(url, json_type(), ...)
  tt <- cli$post(query = args, body = body, encode = "json")
  geterror(conn, tt)
  if (conn$warn) catch_warnings(tt)
  jsonlite::fromJSON(tt$parse("UTF-8"), FALSE)
}
