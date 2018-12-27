#' Get documents
#'
#' @export
#' @param conn an Elasticsearch connection object, see [connect()]
#' @param index (character) The name of the index. Required
#' @param type (character) The type of the document. Required
#' @param id (numeric/character) The document ID. Can be numeric or character. 
#' Required
#' @param source (logical) If `TRUE`, return source.
#' @param fields Fields to return from the response object.
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
#' docs_get(x, index='shakespeare', type='line', id=10)
#' docs_get(x, index='shakespeare', type='line', id=12)
#' docs_get(x, index='shakespeare', type='line', id=12, source=TRUE)
#'
#' # Get certain fields
#' if (gsub("\\.", "", x$ping()$version$number) < 500) {
#'   ### ES < v5
#'   docs_get(x, index='shakespeare', type='line', id=10, fields='play_name')
#'   docs_get(x, index='shakespeare', type='line', id=10, 
#'     fields=c('play_name','speaker'))
#' } else {
#'   ### ES > v5
#'   docs_get(x, index='shakespeare', type='line', id=10, source='play_name')
#'   docs_get(x, index='shakespeare', type='line', id=10, 
#'     source=c('play_name','speaker'))
#' }
#'
#' # Just test for existence of the document
#' docs_get(x, index='plos', type='article', id=1, exists=TRUE)
#' docs_get(x, index='plos', type='article', id=123456, exists=TRUE)
#' }

docs_get <- function(conn, index, type, id, source=NULL, fields=NULL, exists=FALSE,
  raw=FALSE, callopts=list(), verbose=TRUE, ...) {
  
  is_conn(conn)
  url <- conn$make_url()
  # fields parameter changed to stored_fields in Elasticsearch v5.0
  field_name <- if (conn$es_ver() >= 500) "stored_fields" else "fields"
  args <- ec(stats::setNames(list(cl(fields)), field_name), ...)
  if (inherits(source, "logical")) source <- tolower(source)
  args <- c(args, `_source` = cl(source))
  if (length(args) == 0) args <- NULL

  url <- sprintf("%s/%s/%s/%s", url, esc(index), esc(type), esc(id))

  cli <- conn$make_conn(url, list(), callopts)
  if (exists) {
    out <- cli$head(query = args)
    if (out$status_code == 200) TRUE else FALSE
  } else {
    out <- cli$get(query = args)
    geterror(out)
    if (verbose) message(URLdecode(out$url))
    if (raw) {
      cont_utf8(out)
    } else {
      jsonlite::fromJSON(out$parse("UTF-8"), FALSE)
    }
  }
}
