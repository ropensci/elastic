#' Get documents via the get API.
#'
#' @export
#' @param index Index. Required.
#' @param type Document type. Required.
#' @param id Document id. Required.
#' @param source (logical) If \code{TRUE}, return source.
#' @param fields Fields to return from the response object.
#' @param exists (logical) Only return a logical as to whether the document exists or not.
#' @param raw If TRUE (default), data is parsed to list. If FALSE, then raw JSON.
#' @param callopts Curl args passed on to httr::POST.
#' @param verbose If TRUE (default) the url call used printed to console.
#' @param ... Further args passed on to elastic search HTTP API as parameters.
#' 
#' @references
#' \url{https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-get.html}
#' 
#' @examples \dontrun{
#' docs_get(index='shakespeare', type='line', id=10)
#' docs_get(index='shakespeare', type='line', id=3)
#' docs_get(index='shakespeare', type='line', id=3, source=TRUE)
#'
#' # Get certain fields
#' docs_get(index='shakespeare', type='line', id=10, fields='play_name')
#' docs_get(index='shakespeare', type='line', id=10, fields=c('play_name','speaker'))
#'
#' # Just test for existence of the document
#' docs_get(index='plos', type='article', id=1, exists=TRUE)
#' docs_get(index='plos', type='article', id=123456, exists=TRUE)
#' }

docs_get <- function(index, type, id, source=FALSE, fields=NULL, exists=FALSE, 
  raw=FALSE, callopts=list(), verbose=TRUE, ...) {
  
  checkconn()
  url <- make_url(es_get_auth())
  if (!is.null(fields)) fields <- paste(fields, collapse = ",")

  args <- ec(list(fields = cl(fields), ...))
  if (length(args) == 0) args <- NULL
  
  url <- sprintf("%s/%s/%s/%s", url, esc(index), esc(type), id)
  if (source) url <- paste(url, '_source', sep = "/")

  if (exists) {
    out <- HEAD(url, query = args, mc(make_up(), callopts))
    if (out$status_code == 200) TRUE else FALSE
  } else {
    out <- GET(url, query = args, mc(make_up(), callopts))
    if (out$status_code > 202) stop(out$status_code, " - document not found", call. = FALSE)
    if (verbose) message(URLdecode(out$url))
    if (raw) { 
      content(out, as = "text") 
    } else { 
      jsonlite::fromJSON(content(out, as = "text"), FALSE) 
    }
  }
}
