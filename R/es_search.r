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
#' results <- es_search(dbname="rplos_db", q="scienceseeker")
#' sapply(results$hits$hits, function(x) x$`_id`) # get the document IDs
#' lapply(results$hits$hits, function(x) x$`_source`) # get the document contents
#' sapply(results$hits$hits, function(x) x$`_source`)[[1]][[1]] # get one of the documents contents'
#' 
#' 
#' doc1 <- '{"name":"james","icecream":"mint"}'
#' doc2 <- '{"name":"jane","icecream":"rocky road"}'
#' sofa_writedoc(dbname="mydb", doc=doc1)
#' sofa_writedoc(dbname="mydb", doc=doc2)
#' es_search(dbname="mydb", q="mint")
#' }

es_search <- function(url="http://127.0.0.1", port=9200, dbname=NULL, parse=TRUE, 
  verbose=TRUE, ...)
{
  if(is.null(dbname)){
    call_ <- url
  } else
  {
    call_ <- paste(paste(url, port, sep=":"), "/", dbname, "/_search", sep="")    
  }
  args <- compact(list(...))
  out <- GET(call_, query=args)
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