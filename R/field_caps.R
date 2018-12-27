#' Field capabilities
#' 
#' The field capabilities API allows to retrieve the capabilities of fields 
#' among multiple indices.
#'
#' @export
#' @param conn an Elasticsearch connection object, see [Elasticsearch]
#' @param fields A list of fields to compute stats for. optional
#' @param index Index name, one or more
#' @param body Query, either a list or json
#' @param raw (logical) Get raw JSON back or not
#' @param asdf (logical) If `TRUE`, use [jsonlite::fromJSON()] 
#' to parse JSON directly to a data.frame if possible. If `FALSE`
#' (default), list output is given.
#' @param ... Curl args passed on to [crul::HttpClient]
#' 
#' @references 
#' <https://www.elastic.co/guide/en/elasticsearch/reference/current/search-field-caps.html>
#' 
#' @seealso [field_stats()]
#' @examples \dontrun{
#' x <- connect()
#' 
#' field_caps(x, body = '{ "fields": ["speaker"] }', index = "shakespeare")
#' }
field_caps <- function(conn, fields = NULL, index = NULL, body = list(), 
                        raw = FALSE, asdf = FALSE, ...) {
  
  is_conn(conn)
  conn$stop_es_version(540, "field_caps")
  if (conn$es_ver() >= 500) {
    if (!is.null(fields)) {
      stop('"fields" parameter is deprecated in ES >= v5. Use `body` param', 
           call. = FALSE)
    }
  }
  
  if (!is.null(fields)) fields <- paste(fields, collapse = ",")
  search_POST(conn, "_field_caps", cl(esc(index)), 
    args = ec(list(fields = fields)), body = body, raw = raw, 
    asdf = asdf, stream_opts = list(), ...)
}
