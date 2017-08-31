#' Termvectors
#'
#' @export
#' @param index (character) The index in which the document resides.
#' @param type (character) The type of the document.
#' @param id (character) The id of the document, when not specified a doc
#' param should be supplied.
#' @param body (character) Define parameters and or supply a document to get
#' termvectors for
#' @param field_statistics (character) Specifies if document count, sum
#' of document frequencies and sum of total term frequencies should be
#' returned. Default: \code{TRUE}
#' @param fields (character) A comma-separated list of fields to return.
#' @param offsets (character) Specifies if term offsets should be returned.
#' Default: \code{TRUE}
#' @param parent (character) Parent id of documents.
#' @param payloads (character) Specifies if term payloads should be returned.
#' Default: \code{TRUE}
#' @param positions (character) Specifies if term positions should be returned.
#' Default: \code{TRUE}
#' @param preference (character) Specify the node or shard the operation
#' should be performed on (Default: \code{random}).
#' @param realtime (character) Specifies if request is real-time as opposed to
#' near-real-time (Default: \code{TRUE}).
#' @param routing (character) Specific routing value.
#' @param term_statistics (character) Specifies if total term frequency and
#' document frequency should be returned. Default: \code{FALSE}
#' @param version (character) Explicit version number for concurrency control
#' @param version_type (character) Specific version type, valid choices are:
#' 'internal', 'external', 'external_gte', 'force'
#' @param pretty (logical) pretty print. Default: \code{TRUE}
#' @param ... Curl args passed on to \code{\link[httr]{POST}}
#'
#' @references
#' \url{http://www.elastic.co/guide/en/elasticsearch/reference/current/docs-termvectors.html}
#'
#' @details Returns information and statistics on terms in the fields of a
#' particular document. The document could be stored in the index or
#' artificially provided by the user (Added in 1.4). Note that for
#' documents stored in the index, this is a near realtime API as the term
#' vectors are not available until the next refresh.
#'
#' @examples \dontrun{
#' connect()
#' if (!index_exists('plos')) {
#'   plosdat <- system.file("examples", "plos_data.json", package = "elastic")
#'   invisible(docs_bulk(plosdat))
#' }
#' if (!index_exists('omdb')) {
#'   omdb <- system.file("examples", "omdb.json", package = "elastic")
#'   invisible(docs_bulk(omdb))
#' }
#'
#' body <- '{
#'   "fields" : ["title"],
#'   "offsets" : true,
#'   "positions" : true,
#'   "term_statistics" : true,
#'   "field_statistics" : true
#' }'
#' termvectors('plos', 'article', 29, body = body)
#'
#' body <- '{
#'   "fields" : ["Plot"],
#'   "offsets" : true,
#'   "positions" : true,
#'   "term_statistics" : true,
#'   "field_statistics" : true
#' }'
#' termvectors('omdb', 'omdb', 'AVXdx8Eqg_0Z_tpMDyP_', body = body)
#' }
termvectors <- function(index, type, id = NULL, body = list(), pretty = TRUE,
  field_statistics = TRUE, fields = NULL, offsets = TRUE, parent = NULL,
  payloads = TRUE, positions = TRUE, realtime = TRUE, preference = 'random',
  routing = NULL, term_statistics = FALSE, version = NULL,
  version_type = NULL, ...) {

  args <- ec(list(pretty = as_log(pretty), realtime = as_log(realtime), 
                  preference = preference, routing = routing, 
                  version = version, version_type = version_type))
  if (length(body) == 0) {
    body <- ec(list(fields = fields, field_statistics = field_statistics,
                    offsets = offsets, parent = parent, payloads = payloads,
                    positions = positions, term_statistics = term_statistics))
  }
  tv_POST(
    if (es_ver() > 200) "_termvectors" else "_termvector",
    index, type, id, args, body, ...
  )
}

# helpers ------------------------
tv_POST <- function(path, index, type, id, args, body, ...) {
  url <- make_url(es_get_auth())
  url <- construct_url(url, path, index, type, id)
  tt <- httr::POST(url, query = args, body = body,
                   encode = "json", make_up(), content_type_json(), 
                   es_env$headers, ...)
  geterror(tt)
  jsonlite::fromJSON(cont_utf8(tt), FALSE)
}
