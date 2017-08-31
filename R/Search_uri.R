#' Full text search of Elasticsearch with URI search
#'
#' @export
#' @template search_par
#' @template search_uri_egs
#' @seealso \code{\link{fielddata}}
#' @param search_path (character) The path to use for searching. Default
#' to \code{_search}, but in some cases you may already have that in the base
#' url set using \code{\link{connect}}, in which case you can set this
#' to \code{NULL}
#' @seealso \code{\link{Search}} \code{\link{Search_template}}
#' \code{\link{count}} \code{\link{fielddata}}

Search_uri <- function(index=NULL, type=NULL, q=NULL, df=NULL, analyzer=NULL,
  default_operator=NULL, explain=NULL, source=NULL, fields=NULL, sort=NULL,
  track_scores=NULL, timeout=NULL, terminate_after=NULL, from=NULL, size=NULL,
  search_type=NULL, lowercase_expanded_terms=NULL, analyze_wildcard=NULL,
  version=NULL, lenient=FALSE, raw=FALSE, asdf=FALSE,
  search_path="_search", stream_opts=list(), ...) {

  search_GET(search_path, cl(index), type,
    args = ec(list(df = df, analyzer = analyzer,
      default_operator = default_operator, explain = explain,
      `_source` = cl(source), fields = cl(fields), sort = cl(sort),
      track_scores = track_scores, timeout = cn(timeout),
      terminate_after = cn(terminate_after), from = cn(from), size = cn(size),
      search_type = search_type,
      lowercase_expanded_terms = lowercase_expanded_terms,
      analyze_wildcard = analyze_wildcard, version = as_log(version), q = q,
      lenient = as_log(lenient))), raw, asdf, stream_opts, ...)
}

search_GET <- function(path, index=NULL, type=NULL, args, raw, asdf, 
                       stream_opts, ...) {
  conn <- es_get_auth()
  url <- make_url(conn)
  url <- construct_url(url, path, index, type)
  url <- prune_trailing_slash(url)
  # in ES >= v5, lenient param droppped
  if (es_ver() >= 500) args$lenient <- NULL
  # in ES >= v5, fields param changed to stored_fields
  if (es_ver() >= 500) {
    if ("fields" %in% names(args)) {
      stop(
        '"fields" parameter is deprecated in ES >= v5. See help in ?Search_uri', 
        call. = FALSE)
    }
  }
  tt <- GET(url, query = args, make_up(), content_type_json(), 
            es_env$headers, ...)
  geterror(tt)
  res <- cont_utf8(tt)
  
  if (raw) {
    res 
  } else {
    if (length(stream_opts) != 0) {
      dat <- jsonlite::fromJSON(res, flatten = TRUE)
      stream_opts$x <- dat$hits$hits
      if (length(stream_opts$x) != 0) {
        stream_opts$con <- file(stream_opts$file, open = "ab")
        stream_opts$file <- NULL
        do.call(jsonlite::stream_out, stream_opts)
        close(stream_opts$con)
      } else {
        warning("no scroll results remain", call. = FALSE)
      }
      return(list(`_scroll_id` = dat$`_scroll_id`))
    } else {
      jsonlite::fromJSON(res, asdf, flatten = TRUE)
    }
  }
}
