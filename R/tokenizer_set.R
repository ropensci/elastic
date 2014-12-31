#' Tokenizer operations
#'
#' @export
#' 
#' @param index (character) A character vector of index names
#' @param body Query, either a list or json.
#' @param ... Further args passed on to elastic search \code{\link[httr]{GET}}
#' 
#' @author Scott Chamberlain <myrmecocystus@@gmail.com>
#' @examples \dontrun{
#' # set tokenizer
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
#' tokenizer_set(index = "shakespeare", body=body)
#' }

tokenizer_set <- function(index, body, ...)
{
  if(length(index) > 1) stop("Only one index allowed", call. = FALSE)
  conn <- connect()
  url <- sprintf("%s:%s/%s", conn$base, conn$port, index)
  tokenizer_PUT(url, body, ...)
}

tokenizer_PUT <- function(url, body, ...){
  body <- check_inputs(body)
  out <- PUT(url, body=body, encode = "json", ...)
  stop_for_status(out)
  tt <- content(out, as = "text")
  jsonlite::fromJSON(tt)
}
