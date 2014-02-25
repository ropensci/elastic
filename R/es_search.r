#' Full text search of any CouchDB databases using Elasticsearch.
#' 
#' @import httr 
#' @importFrom plyr compact
#' @param url the url, defaults to localhost (http://127.0.0.1)
#' @param port port to connect to, defaults to 5984
#' @param dbname Database name. (charcter)
#' @param parse If TRUE (default), data is parsed to list. If FALSE, then raw JSON.
#' @param verbose Verbosity (default) or not. Ignored if parse=FALSE
#' @param ... Further args passed on to elastic search HTTP API.
#' @details There are a lot of terms you can use for Elasticsearch. See here 
#'    \url{http://www.elasticsearch.org/guide/reference/query-dsl/} for the documentation.
#' @export
#' @examples \dontrun{
#' init <- es_connect()
#' es_search(init, index="twitter")
#' es_search(init, index="twitter", type="tweet")
#' es_search(init, index="twitter", type="mention")
#' es_search(init, index="twitter", type="tweet", q="what")
#' es_search(init, index="twitter", type="tweet", sort="message")
#' 
#' # Get raw data
#' es_search(init, index="twitter", type="tweet", parse=FALSE)
#' }

es_search <- function(conn, index=NULL, type=NULL, parse=TRUE, verbose=TRUE, callopts=list(), ...)
{
  base <- paste(conn$url, ":", conn$port, sep="")
  url <- paste(base, index, type, "_search", sep="/")
  args <- compact(list(...))
  out <- GET(url, query=args)
  stop_for_status(out)

  if(!parse){
    tt <- content(out, as="text")
    class(tt) <- "elastic"
    return( tt )
  } else {
    parsed <- content(out)
    if(verbose)
      max_score <- parsed$hits$max_score
      message(paste("\nmatches -> ", round(parsed$hits$total,1), "\nscore -> ", 
        ifelse(is.null(max_score), NA, round(max_score, 3)), sep="")
      )
    class(parsed) <- "elastic"
    return( parsed )
  }
}