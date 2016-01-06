#' Search functions.
#'
#' @name searchapis
#' @details
#' Elasticsearch search APIs include the following functions:
#' \itemize{
#'  \item \code{\link{Search}} - Search using the Query DSL via the body of the request.
#'  \item \code{\link{Search_uri}} - Search using the URI search API only. This may be
#'  needed for servers that block POST requests for security, or maybe you don't need
#'  complicated requests, in which case URI only requests are suffice.
#'  \item \code{\link{msearch}} - Multi Search - execute several search requests defined
#'  in a file passed to \code{msearch}
#'  \item \code{\link{search_shards}} - Search shards.
#'  \item \code{\link{count}} - Get counts for various searches.
#'  \item \code{\link{explain}} - Computes a score explanation for a query and a specific
#'  document. This can give useful feedback whether a document matches or didn't match
#'  a specific query.
#'  \item \code{\link{validate}} - Validate a search
#'  \item \code{\link{field_stats}} - Search field statistics
#'  \item \code{\link{percolate}} - Store queries into an index then, via the percolate API, 
#'  define documents to retrieve these queries.
#' }
#'
#' More will be added soon.
#' @references
#' \url{https://www.elastic.co/guide/en/elasticsearch/reference/current/search.html}
NULL
