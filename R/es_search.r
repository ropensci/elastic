#' Full text search of Elasticsearch - URI requests
#'
#' @import httr
#' @export
#'
#' @param index Index
#' @param type Document type
#' @param q The query string (maps to the query_string query, see Query String Query for more 
#' details).
#' @param df The default field to use when no field prefix is defined within the query.
#' @param analyzer The analyzer name to be used when analyzing the query string.
#' @param default_operator The default operator to be used, can be AND or OR. Default: OR.
#' @param explain (logical) For each hit, contain an explanation of how scoring of the hits 
#' was computed.
#' @param source Set to FALSE to disable retrieval of the _source field. You can also retrieve 
#' part of the document by using _source_include & _source_exclude (see the request body 
#' documentation for more details)
#' @param fields The selective stored fields of the document to return for each hit. Not 
#' specifying any value will cause no fields to return.
#' @param sort Sorting to perform. Can either be in the form of fieldName, or 
#' fieldName:asc/fieldName:desc. The fieldName can either be an actual field within the document, 
#' or the special _score name to indicate sorting based on scores. There can be several sort 
#' parameters (order is important).
#' @param track_scores When sorting, set to TRUE in order to still track scores and return them 
#' as part of each hit.
#' @param timeout A search timeout, bounding the search request to be executed within the 
#' specified time value and bail with the hits accumulated up to that point when expired. Default: 
#' no timeout.
#' @param terminate_after The maximum number of documents to collect for each shard, upon 
#' reaching which the query execution will terminate early. If set, the response will have a 
#' boolean field terminated_early to indicate whether the query execution has actually 
#' terminated_early. Defaults to no terminate_after.
#' @param from The starting from index of the hits to return. Default: 0.
#' @param size The number of hits to return. Default: 10.
#' @param search_type The type of the search operation to perform. Can be dfs_query_then_fetch, 
#' dfs_query_and_fetch, query_then_fetch, query_and_fetch, count, scan. Default: query_then_fetch. 
#' See Search Type for more details on the different types of search that can be performed.
#' @param lowercase_expanded_terms Should terms be automatically lowercased or not. Default: TRUE.
#' @param analyze_wildcard Should wildcard and prefix queries be analyzed or not. Default: FALSE.
#' @param raw If TRUE (default), data is parsed to list. If FALSE, then raw JSON.
#' @param ... Curl args passed on to \code{\link[httr]{GET}}
#' 
#' @details See \code{\link{search_body}} for doing requests in the body of the call.
#' 
#' @examples \donttest{
#' es_search(index="shakespeare")
#' es_search(index="shakespeare", type="act")
#' es_search(index="shakespeare", type="scene")
#' es_search(index="shakespeare", type="line")
#' 
#' # Return certain fields
#' es_search(index="shakespeare", fields=c('play_name','speaker'))
#' 
#' # sorting
#' es_search(index="shakespeare", type="act", sort="text_entry")
#' es_search(index="shakespeare", type="act", sort="speaker:desc", fields='speaker')
#' es_search(index="shakespeare", type="act", 
#'  sort=c("speaker:desc","play_name:asc"), fields=c('speaker','play_name'))
#' 
#' # paging
#' es_search(index="shakespeare", size=1, fields='text_entry')$hits$hits
#' es_search(index="shakespeare", size=1, from=1, fields='text_entry')$hits$hits
#' 
#' # queries
#' es_search(index="shakespeare", type="act", q="what")
#' res <- es_search(index="shakespeare", type="act", q="speech_number>='2'")
#' res$hits$total
#'
#' # more complex queries
#' es_search(index="shakespeare", q="what")
#' res <- es_search(index="shakespeare", q="speech_number>='2013-10-01'")
#' es_search(index="shakespeare", q="createdTime>='2013-10-01'")
#' es_search(index="shakespeare", size=1)
#' es_search(index="shakespeare", size=1, explain=TRUE)
#' 
#' # terminate query after x documents found
#' ## setting to 1 gives back one document for each shard
#' es_search(index="shakespeare", terminate_after=1)
#' ## or set to other number
#' es_search(index="shakespeare", terminate_after=2)
#'
#' # Get raw data
#' es_search(index="shakespeare", type="scene", raw=TRUE)
#'
#' # Curl debugging
#' library('httr')
#' out <- es_search(index="shakespeare", type="line", config=verbose())
#' }

es_search <- function(index=NULL, type=NULL, df=NULL, analyzer=NULL, default_operator=NULL, 
  explain=NULL, source=NULL, fields=NULL, sort=NULL, track_scores=NULL, timeout=NULL, 
  terminate_after=NULL, from=NULL, size=NULL, search_type=NULL, lowercase_expanded_terms=NULL, 
  analyze_wildcard=NULL, raw=FALSE, ...)
{
  search_GET("_search", index, type, args=ec(list(df=df, analyzer=analyzer, 
         default_operator=default_operator, explain=explain, `_source`=source, fields=cl(fields), 
         sort=cl(sort), track_scores=track_scores, timeout=timeout, terminate_after=terminate_after, 
         from=from, size=size, search_type=search_type, lowercase_expanded_terms=lowercase_expanded_terms, 
         analyze_wildcard=analyze_wildcard)), raw, ...)
}

search_GET <- function(path, index=NULL, type=NULL, args, raw, ...) 
{
  conn <- es_get_auth()
  url <- paste(conn$base, ":", conn$port, sep="")
  if(is.null(index) && is.null(type)){ url <- paste(url, path, sep="/") } else
    if(is.null(type) && !is.null(index)){ url <- paste(url, index, path, sep="/") } else {
      url <- paste(url, index, type, path, sep="/")    
    }
  tt <- GET(url, query=args, ...)
  if(tt$status_code > 202) stop(content(tt)$error)
  res <- content(tt, as = "text")
  if(raw) res else jsonlite::fromJSON(res, FALSE)
}
