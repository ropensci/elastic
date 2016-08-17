#' Full text search of Elasticsearch with URI search
#'
#' @export
#' @template search_par
#' @template search_uri_egs
#' @param search_path (character) The path to use for searching. Default to \code{_search},
#' but in some cases you may already have that in the base url set using \code{\link{connect}},
#' in which case you can set this to \code{NULL}
#' @seealso \code{\link{Search}} \code{\link{Search_template}} \code{\link{count}}

Search_uri <- function(index=NULL, type=NULL, q=NULL, df=NULL, analyzer=NULL, default_operator=NULL,
  explain=NULL, source=NULL, fields=NULL, sort=NULL, track_scores=NULL, timeout=NULL,
  terminate_after=NULL, from=NULL, size=NULL, search_type=NULL, lowercase_expanded_terms=NULL,
  analyze_wildcard=NULL, version=FALSE, lenient=FALSE, raw=FALSE,
  asdf=FALSE, search_path="_search", ...) {

  search_GET(search_path, cl(index), type,
    args=ec(list(df=df, analyzer=analyzer, default_operator=default_operator, explain=explain,
      `_source`=source, fields=cl(fields), sort=cl(sort), track_scores=track_scores,
      timeout=cn(timeout), terminate_after=cn(terminate_after),
      from=cn(from), size=cn(size), search_type=search_type,
      lowercase_expanded_terms=lowercase_expanded_terms, analyze_wildcard=analyze_wildcard,
      version=as_log(version), q=q, lenient=as_log(lenient))), raw, asdf, ...)
}

search_GET <- function(path, index=NULL, type=NULL, args, raw, asdf, ...) {
  checkconn()
  conn <- es_get_auth()
  url <- make_url(conn)
  url <- construct_url(url, path, index, type)
  url <- prune_trailing_slash(url)
  tt <- GET(url, query = args, make_up(), es_env$headers, ...)
  geterror(tt)
  res <- cont_utf8(tt)
  if (raw) res else jsonlite::fromJSON(res, asdf)
}
