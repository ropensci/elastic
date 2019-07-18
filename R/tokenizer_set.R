#' Tokenizer operations
#'
#' @export
#'
#' @param conn an Elasticsearch connection object, see [connect()]
#' @param index (character) A character vector of index names
#' @param body Query, either a list or json.
#' @param ... Curl options passed on to [crul::HttpClient]
#' 
#' @references 
#' https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-tokenizers.html
#'
#' @author Scott Chamberlain <myrmecocystus@@gmail.com>
#' @examples \dontrun{
#' # connection setup
#' (x <- connect())
#' 
#' # set tokenizer
#'
#' ## NGram tokenizer
#' body <- '{
#'         "settings" : {
#'              "analysis" : {
#'                  "analyzer" : {
#'                      "my_ngram_analyzer" : {
#'                          "tokenizer" : "my_ngram_tokenizer"
#'                      }
#'                  },
#'                  "tokenizer" : {
#'                      "my_ngram_tokenizer" : {
#'                          "type" : "nGram",
#'                          "min_gram" : "2",
#'                          "max_gram" : "3",
#'                          "token_chars": [ "letter", "digit" ]
#'                      }
#'                  }
#'              }
#'       }
#' }'
#' if (index_exists('test1')) index_delete('test1')
#' tokenizer_set(index = "test1", body=body)
#' index_analyze(text = "hello world", index = "test1", 
#'   analyzer='my_ngram_analyzer')
#' }

tokenizer_set <- function(conn, index, body, ...) {
  is_conn(conn)
  if (length(index) > 1) stop("Only one index allowed", call. = FALSE)
  url <- conn$make_url()
  url <- sprintf("%s/%s", url, esc(index))
  tokenizer_PUT(conn, url, body, ...)
}

tokenizer_PUT <- function(conn, url, body, ...){
  body <- check_inputs(body)
  out <- conn$make_conn(url, json_type(), ...)$put(
    body = body, encode = "json")
  if (out$status_code > 202) geterror(conn, out)
  if (conn$warn) catch_warnings(out)
  jsonlite::fromJSON(out$parse('UTF-8'))
}
