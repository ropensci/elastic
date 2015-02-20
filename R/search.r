#' Full text search of Elasticsearch 
#'
#' @import httr
#' @importFrom RCurl curlEscape
#' @export
#' 
#' @template search_egs
#' @param index Index name
#' @param type Document type
#' @param q The query string (maps to the query_string query, see Query String Query for more 
#' details). See \url{http://bit.ly/esquerystring} for documentation and examples.
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
#' @param from (character) The starting from index of the hits to return. Pass in as a character 
#' string to avoid problems with large number conversion to scientific notation. Default: 0.
#' @param size (character) The number of hits to return. Pass in as a character string 
#' to avoid problems with large number conversion to scientific notation. Default: 10.
#' @param search_type The type of the search operation to perform. Can be dfs_query_then_fetch, 
#' dfs_query_and_fetch, query_then_fetch, query_and_fetch, count, scan. Default: query_then_fetch. 
#' See Search Type for more details on the different types of search that can be performed.
#' @param lowercase_expanded_terms Should terms be automatically lowercased or not. Default: TRUE.
#' @param analyze_wildcard Should wildcard and prefix queries be analyzed or not. Default: FALSE.
#' @param version (logical) Print the document version with each document.
#' @param body Query, either a list or json.
#' @param raw If TRUE (default), data is parsed to list. If FALSE, then raw JSON.
#' @param scroll (character) Specify how long a consistent view of the index should be maintained 
#' for scrolled search, e.g., "30s", "1m". See \code{\link{units-time}}.
#' @param ... Curl args passed on to \code{\link[httr]{POST}}
#' @seealso \code{\link{scroll}}
Search <- function(index=NULL, type=NULL, q=NULL, df=NULL, analyzer=NULL, default_operator=NULL, 
  explain=NULL, source=NULL, fields=NULL, sort=NULL, track_scores=NULL, timeout=NULL, 
  terminate_after=NULL, from=NULL, size=NULL, search_type=NULL, lowercase_expanded_terms=NULL, 
  analyze_wildcard=NULL, version=FALSE, body=list(), raw=FALSE, scroll=NULL, ...){
  
  search_POST("_search", esc(index), esc(type), 
    args=ec(list(df=df, analyzer=analyzer, default_operator=default_operator, explain=explain, 
      `_source`=source, fields=cl(fields), sort=cl(sort), track_scores=track_scores, 
      timeout=timeout, terminate_after=terminate_after, from=check_num(from, "from"), 
      size=check_num(size, "size"), search_type=search_type, 
      lowercase_expanded_terms=lowercase_expanded_terms, analyze_wildcard=analyze_wildcard, 
      version=version, q=q, scroll=scroll)), body, raw, ...)

}

#' @export
#' @rdname Search
Search_ <- function(.obj, ...) Search(...)

search_POST <- function(path, index=NULL, type=NULL, args, body, raw, ...) 
{
  conn <- es_get_auth()
  url <- make_url(conn)
  if(is.null(index) && is.null(type)){ url <- paste(url, path, sep="/") } else
    if(is.null(type) && !is.null(index)){ url <- paste(url, index, path, sep="/") } else {
      url <- paste(url, index, type, path, sep="/")    
    }
  body <- check_inputs(body)
  tt <- POST(url, query=args, body=body, ...)
  if(tt$status_code > 202) stop(error_parser(content(tt), 1), call. = FALSE)
  res <- content(tt, as = "text")
  if(raw) res else jsonlite::fromJSON(res, FALSE)
}

error_parser <- function(y, shard_no=1){
  if(!is.null(y$error)){
    y <- y$error
    if(grepl("SearchParseException", y)){
      first <- strloc2match(y, 1, ";")
      shards <- strsplit(substring(y, regexpr(";", y)+17, nchar(y)), "\\}\\{")[[1]]
      shards <- gsub("\\s}]$|\\s$", "", shards)
      paste(first, paste0("1st shard:  ", shards[1:shard_no]), sep = "\n")
    } else { 
      y 
    }
  } else {
    y
  }
}

strmatch <- function(x, y) regmatches(x, regexpr(y, x))
strloc2match <- function(x, first, y) substring(x, first, regexpr(y, x)-1)

# Make sure limit is a numeric or integer
check_num <- function(x, name){
  if(!is.null(x)){
    tryx <- tryCatch(as.numeric(as.character(x)), warning=function(e) e)
    if("warning" %in% class(tryx)){
      stop(sprintf("%s should be a numeric or integer class value", name), call. = FALSE)
    }
    if(!is(tryx, "numeric") | is.na(tryx))
      stop(sprintf("%s should be a numeric or integer class value", name), call. = FALSE)
    return( format(as.character(x), digits = 22) )
  } else {
    NULL
  }
}

make_url <- function(x){
  if(is.null(x$port) || nchar(x$port) == 0){
    x$base
  } else {
    paste(x$base, ":", x$port, sep="")
  }
}
