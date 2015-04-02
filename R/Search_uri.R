#' Full text search of Elasticsearch with URI search
#' 
#' @export
#' @template search_par
#' @template search_uri_egs
#' @seealso \code{\link{Search}}

Search_uri <- function(index=NULL, type=NULL, q=NULL, df=NULL, analyzer=NULL, default_operator=NULL, 
                   explain=NULL, source=NULL, fields=NULL, sort=NULL, track_scores=NULL, timeout=NULL, 
                   terminate_after=NULL, from=NULL, size=NULL, search_type=NULL, lowercase_expanded_terms=NULL, 
                   analyze_wildcard=NULL, version=FALSE, raw=FALSE, asdf=FALSE, ...) {
  
  search_GET("_search", esc(index), esc(type), 
              args=ec(list(df=df, analyzer=analyzer, default_operator=default_operator, explain=explain, 
                           `_source`=source, fields=cl(fields), sort=cl(sort), track_scores=track_scores, 
                           timeout=timeout, terminate_after=terminate_after, from=check_num(from, "from"), 
                           size=check_num(size, "size"), search_type=search_type, 
                           lowercase_expanded_terms=lowercase_expanded_terms, analyze_wildcard=analyze_wildcard, 
                           version=version, q=q, scroll=scroll)), raw, asdf, ...)
}

search_GET <- function(path, index=NULL, type=NULL, args, raw, asdf, ...) {
  conn <- es_get_auth()
  url <- make_url(conn)
  if (is.null(index) && is.null(type)) {
    url <- paste(url, path, sep = "/") 
  } else {
    if (is.null(type) && !is.null(index)) {
      url <- paste(url, index, path, sep = "/") 
    } else {
      url <- paste(url, index, type, path, sep = "/")
    }
  }
  userpwd <- make_up()
  tt <- GET(url, query = args, userpwd, ...)
  if (tt$status_code > 202) stop(error_parser(tt, 1), call. = FALSE)
  res <- content(tt, as = "text")
  if (raw) res else jsonlite::fromJSON(res, asdf)
}
