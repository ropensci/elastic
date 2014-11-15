#' @references 
#' \url{http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search.html}
#' @details This function name has the "S" capitalized to avoid conflict with the function
#' \code{base::search}. I hate mixing cases, as I think it confuses users, but in this case
#' it seems neccessary. 
#' @examples \donttest{
#' # URI string queries
#' Search(index="shakespeare")
#' Search(index="shakespeare", type="act")
#' Search(index="shakespeare", type="scene")
#' Search(index="shakespeare", type="line")
#' 
#' ## Return certain fields
#' Search(index="shakespeare", fields=c('play_name','speaker'))
#' 
#' ## sorting
#' Search(index="shakespeare", type="act", sort="text_entry")
#' Search(index="shakespeare", type="act", sort="speaker:desc", fields='speaker')
#' Search(index="shakespeare", type="act", 
#'  sort=c("speaker:desc","play_name:asc"), fields=c('speaker','play_name'))
#' 
#' ## paging
#' Search(index="shakespeare", size=1, fields='text_entry')$hits$hits
#' Search(index="shakespeare", size=1, from=1, fields='text_entry')$hits$hits
#' 
#' ## queries
#' Search(index="shakespeare", type="act", q="what")
#' res <- Search(index="shakespeare", type="act", q="speech_number>='2'")
#' res$hits$total
#'
#' ## more complex queries
#' Search(index="shakespeare", q="what")
#' res <- Search(index="shakespeare", q="speech_number>='2013-10-01'")
#' Search(index="shakespeare", q="createdTime>='2013-10-01'")
#' Search(index="shakespeare", size=1)
#' Search(index="shakespeare", size=1, explain=TRUE)
#' 
#' ## terminate query after x documents found
#' ## setting to 1 gives back one document for each shard
#' Search(index="shakespeare", terminate_after=1)
#' ## or set to other number
#' Search(index="shakespeare", terminate_after=2)
#' 
#' ## Get version number for each document
#' Search(index="shakespeare", version=TRUE, size=2)
#'
#' ## Get raw data
#' Search(index="shakespeare", type="scene", raw=TRUE)
#'
#' ## Curl debugging
#' library('httr')
#' out <- Search(index="shakespeare", type="line", config=verbose())
#' 
#' 
#' 
#' # Query DSL searches - queries sent in the body of the request
#' # pass in as an R list
#' aggs <- list(aggs = list(stats = list(terms = list(field = "text_entry"))))
#' Search(index="shakespeare", body=aggs)
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
#' Search(index="shakespeare", body=aggs)
#' 
#' # or pass in collapsed json string
#' aggs <- '{"aggs":{"stats":{"terms":{"field":"text_entry"}}}}'
#' Search(index="shakespeare", body=aggs)
#' 
#' # match query
#' match <- '{"query": {"match" : {"text_entry" : "Two Gentlemen"}}}'
#' Search(index="shakespeare", body=match)
#' 
#' # multi-match (multiple fields that is) query
#' mmatch <- '{"query": {"multi_match" : {"query" : "henry", "fields": ["text_entry","play_name"]}}}'
#' Search(index="shakespeare", body=mmatch)
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
#' Search(index="shakespeare", body=mmatch)
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
#' Search(index="shakespeare", body=mmatch)
#' }
