#' Field capabilities
#' 
#' The field capabilities API allows to retrieve the capabilities of fields
#' among multiple indices.
#'
#' @export
#' @param conn an Elasticsearch connection object, see [connect()]
#' @param fields A list of fields to compute stats for. required
#' @param index Index name, one or more
#' @param ... Curl args passed on to [crul::verb-GET]
#' 
#' @references 
#' <https://www.elastic.co/guide/en/elasticsearch/reference/current/search-field-caps.html>
#' 
#' @seealso [field_stats()]
#' @examples \dontrun{
#' x <- connect()
#' x$ping()
#' 
#' if (x$es_ver() >= 540) {
#'   field_caps(x, fields = "speaker", index = "shakespeare")
#' }
#' 
#' }
field_caps <- function(conn, fields, index = NULL, ...) {
  is_conn(conn)
  conn$stop_es_version(540, "field_caps")
  fields <- paste(fields, collapse = ",")
  tt <- es_GET(conn, "_field_caps", index = index, 
    fields = fields, callopts = list(...))
  jsonlite::fromJSON(tt)
}
