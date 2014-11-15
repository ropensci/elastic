#' @references 
#' \url{http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search.html}
#' @examples \donttest{
#' # URI string queries
#' search(index="shakespeare")
#' search(index="shakespeare", type="act")
#' search(index="shakespeare", type="scene")
#' search(index="shakespeare", type="line")
#' 
#' # Return certain fields
#' search(index="shakespeare", fields=c('play_name','speaker'))
#' 
#' # sorting
#' search(index="shakespeare", type="act", sort="text_entry")
#' search(index="shakespeare", type="act", sort="speaker:desc", fields='speaker')
#' search(index="shakespeare", type="act", 
#'  sort=c("speaker:desc","play_name:asc"), fields=c('speaker','play_name'))
#' 
#' # paging
#' search(index="shakespeare", size=1, fields='text_entry')$hits$hits
#' search(index="shakespeare", size=1, from=1, fields='text_entry')$hits$hits
#' 
#' # queries
#' search(index="shakespeare", type="act", q="what")
#' res <- search(index="shakespeare", type="act", q="speech_number>='2'")
#' res$hits$total
#'
#' # more complex queries
#' search(index="shakespeare", q="what")
#' res <- search(index="shakespeare", q="speech_number>='2013-10-01'")
#' search(index="shakespeare", q="createdTime>='2013-10-01'")
#' search(index="shakespeare", size=1)
#' search(index="shakespeare", size=1, explain=TRUE)
#' 
#' # terminate query after x documents found
#' ## setting to 1 gives back one document for each shard
#' search(index="shakespeare", terminate_after=1)
#' ## or set to other number
#' search(index="shakespeare", terminate_after=2)
#' 
#' # Get version number for each document
#' search(index="shakespeare", version=TRUE, size=2)
#'
#' # Get raw data
#' search(index="shakespeare", type="scene", raw=TRUE)
#'
#' # Curl debugging
#' library('httr')
#' out <- search(index="shakespeare", type="line", config=verbose())
#' 
#' 
#' 
#' # Query DSL searches
#' # pass in as an R list
#' aggs <- list(aggs = list(stats = list(terms = list(field = "text_entry"))))
#' search(index="shakespeare", body=aggs)
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
#' search(index="shakespeare", body=aggs)
#' 
#' # or pass in collapsed json string
#' aggs <- '{"aggs":{"stats":{"terms":{"field":"text_entry"}}}}'
#' search(index="shakespeare", body=aggs)
#' 
#' # match query
#' match <- '{"query": {"match" : {"text_entry" : "Two Gentlemen"}}}'
#' search(index="shakespeare", body=match)
#' 
#' # multi-match (multiple fields that is) query
#' mmatch <- '{"query": {"multi_match" : {"query" : "henry", "fields": ["text_entry","play_name"]}}}'
#' search(index="shakespeare", body=mmatch)
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
#' search(index="shakespeare", body=mmatch)
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
#' search(index="shakespeare", body=mmatch)
#' }
