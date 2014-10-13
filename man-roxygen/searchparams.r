#' @details There are a lot of terms you can use for Elasticsearch. See here
#' \url{http://www.elasticsearch.org/guide/reference/query-dsl/} for the documentation.
#'
#' Here is a list of the common ones:
#'
#' \itemize{
#'  \item q The query string (maps to the query_string query, see Query String Query for more 
#'  details).
#'  \item df The default field to use when no field prefix is defined within the query.
#'  \item analyzer The analyzer name to be used when analyzing the query string.
#'  \item default_operator The default operator to be used, can be AND or OR. Defaults to OR.
#'  \item explain For each hit, contain an explanation of how scoring of the hits was computed.
#'  \item _source [1.0.0.Beta1] Added in 1.0.0.Beta1.Set to false to disable retrieval of the 
#'  _source field. You can also retrieve part of the document by using _source_include & 
#'  _source_exclude (see the request body documentation for more details)
#'  \item fields The selective stored fields of the document to return for each hit, comma 
#'  delimited. Not specifying any value will cause no fields to return.
#'  \item sort Sorting to perform. Can either be in the form of fieldName, or 
#'  fieldName:asc/fieldName:desc. The fieldName can either be an actual field within the document, 
#'  or the special _score name to indicate sorting based on scores. There can be several sort 
#'  parameters (order is important).
#'  \item track_scores When sorting, set to true in order to still track scores and return them 
#'  as part of each hit.
#'  \item timeout A search timeout, bounding the search request to be executed within the 
#'  specified time value and bail with the hits accumulated up to that point when expired. 
#'  Defaults to no timeout.
#'  \item from The starting from index of the hits to return. Defaults to 0.
#'  \item size The number of hits to return. Defaults to 10.
#'  \item search_type The type of the search operation to perform. Can be dfs_query_then_fetch, 
#'  dfs_query_and_fetch, query_then_fetch, query_and_fetch, count, scan. Defaults to 
#'  query_then_fetch. See Search Type for more details on the different types of search that can 
#'  be performed.
#'  \item lowercase_expanded_terms Should terms be automatically lowercased or not. Defaults to 
#'  true.
#'  \item analyze_wildcard Should wildcard and prefix queries be analyzed or not. Defaults to 
#'  false.
#' }
