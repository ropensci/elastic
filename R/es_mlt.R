#' More like this API request.
#'
#' @export
#'
#' @param index The name of the index
#' @param type xxx
#' @param like_text xxx
#' @param doc_type The type of the document (use _all to fetch the first document matching the ID 
#' across all types)
#' @param id The document ID
#' @param body A specific search request definition
#' @param boost_terms The boost factor
#' @param include Whether to include the queried document from the response
#' @param max_doc_freq The word occurrence frequency as count: words with higher occurrence in the 
#' corpus will be ignored
#' @param max_query_terms The maximum query terms to be included in the generated query
#' @param max_word_length The minimum length of the word: longer words will be ignored
#' @param min_doc_freq The word occurrence frequency as count: words with lower occurrence in the 
#' corpus will be ignored
#' @param min_term_freq The term frequency as percent: terms with lower occurence in the source 
#' document will be ignored
#' @param min_word_length The minimum length of the word: shorter words will be ignored
#' @param mlt_fields Specific fields to perform the query against
#' @param percent_terms_to_match How many terms have to match in order to consider the document a 
#' match (default: 0.3)
#' @param routing Specific routing value
#' @param search_from The offset from which to return results
#' @param search_indices A comma-separated list of indices to perform the query against (default: 
#' the index containing the document)
#' @param search_query_hint The search query hint
#' @param search_scroll A scroll search request definition
#' @param search_size The number of documents to return (default: 10)
#' @param search_source A specific search request definition (instead of using the request body)
#' @param search_type Specific search type (eg. dfs_then_fetch, count, etc)
#' @param search_types A comma-separated list of types to perform the query against (default: the 
#' same type as the document)
#' @param stop_words A list of stop words to be ignored
#' @param callopts curl options passed on to \code{\link[httr]{GET}}
#' 
#' @details Currently uses HTTP GET request, so parameters are passed in the URL. Another option 
#' is the more like this query, which passes the query in the body of a POST request - may
#' be added later.
#' 
#' @examples  \donttest{
#' es_mlt(index = "plos", type = "article", id = 5)$hits$total
#' es_mlt(index = "plos", type = "article", id = 5, min_doc_freq=12)$hits$total
#' es_mlt(index = "plos", type = "article", id = 800)$hits$total
#' 
#' # Return different number of results
#' es_mlt(index = "plos", type = "article", id = 800, search_size=1)$hits$hits
#' es_mlt(index = "plos", type = "article", id = 800, search_size=2)$hits$hits
#' 
#' # Exclude stop words
#' es_mlt(index = "plos", type = "article", id = 800)$hits$total
#' es_mlt(index = "plos", type = "article", id = 800, stop_words="the,and")$hits$total
#' 
#' # Specify percent of terms that have to match
#' es_mlt(index = "plos", type = "article", id = 800, percent_terms_to_match=0.1)$hits$total
#' es_mlt(index = "plos", type = "article", id = 800, percent_terms_to_match=0.7)$hits$total
#' 
#' # Maximum query terms to be included in the generated query
#' es_mlt(index = "plos", type = "article", id = 800, max_query_terms=1)$hits$total
#' es_mlt(index = "plos", type = "article", id = 800, max_query_terms=2)$hits$total
#' es_mlt(index = "plos", type = "article", id = 800, max_query_terms=3)$hits$total
#' 
#' # Maximum query terms to be included in the generated query
#' es_mlt(index = "plos", type = "article", id = 800, mlt_fields="title", boost_terms=1)$hits$total
#' }
es_mlt <- function(index, type, id, doc_type=NULL, body=NULL, 
  boost_terms=NULL, include=NULL, max_doc_freq=NULL, max_query_terms=NULL, max_word_length=NULL, 
  min_doc_freq=NULL, min_term_freq=NULL, min_word_length=NULL, mlt_fields=NULL, 
  percent_terms_to_match=NULL, routing=NULL, search_from=NULL, search_indices=NULL, 
  search_query_hint=NULL, search_scroll=NULL, search_size=NULL, search_source=NULL, 
  search_type=NULL, search_types=NULL, stop_words=NULL, like_text=NULL, callopts=list())
{
  conn <- es_connect()
  url <- sprintf("%s:%s/%s/%s/%s/%s", conn$base, conn$port, index, type, id, "_mlt")
  args <- ec(list(doc_type=doc_type, id=id, body=body, boost_terms=boost_terms, 
    include=include, max_doc_freq=max_doc_freq, max_query_terms=max_query_terms, 
    max_word_length=max_word_length, min_doc_freq=min_doc_freq, min_term_freq=min_term_freq, 
    min_word_length=min_word_length, mlt_fields=mlt_fields, percent_terms_to_match=percent_terms_to_match, 
    routing=routing, search_from=search_from, search_indices=search_indices, 
    search_query_hint=search_query_hint, search_scroll=search_scroll, search_size=search_size, 
    search_source=search_source, search_type=search_type, search_types=search_types, stop_words=stop_words,
    like_text=like_text))
  res <- GET(url, query=args, callopts)
  stop_for_status(res)
  tt <- content(res, "text")
  jsonlite::fromJSON(tt, FALSE)
}
