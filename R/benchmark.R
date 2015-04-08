#' Run benchmark tests
#' 
#' THIS FUNCTION DOESN'T WORK YET.
#' 
#' @keywords internal
#' @param raw (logical) If TRUE (default), data is parsed to list. If FALSE, then raw JSON.
#' @param callopts Curl args passed on to httr::POST.
#' @param query Query, either a list or json.
#' @param ... Further args passed on to elastic search HTTP API as parameters. Not used right now.
#' @references 
#' \url{http://www.elasticsearch.org/guide/en/elasticsearch/reference/master/search-benchmark.html}
#' @examples \dontrun{ 
#' # pass in as an R list
#' args <- list(name = "b1", 
#'    competitors = list(name = "c1", requests = list(query = list(match = "a*"))))
#' benchmark(index="shakespeare", query=args)
#' 
#' # or pass in as json query with newlines, easy to read
#' aggs <- '{
#' "name": "b1",
#' "competitors": [ {
#' "name": "c1",
#'   "requests": [ {
#'     "query": {
#'       "match": { "_all": "a*" }
#'     }
#'   } ]
#' } ]
#' }'
#' benchmark(query=aggs)
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
#' mmatch <- '{"query": {"multi_match" : {"query" : "henry","fields":["text_entry","play_name"]}}}'
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
#' }

benchmark <- function(raw=FALSE, callopts=list(), query=list(), ...){
  message("This function doesn't work yet")
  # bench_POST(query = query, raw = raw, callopts = callopts, ...)
}

bench_POST <- function(query, raw, callopts, ...){
  checkconn()
  conn <- es_get_auth()
  url <- paste0(conn$base, ":", conn$port, "/shakespeare/_bench")
  args <- check_inputs(query)
  tt <- PUT(url, body=args, callopts, encode = "json")
  if(tt$status_code > 202){
    if(tt$status_code > 202) stop(tt$headers$statusmessage)
    if(content(tt)$status == "ERROR") stop(content(tt)$error_message)
  }
  res <- content(tt, as = "text")
  if(raw) res else jsonlite::fromJSON(res, FALSE)
}
