#' Tokenizer operations
#'
#' @export
#' 
#' @param index (character) A character vector of index names
#' @param body Query, either a list or json.
#' @param ... Curl options passed on to \code{\link[httr]{PUT}}
#' 
#' @author Scott Chamberlain <myrmecocystus@@gmail.com>
#' @examples \dontrun{
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
#' index_analyze(text = "hello world", index = "test1", analyzer='my_ngram_analyzer')
#' }

tokenizer_set <- function(index, body, ...) {
  if (length(index) > 1) stop("Only one index allowed", call. = FALSE)
  url <- make_url(es_get_auth())
  url <- sprintf("%s/%s", url, esc(index))
  tokenizer_PUT(url, body, ...)
}

tokenizer_PUT <- function(url, body, ...){
  checkconn()
  body <- check_inputs(body)
  out <- PUT(url, make_up(), ..., body = body, encode = "json")
  if (out$status_code > 202) geterror(out)
  tt <- content(out, as = "text")
  jsonlite::fromJSON(tt)
}
