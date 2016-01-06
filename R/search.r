#' Full text search of Elasticsearch
#'
#' @export
#' @name Search
#' @template search_par
#' @template search_egs
#' @param body Query, either a list or json.
#' @param scroll (character) Specify how long a consistent view of the index should
#' be maintained for scrolled search, e.g., "30s", "1m". See \code{\link{units-time}}.
#' @param search_path (character) The path to use for searching. Default to \code{_search},
#' but in some cases you may already have that in the base url set using \code{\link{connect}},
#' in which case you can set this to \code{NULL}
#' @seealso  \code{\link{Search_uri}} \code{\link{scroll}} 
#' \code{\link{count}} \code{\link{validate}}

Search <- function(index=NULL, type=NULL, q=NULL, df=NULL, analyzer=NULL, default_operator=NULL,
  explain=NULL, source=NULL, fields=NULL, sort=NULL, track_scores=NULL, timeout=NULL,
  terminate_after=NULL, from=NULL, size=NULL, search_type=NULL, lowercase_expanded_terms=NULL,
  analyze_wildcard=NULL, version=FALSE, lenient=FALSE, body=list(), raw=FALSE, asdf=FALSE, scroll=NULL,
  search_path="_search", ...) {

  search_POST(search_path, cl(esc(index)), esc(type),
    args=ec(list(df=df, analyzer=analyzer, default_operator=default_operator, explain=explain,
      `_source`=source, fields=cl(fields), sort=cl(sort), track_scores=track_scores,
      timeout=cn(timeout), terminate_after=cn(terminate_after),
      from=cn(from), size=cn(size), search_type=search_type,
      lowercase_expanded_terms=lowercase_expanded_terms, analyze_wildcard=analyze_wildcard,
      version=as_log(version), q=q, scroll=scroll, lenient=as_log(lenient))), body, raw, asdf, ...)
}

search_POST <- function(path, index=NULL, type=NULL, args, body, raw, asdf, ...) {
  checkconn()
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
  url <- prune_trailing_slash(url)
  body <- check_inputs(body)
  tt <- POST(url, make_up(), ..., query = args, body = body)
  geterror(tt)
  # if (tt$status_code > 202) stop(error_parser(tt, 1), call. = FALSE)
  res <- content(tt, as = "text")
  if (raw) res else jsonlite::fromJSON(res, asdf)
}

prune_trailing_slash <- function(x) {
  gsub("\\/$", "", x)
}

# error_parser <- function(y, shard_no = 1) {
#   res <- content(y)
#   tryerr <- tryCatch(res$error, error = function(e) e)
#   if (!is(tryerr, "simpleError")) {
#     if (!is.null(res$error)) {
#       y <- res$error
#       if (grepl("SearchParseException", y)) {
#         first <- strloc2match(y, 1, ";")
#         shards <- strsplit(substring(y, regexpr(";", y) + 17, nchar(y)), "\\}\\{")[[1]]
#         shards <- gsub("\\s}]$|\\s$", "", shards)
#         paste(first, paste0("1st shard:  ", shards[1:shard_no]), sep = "\n")
#       } else {
#         y
#       }
#     } else {
#       y
#     }
#   } else {
#     mssg <- tryCatch(http_status(y)$message, error = function(e) e)
#     if (is(mssg, "simpleError")) {
#       y$status_code
#     } else {
#       mssg
#     }
#   }
# }

strmatch <- function(x, y) regmatches(x, regexpr(y, x))
strloc2match <- function(x, first, y) substring(x, first, regexpr(y, x) - 1)

# Make sure variable is a numeric or integer --------------
cn <- function(x) {
  name <- substitute(x)
  if (!is.null(x)) {
    tryx <- tryCatch(as.numeric(as.character(x)), warning = function(e) e)
    if ("warning" %in% class(tryx)) {
      stop(name, " should be a numeric or integer class value", call. = FALSE)
    }
    if (!is(tryx, "numeric") | is.na(tryx))
      stop(name, " should be a numeric or integer class value", call. = FALSE)
    return( format(x, digits = 22, scientific = FALSE) )
  } else {
    NULL
  }
}

make_url <- function(x) {
  if (is.null(x$port) || nchar(x$port) == 0) {
    x$base
  } else {
    paste(x$base, ":", x$port, sep = "")
  }
}
