#' Get counts of the number of records per index.
#'
#' @export
#' @param index Index, defaults to all indices
#' @param type Document type
#' @param callopts Curl args passed on to httr::GET.
#' @param verbose If TRUE (default) the url call used printed to console.
#' @param ... Further args passed on to elastic search HTTP API as parameters.
#' @details See docs for the count API here
#' \url{https://www.elastic.co/guide/en/elasticsearch/reference/current/search-count.html}
#' 
#' You can also get a count of documents using \code{\link{Search}} or 
#' \code{\link{Search_uri}} and setting \code{size = 0}
#' @examples \dontrun{
#' count()
#' count(index='plos')
#' count(index='plos', type='article')
#' count(index='shakespeare')
#' count(index=c('plos','shakespeare'), q="a*")
#' count(index=c('plos','shakespeare'), q="z*")
#'
#' # Curl options
#' library("httr")
#' count(callopts=verbose())
#' }

count <- function(index=NULL, type=NULL, callopts=list(), verbose=TRUE, ...){
  checkconn()
  out <- es_GET(path = '_count', cl(index), type, NULL, NULL, NULL, FALSE, callopts, ...)
  jsonlite::fromJSON(out, FALSE)$count
}
