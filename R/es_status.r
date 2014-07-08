#' Get a list of your indices, just the names.
#'
#' See \code{es_status} for more details on indices.
#' 
#' @export
#'
#' @examples \dontrun{
#' es_status()
#' }

es_status <- function(callopts=list(), raw=FALSE, verbose=TRUE, ...)
{
  es_GET('_status', NULL, NULL, NULL, NULL, 'elastic_status', raw, callopts, ...)
}
