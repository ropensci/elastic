#' Get a list of your indices, just the names.
#'
#' See \code{es_status} for more details on indices.
#' 
#' @export
#'
#' @param callopts Curl args passed on to httr::GET.
#' @param raw If TRUE (default), data is parsed to list. If FALSE, then raw JSON.
#' @param verbose If TRUE (default) the url call used printed to console.
#' @param ... Further args passed on to elastic search HTTP API as parameters.
#'
#' @seealso \link{es_status}
#' @examples \dontrun{
#' es_aliases()
#' es_aliases(raw=TRUE)
#' }

es_aliases <- function(callopts=list(), raw=FALSE, verbose=TRUE, ...)
{
  out <- elastic_GET('_aliases', NULL, NULL, NULL, NULL, NULL, raw, callopts, ...)
  if(raw) out else names(rjson::fromJSON(out))
}