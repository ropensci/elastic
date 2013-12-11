#' Full text search of any CouchDB databases using Elasticsearch.
#' 
#' @import httr 
#' @importFrom plyr compact
#' @param endpoint the endpoint, defaults to localhost (http://127.0.0.1)
#' @param port port to connect to, defaults to 5984
#' @param dbname Database name. (charcter)
#' @param parse_ yes or no
#' @param verbose Verbosity or not
#' @param docid Document ID (character)
#' @param q Query terms.
#' @param ... Further args passed on to ...
#' @details There are a lot of terms you can use for Elasticsearch. See here 
#'    \url{http://www.elasticsearch.org/guide/reference/query-dsl/} for the documentation.
#' @examples
#' results <- elastic_search(dbname="rplos_db", q="scienceseeker")
#' sapply(results, function(x) x$id) # get the document IDs
#' sapply(results, function(x) x$res) # get the document contents
#' sapply(results, function(x) x$res)[[1]][[1]] # get one of the documents contents'
#' @export
elastic_search <- function(endpoint="http://127.0.0.1", port=9200, dbname, parse_=TRUE, 
                        verbose=TRUE, ...)
{
  call_ <- paste(paste(endpoint, port, sep=":"), "/", dbname, "/_search", sep="")
  args <- compact(list(...))
  out <- GET(call_, query=args)
  stop_for_status(out)
  
  parsed <- content(out)
  if(verbose)
    message(paste("\nmatches -> ", round(parsed$hits$total,1), "\nscore -> ", round(parsed$hits$max_score,3), sep=""))  
  class(parsed) <- "elastic"
  return( parsed )
  
#   if(parse_){
#     parsed <- content(out)
#     if(verbose)
#       message(paste("\nmatches -> ", round(parsed$hits$total,1), "\nscore -> ", round(parsed$hits$max_score,3), sep=""))  
#     return( llply(parsed$hits$hits, function(x) list(id=x$`_id`, res=x$`_source`$response)) ) 
#   } else
#     { 
#       class(out) <- "sofaes"
#       return( content(out) ) 
#     }
}