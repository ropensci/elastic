#' Get documents
#'
#' @export
#' @param index (character) The name of the index. Required
#' @param type (character) The type of the document. Required
#' @param id (numeric/character) The document ID. Can be numeric or character. 
#' Required
#' @param source (logical) If \code{TRUE}, return source.
#' @param fields Fields to return from the response object.
#' @param exists (logical) Only return a logical as to whether the document 
#' exists or not.
#' @param raw If TRUE (default), data is parsed to list. If FALSE, then raw 
#' JSON.
#' @param callopts Curl args passed on to httr::POST.
#' @param verbose If TRUE (default) the url call used printed to console.
#' @param ... Further args passed on to elastic search HTTP API as parameters.
#'
#' @references
#' \url{https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-get.html}
#'
#' @examples \dontrun{
#' docs_get(index='shakespeare', type='line', id=10)
#' docs_get(index='shakespeare', type='line', id=12)
#' docs_get(index='shakespeare', type='line', id=12, source=TRUE)
#'
#' # Get certain fields
#' if (gsub("\\.", "", ping()$version$number) < 500) {
#'   ### ES < v5
#'   docs_get(index='shakespeare', type='line', id=10, fields='play_name')
#'   docs_get(index='shakespeare', type='line', id=10, 
#'     fields=c('play_name','speaker'))
#' } else {
#'   ### ES > v5
#'   docs_get(index='shakespeare', type='line', id=10, source='play_name')
#'   docs_get(index='shakespeare', type='line', id=10, 
#'     source=c('play_name','speaker'))
#' }
#'
#' # Just test for existence of the document
#' docs_get(index='plos', type='article', id=1, exists=TRUE)
#' docs_get(index='plos', type='article', id=123456, exists=TRUE)
#' }

docs_get <- function(index, type, id, source=NULL, fields=NULL, exists=FALSE,
  raw=FALSE, callopts=list(), verbose=TRUE, ...) {
  
  url <- make_url(es_get_auth())
  # fields parameter changed to stored_fields in Elasticsearch v5.0
  field_name <- if (es_ver() >= 500) "stored_fields" else "fields"
  args <- ec(stats::setNames(list(cl(fields)), field_name), ...)
  if (inherits(source, "logical")) source <- tolower(source)
  args <- c(args, `_source` = cl(source))
  if (length(args) == 0) args <- NULL

  url <- sprintf("%s/%s/%s/%s", url, esc(index), esc(type), esc(id))

  if (exists) {
    out <- HEAD(url, query = args, es_env$headers, make_up(), callopts)
    if (out$status_code == 200) TRUE else FALSE
  } else {
    out <- GET(url, query = args, es_env$headers, make_up(), callopts)
    geterror(out)
    if (verbose) message(URLdecode(out$url))
    if (raw) {
      cont_utf8(out)
    } else {
      jsonlite::fromJSON(cont_utf8(out), FALSE)
    }
  }
}
