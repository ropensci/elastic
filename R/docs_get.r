#' Get documents
#'
#' @export
#' @param conn an Elasticsearch connection object, see [connect()]
#' @param index (character) The name of the index. Required
#' @param id (numeric/character) The document ID. Can be numeric or character. 
#' Required
#' @param type (character) The type of the document. optional
#' @param source (logical) If `TRUE` (default), return source. note that 
#' it is actually set to `NULL` in the function definition, but within 
#' Elasticsearch, it returns the source by default. alternatively, 
#' you can pass a vector of field names to return.
#' @param fields Fields to return from the response object.
#' @param source_includes,source_excludes (character) fields to include in the
#' returned document, or to exclude. a character vector
#' @param exists (logical) Only return a logical as to whether the document 
#' exists or not.
#' @param raw If `TRUE` (default), data is parsed to list. If `FALSE`, then raw 
#' JSON.
#' @param callopts Curl args passed on to [crul::HttpClient]
#' @param verbose If TRUE (default) the url call used printed to console.
#' @param ... Further args passed on to elastic search HTTP API as parameters.
#'
#' @references
#' <https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-get.html>
#'
#' @examples \dontrun{
#' (x <- connect())
#' 
#' if (!index_exists(x, "shakespeare")) {
#'   shakespeare <- system.file("examples", "shakespeare_data_.json",
#'     package = "elastic")
#'   shakespeare <- type_remover(shakespeare)
#'   invisible(docs_bulk(x, shakespeare))
#' }
#' 
#' docs_get(x, index='shakespeare', id=10)
#' docs_get(x, index='shakespeare', id=12)
#' docs_get(x, index='shakespeare', id=12, source=TRUE)
#'
#' # Get certain fields
#' if (gsub("\\.", "", x$ping()$version$number) < 500) {
#'   ### ES < v5
#'   docs_get(x, index='shakespeare', id=10, fields='play_name')
#'   docs_get(x, index='shakespeare', id=10, fields=c('play_name','speaker'))
#' } else {
#'   ### ES > v5
#'   docs_get(x, index='shakespeare', id=10, source='play_name')
#'   docs_get(x, index='shakespeare', id=10, source=c('play_name','speaker'))
#' }
#'
#' # Just test for existence of the document
#' docs_get(x, index='plos', id=1, exists=TRUE)
#' docs_get(x, index='plos', id=123456, exists=TRUE)
#' 
#' # source includes / excludes
#' docs_get(x, index='shakespeare', id=10, source_includes = "play_name")
#' docs_get(x, index='shakespeare', id=10, source_excludes = "play_name")
#' }

docs_get <- function(conn, index, id, type = NULL, source = NULL,
  fields = NULL, source_includes = NULL, source_excludes = NULL, exists=FALSE,
  raw=FALSE, callopts=list(), verbose=TRUE, ...) {
  
  is_conn(conn)
  url <- conn$make_url()
  # fields parameter changed to stored_fields in Elasticsearch v5.0
  field_name <- if (conn$es_ver() >= 500) "stored_fields" else "fields"
  args <- ec(stats::setNames(list(cl(fields)), field_name), ...)
  if (inherits(source, "logical")) source <- tolower(source)
  args <- c(args, `_source` = cl(source))
  if (!is.null(source_includes)) {
    assert(source_includes, "character")
    args$`_source_includes` <- cl(source_includes)
  }
  if (!is.null(source_excludes)) {
    assert(source_excludes, "character")
    args$`_source_excludes` <- cl(source_excludes)
  }
  if (length(args) == 0) args <- NULL

  type <- if (!is.null(type)) esc(type) else "_doc"
  url <- sprintf("%s/%s/%s/%s", url, esc(index), type, esc(id))

  cli <- conn$make_conn(url, list(), callopts)
  if (exists) {
    out <- cli$head(query = args)
    if (conn$warn) catch_warnings(out)
    if (out$status_code == 200) TRUE else FALSE
  } else {
    out <- cli$get(query = args)
    if (conn$warn) catch_warnings(out)
    geterror(conn, out)
    if (verbose) message(URLdecode(out$url))
    if (raw) {
      out$parse("UTF-8")
    } else {
      jsonlite::fromJSON(out$parse("UTF-8"), FALSE)
    }
  }
}
