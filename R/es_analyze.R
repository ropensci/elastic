#' Performs the analysis process on a text and return the tokens breakdown of the text.
#' 
#' @export
#' 
#' @param text The text on which the analysis should be performed (when request body is not used)
#' @param field Use the analyzer configured for this field (instead of passing the analyzer name)
#' @param index The name of the index to scope the operation
#' @param analyzer The name of the analyzer to use
#' @param tokenizer The name of the tokenizer to use for the analysis
#' @param filters A comma-separated list of filters to use for the analysis
#' @param char_filters A comma-separated list of character filters to use for the analysis
#' @param callopts Curl args passed on to httr::POST.
#' @references 
#' \url{http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-analyze.html} 
#' @details This method can accept a sting of text in the body, but this function passes it as a 
#' parameter in a GET request to simplify. 
#' @examples \donttest{
#' es_analyze(text = 'this is a test', analyzer='standard')
#' es_analyze(text = 'this is a test', analyzer='whitespace')
#' es_analyze(text = 'this is a test', analyzer='stop')
#' es_analyze(text = 'this is a test', tokenizer='keyword', filters='lowercase')
#' es_analyze(text = 'this is a test', tokenizer='keyword', filters='lowercase', 
#'    char_filters='html_strip')
#' es_analyze(text = 'this is a test', index = 'plos')
#' es_analyze(text = 'this is a test', index = 'shakespeare')
#' es_analyze(text = 'this is a test', index = 'shakespeare', callopts=verbose())
#' }
es_analyze <- function(text=NULL, field=NULL, index=NULL, analyzer=NULL, tokenizer=NULL, 
  filters=NULL, char_filters=NULL, callopts=list())
{
  conn <- es_connect()
  if(!is.null(index)) 
    url <- sprintf("%s:%s/%s/_analyze", conn$base, conn$port, cl(index)) 
  else 
    url <- sprintf("%s:%s/_analyze", conn$base, conn$port)
  args <- ec(list(text=text, analyzer=analyzer, tokenizer=tokenizer, filters=filters, 
                          char_filters=char_filters, field=field))
  analyze_GET(url, args, callopts)$tokens
}

cl <- function(x) paste0(x, collapse = ",")

analyze_GET <- function(url, args, callopts){
  out <- GET(url, query=args, callopts)
  stop_for_status(out)
  tt <- content(out, as = "text")
  jsonlite::fromJSON(tt)
}
