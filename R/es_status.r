#' Get status details for your cluster.
#' 
#' @export
#' 
#' @param callopts Curl args passed on to httr::GET.
#' @param raw If TRUE (default), data is parsed to list. If FALSE, then raw JSON.
#' @param verbose If TRUE (default) the url call used printed to console.
#' @param ... Further args passed on to elastic search HTTP API as parameters.
#'
#' @examples \dontrun{
#' es_status()
#' }

es_status <- function(callopts=list(), raw=FALSE, verbose=TRUE, ...)
{
  es_GET('_status', NULL, NULL, NULL, NULL, 'elastic_status', raw, callopts, ...)
}
