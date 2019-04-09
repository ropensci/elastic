#' @section profile:
#' The Profile API provides detailed timing information about the execution of
#' individual components in a search request. See 
#' https://www.elastic.co/guide/en/elasticsearch/reference/current/search-profile.html
#' for more information
#' 
#' In a body query, you can set to \code{profile: true} to enable profiling
#' results. e.g.
#' 
#' \preformatted{
#' {
#'   "profile": true,
#'   "query" : {
#'     "match" : { "message" : "some number" }
#'   }
#' }
#' }
#' 
