#' Full text search of Elasticsearch - body requests.
#'
#' @import httr
#' @export
#' @template all
#' @param query Query, either a list or json.
#' @examples \dontrun{ 
#' aggs <- list(stats = list(terms = list(field = "client_ip")))
#' 
#' # pass in as an R list
#' aggs <- list(aggs = list(stats = list(terms = list(field = "text_entry"))))
#' es_search_body(index="shakespeare", query=aggs)
#' 
#' # or pass in as json query with newlines, easy to read
#' aggs <- '{
#'     "aggs": {
#'         "stats" : {
#'             "terms" : {
#'                 "field" : "text_entry"
#'             }
#'         }
#'     }
#' }'
#' es_search_body(index="shakespeare", query=aggs)
#' 
#' 
#' # or pass in collapsed json string
#' aggs <- '{"aggs":{"stats":{"terms":{"field":"text_entry"}}}}'
#' es_search_body(index="shakespeare", query=aggs)
#' 
#' # match query
#' match <- '{"query": {"match" : {"text_entry" : "Two Gentlemen"}}}'
#' es_search_body(index="shakespeare", query=match)
#' 
#' # multi-match (multiple fields that is) query
#' mmatch <- '{"query": {"multi_match" : {"query" : "henry", "fields": ["text_entry","play_name"]}}}'
#' es_search_body(index="shakespeare", query=mmatch)
#' 
#' # bool query
#' mmatch <- '{
#'  "query": {
#'    "bool" : {
#'      "must_not" : {
#'        "range" : {
#'          "speech_number" : {
#'            "from" : 1, "to": 5 
#' }}}}}}'
#' es_search_body(index="shakespeare", query=mmatch)
#' 
#' # Boosting query
#' boost <- '{
#'  "query" : { 
#'   "boosting" : {
#'       "positive" : {
#'           "term" : {
#'               "play_name" : "henry"
#'           }
#'       },
#'       "negative" : {
#'           "term" : {
#'               "text_entry" : "thou"
#'           }
#'       },
#'       "negative_boost" : 0.2
#'     }
#'  }
#' }'
#' es_search_body(index="shakespeare", query=mmatch)
#' 
#' # 
#' }

es_search_body <- function(index=NULL, type=NULL, raw=FALSE, callopts=list(), query=list(), ...)
{
  elastic_POST(path = "_search",
              index = index,
              type = type,
              clazz = 'elastic_search',
              raw = raw,
              callopts = callopts, 
              query = query, 
              ...)
}

