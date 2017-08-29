#' Field capabilities
#' 
#' The field capabilities API allows to retrieve the capabilities of fields 
#' among multiple indices.
#'
#' @export
#' @param fields A list of fields to compute stats for. optional
#' @param index Index name, one or more
#' @param body Query, either a list or json
#' @param raw (logical) Get raw JSON back or not
#' @param asdf (logical) If \code{TRUE}, use \code{\link[jsonlite]{fromJSON}} 
#' to parse JSON directly to a data.frame if possible. If \code{FALSE} 
#' (default), list output is given.
#' @param ... Curl args passed on to \code{\link[httr]{POST}}
#' 
#' @references \url{https://github.com/elastic/elasticsearch/blob/master/docs/reference/search/field-caps.asciidoc}
#' 
#' @seealso \code{\link{field_stats}}
#' @examples \dontrun{
#' connect()
#' 
#' if (gsub("\\.", "", ping()$version$number) >= 500) {
#'   mapping_create("shakespeare", "act", update_all_types = TRUE, body = '{
#'     "properties": {
#'       "speaker": { 
#'       "type":     "text",
#'       "fielddata": true
#'   }}}')
#'   field_caps(body = '{ "fields": ["speaker"] }', index = "shakespeare")
#' }
#' }
field_caps <- function(fields = NULL, index = NULL, body = list(), 
                        raw = FALSE, asdf = FALSE, ...) {
  
  stop_es_version(540, "field_caps")
  if (es_ver() >= 500) {
    if (!is.null(fields)) {
      stop('"fields" parameter is deprecated in ES >= v5. Use `body` param', 
           call. = FALSE)
    }
  }
  
  if (!is.null(fields)) fields <- paste(fields, collapse = ",")
  search_POST("_field_caps", cl(esc(index)), args = ec(list(fields = fields)), 
              body = body, raw = raw, asdf = asdf, stream_opts = list(), ...)
}
