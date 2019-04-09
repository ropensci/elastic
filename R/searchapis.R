#' Overview of search functions
#'
#' @name searchapis
#' @details
#' Elasticsearch search APIs include the following functions:
#' 
#' - [Search()] - Search using the Query DSL via the body of the request.
#' - [Search_uri()] - Search using the URI search API only. This may be
#'  needed for servers that block POST requests for security, or maybe you don't need
#'  complicated requests, in which case URI only requests are suffice.
#' - [msearch()] - Multi Search - execute several search requests defined
#'  in a file passed to `msearch`
#' - [search_shards()] - Search shards.
#' - [count()] - Get counts for various searches.
#' - [explain()] - Computes a score explanation for a query and a specific
#'  document. This can give useful feedback whether a document matches or didn't match
#'  a specific query.
#' - [validate()] - Validate a search
#' - [field_stats()] - Search field statistics
#' - [percolate()] - Store queries into an index then, via the percolate API, 
#'  define documents to retrieve these queries.
#'
#' More will be added soon.
#' 
#' @references
#' <https://www.elastic.co/guide/en/elasticsearch/reference/current/search.html>
NULL
