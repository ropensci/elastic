#' Full text search of Elasticsearch - body requests.
#'
#' @keywords internal
#' @param index Index name
#' @param type Document type
#' @param raw If TRUE (default), data is parsed to list. If FALSE, then raw JSON.
#' @param callopts Curl args passed on to httr::POST.
#' @param query Query, either a list or json.
#' @param ... Further args passed on to elastic search HTTP API as parameters. Not used right now.
#' @examples \dontrun{
#' # pass in as an R list
#' # aggs <- list(aggs = list(stats = list(terms = list(field = "text_entry"))))
#' # search_body(index="shakespeare", query=aggs)
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
#' # search_body(index="shakespeare", query=aggs)
#'
#'
#' # or pass in collapsed json string
#' aggs <- '{"aggs":{"stats":{"terms":{"field":"text_entry"}}}}'
#' # search_body(index="shakespeare", query=aggs)
#'
#' # match query
#' match <- '{"query": {"match" : {"text_entry" : "Two Gentlemen"}}}'
#' # search_body(index="shakespeare", query=match)
#'
#' # multi-match (multiple fields that is) query
#' mmatch <- '{"query": {"multi_match" : {"query" : "henry", "fields": ["text_entry","play_name"]}}}'
#' # search_body(index="shakespeare", query=mmatch)
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
#' # search_body(index="shakespeare", query=mmatch)
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
#' # search_body(index="shakespeare", query=mmatch)
#' }

search_body <- function(index=NULL, type=NULL, raw=FALSE, callopts=list(), query=list(), ...)
{
  es_POST(path = "_search",
              index = index,
              type = type,
              clazz = 'elastic_search',
              raw = raw,
              callopts = callopts,
              query = query,
              ...)
}

