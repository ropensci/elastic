#' Multi Termvectors
#'
#' @export
#' @param index (character) The index in which the document resides.
#' @param type (character) The type of the document.
#' @param ids (character) One or more document ids
#' @param body (character) Define parameters and or supply a document to get 
#' termvectors for
#' @param field_statistics (character) Specifies if document count, sum of 
#' document frequencies and sum of total term frequencies should be returned. 
#' Default: \code{TRUE}
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
#' \url{https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-multi-termvectors.html}
#'
#' @details Multi termvectors API allows to get multiple termvectors based on an 
#' index, type and id.
#' 
#' @examples \dontrun{
#' connect()
#' if (!index_exists('omdb')) {
#'   omdb <- system.file("examples", "omdb.json", package = "elastic")
#'   docs_bulk(omdb)
#' }
#' 
#' # no index or type given
#' body <- '{
#'    "docs": [
#'       {
#'          "_index": "omdb",
#'          "_type": "omdb",
#'          "_id": "AVXdx8Eqg_0Z_tpMDyP_",
#'          "term_statistics": true
#'       },
#'       {
#'          "_index": "omdb",
#'          "_type": "omdb",
#'          "_id": "AVXdx8Eqg_0Z_tpMDyQ1",
#'          "fields": [
#'             "Plot"
#'          ]
#'       }
#'    ]
#' }'
#' mtermvectors(body = body)
#'
#' # index given, but not type
#' body <- '{
#'    "docs": [
#'       {
#'          "_type": "omdb",
#'          "_id": "AVXdx8Eqg_0Z_tpMDyP_",
#'          "fields": [
#'             "Plot"
#'          ],
#'          "term_statistics": true
#'       },
#'       {
#'          "_type": "omdb",
#'          "_id": "AVXdx8Eqg_0Z_tpMDyQ1",
#'          "fields": [
#'             "Title"
#'          ]
#'       }
#'    ]
#' }'
#' mtermvectors('omdb', body = body)
#' 
#' # index and type given
#' body <- '{
#'    "docs": [
#'       {
#'          "_id": "AVXdx8Eqg_0Z_tpMDyP_",
#'          "fields": [
#'             "Plot"
#'          ],
#'          "term_statistics": true
#'       },
#'       {
#'          "_id": "AVXdx8Eqg_0Z_tpMDyQ1"
#'       }
#'    ]
#' }'
#' mtermvectors('omdb', 'omdb', body = body)
#' 
#' # index and type given, parameters same, so can simplify
#' body <- '{
#'     "ids" : ["AVXdx8Eqg_0Z_tpMDyP_", "AVXdx8Eqg_0Z_tpMDyQ1"],
#'     "parameters": {
#'         "fields": [
#'             "Plot"
#'         ],
#'         "term_statistics": true
#'     }
#' }'
#' mtermvectors('omdb', 'omdb', body = body)
#' 
#' # you can give user provided documents via the 'docs' parameter
#' ## though you have to give index and type that exist in your Elasticsearch 
#' ## instance
#' body <- '{
#'    "docs": [
#'       {
#'          "_index": "omdb",
#'          "_type": "omdb",
#'          "doc" : {
#'             "Director" : "John Doe",
#'             "Plot" : "twitter test test test"
#'          }
#'       },
#'       {
#'          "_index": "omdb",
#'          "_type": "omdb",
#'          "doc" : {
#'            "Director" : "Jane Doe",
#'            "Plot" : "Another twitter test ..."
#'          }
#'       }
#'    ]
#' }'
#' mtermvectors(body = body)
#' }
mtermvectors <- function(
  index = NULL, type = NULL, ids = NULL, body = list(), pretty = TRUE,
  field_statistics = TRUE, fields = NULL, offsets = TRUE, parent = NULL,
  payloads = TRUE, positions = TRUE, preference = 'random', realtime = TRUE,
  routing = NULL, term_statistics = FALSE, version = NULL, version_type = NULL, 
  ...) {
  
  args <- ec(list(pretty = as_log(pretty), realtime = as_log(realtime), 
                  preference = preference, routing = routing, version = version, 
                  version_type = version_type))
  if (length(body) == 0) {
    body <- ec(list(fields = fields, field_statistics = field_statistics,
                    offsets = offsets, parent = parent, payloads = payloads,
                    positions = as_log(positions), 
                    term_statistics = as_log(term_statistics), ids = ids))
  }
  tv_POST("_mtermvectors", index, type, id = NULL, args, body, ...)
}
