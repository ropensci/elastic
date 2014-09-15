#' Full text search of any CouchDB databases using Elasticsearch.
#' 
#' @import httr 
#' @importFrom plyr compact
#' 
#' @template all
#' @details There are a lot of terms you can use for Elasticsearch. See here 
#'    \url{http://www.elasticsearch.org/guide/reference/query-dsl/} for the documentation.
#' @export
#' @examples \dontrun{
#' es_search(index="twitter")
#' es_search(index="twitter", type="tweet")
#' es_search(index="twitter", type="mention")
#' es_search(index="twitter", type="tweet", q="what")
#' es_search(index="twitter", type="tweet", sort="message")
#' 
#' # Get raw data
#' es_search(index="twitter", type="tweet", raw=TRUE)
#' 
#' # Curl debugging
#' library('httr')
#' es_search(index="twitter", type="tweet", callopts=verbose())
#' }

es_search <- function(index=NULL, type=NULL, raw=FALSE, verbose=TRUE, callopts=list(), ...)
{
  elastic_GET(path = "_search", index, type, NULL, NULL, clazz = 'elastic_search', raw, callopts, ...)
#   conn <- es_get_auth()
#   base <- paste(conn$base, ":", conn$port, sep="")
#   if(is.null(type)){ url <- paste(base, index, "_search", sep="/") } else {
#     url <- paste(base, index, type, "_search", sep="/")    
#   }
#   args <- es_compact(list(...))
#   out <- GET(url, query=args, callopts)
#   stop_for_status(out)
#   if(verbose) message(URLdecode(out$url))
#   tt <- content(out, as="text")
#   class(tt) <- "elastic_search"
#   if(raw){ tt } else { es_parse(tt, verbose=verbose) }
}
