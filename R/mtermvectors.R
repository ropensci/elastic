#' Multi Termvectors
#'
#' @export
#' @param conn an Elasticsearch connection object, see [connect()]
#' @param index (character) The index in which the document resides.
#' @param type (character) The type of the document.
#' @param ids (character) One or more document ids
#' @param body (character) Define parameters and or supply a document to get 
#' termvectors for
#' @param field_statistics (character) Specifies if document count, sum of 
#' document frequencies and sum of total term frequencies should be returned. 
#' Default: `TRUE`
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
#' <https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-multi-termvectors.html>
#'
#' @details Multi termvectors API allows to get multiple termvectors based on an 
#' index, type and id.
#' 
#' @seealso [termvectors()]
#' 
#' @examples \dontrun{
#' x <- connect()
#' 
#' if (index_exists(x, 'omdb')) index_delete(x, "omdb")
#' omdb <- system.file("examples", "omdb_notypes.json", package = "elastic")
#' invisible(docs_bulk(x, omdb))
#' out <- Search(x, "omdb", size = 2)$hits$hits
#' ids <- vapply(out, "[[", "", "_id")
#' 
#' # no index
#' body <- '{
#'    "docs": [
#'       {
#'          "_index": "omdb",
#'          "_id": "%s",
#'          "term_statistics": true
#'       },
#'       {
#'          "_index": "omdb",
#'          "_id": "%s",
#'          "fields": [
#'             "Plot"
#'          ]
#'       }
#'    ]
#' }'
#' mtermvectors(x, body = sprintf(body, ids[1], ids[2]))
#'
#' # index given
#' body <- '{
#'    "docs": [
#'       {
#'          "_id": "%s",
#'          "fields": [
#'             "Plot"
#'          ],
#'          "term_statistics": true
#'       },
#'       {
#'          "_id": "%s",
#'          "fields": [
#'             "Title"
#'          ]
#'       }
#'    ]
#' }'
#' mtermvectors(x, 'omdb', body = sprintf(body, ids[1], ids[2]))
#' 
#' # parameters same for both documents, so can simplify
#' body <- '{
#'     "ids" : ["%s", "%s"],
#'     "parameters": {
#'         "fields": [
#'             "Plot"
#'         ],
#'         "term_statistics": true
#'     }
#' }'
#' mtermvectors(x, 'omdb', body = sprintf(body, ids[1], ids[2]))
#' 
#' # you can give user provided documents via the 'docs' parameter
#' ## though you have to give index and type that exist in your Elasticsearch 
#' ## instance
#' body <- '{
#'    "docs": [
#'       {
#'          "_index": "omdb",
#'          "doc" : {
#'             "Director" : "John Doe",
#'             "Plot" : "twitter test test test"
#'          }
#'       },
#'       {
#'          "_index": "omdb",
#'          "doc" : {
#'            "Director" : "Jane Doe",
#'            "Plot" : "Another twitter test ..."
#'          }
#'       }
#'    ]
#' }'
#' mtermvectors(x, body = body)
#' }
mtermvectors <- function(conn,
  index = NULL, type = NULL, ids = NULL, body = list(), pretty = TRUE,
  field_statistics = TRUE, fields = NULL, offsets = TRUE, parent = NULL,
  payloads = TRUE, positions = TRUE, preference = 'random', realtime = TRUE,
  routing = NULL, term_statistics = FALSE, version = NULL, version_type = NULL, 
  ...) {
  
  is_conn(conn)
  args <- ec(list(pretty = as_log(pretty), realtime = as_log(realtime), 
                  preference = preference, routing = routing, version = version, 
                  version_type = version_type))
  if (length(body) == 0) {
    body <- ec(list(fields = fields, field_statistics = field_statistics,
                    offsets = offsets, parent = parent, payloads = payloads,
                    positions = as_log(positions), 
                    term_statistics = as_log(term_statistics), ids = ids))
  }
  tv_POST(conn, "_mtermvectors", index, type, id = NULL, args, body, ...)
}
