#' @examples \donttest{
#' # URI string queries
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
#' # Get version number for each document
#' es_search(index="shakespeare", version=TRUE, size=2)
#'
#' # Get raw data
#' es_search(index="shakespeare", type="scene", raw=TRUE)
#'
#' # Curl debugging
#' library('httr')
#' out <- es_search(index="shakespeare", type="line", config=verbose())
#' 
#' 
#' 
#' # Query DSL searches
#' # pass in as an R list
#' aggs <- list(aggs = list(stats = list(terms = list(field = "text_entry"))))
#' es_search(index="shakespeare", body=aggs)
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
#' es_search(index="shakespeare", body=aggs)
#' 
#' # or pass in collapsed json string
#' aggs <- '{"aggs":{"stats":{"terms":{"field":"text_entry"}}}}'
#' es_search(index="shakespeare", body=aggs)
#' 
#' # match query
#' match <- '{"query": {"match" : {"text_entry" : "Two Gentlemen"}}}'
#' es_search(index="shakespeare", body=match)
#' 
#' # multi-match (multiple fields that is) query
#' mmatch <- '{"query": {"multi_match" : {"query" : "henry", "fields": ["text_entry","play_name"]}}}'
#' es_search(index="shakespeare", body=mmatch)
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
#' es_search(index="shakespeare", body=mmatch)
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
#' es_search(index="shakespeare", body=mmatch)
#' }
