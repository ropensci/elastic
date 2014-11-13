#' Search functions.
#' 
#' @name searchapis
#' @details  
#' Elasticsearch search APIs include the following functions:
#' \itemize{
#'  \item \code{\link{es_search}} - Search using the URI search API
#'  \item \code{\link{search_body}} - Pass in search specification in request body
#'  \item \code{\link{search_shards}} - Search shards
#'  \item \code{\link{mlt}} - More like this queries
#'  \item \code{\link{count}} - Get counts for various searches
#'  \item \code{\link{explain}} - Computes a score explanation for a query and a specific 
#'  document. This can give useful feedback whether a document matches or didn’t match 
#'  a specific query.
#' }
#' 
#' More will be added soon.
#' @references 
#' \url{http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search.html}
NULL
