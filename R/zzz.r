ec <- function(l) Filter(Negate(is.null), l)

cont_utf8 <- function(x) content(x, as = "text", encoding = "UTF-8")

as_log <- function(x){
  if (is.null(x)) {
    x
  } else {
    if (x) 'true' else 'false'
  }
}

`%|||%` <- function(x, y) if (x == "false") y else x

cl <- function(x) if (is.null(x)) NULL else paste0(x, collapse = ",")

cw <- function(x) if (is.null(x)) x else paste(x, collapse = ",")

scroll_POST <- function(path, args, body, raw, stream_opts, ...) {
  url <- make_url(es_get_auth())
  tt <- POST(file.path(url, path), make_up(), es_env$headers, ..., query = args, body = body)
  geterror(tt)
  res <- cont_utf8(tt)
  if (raw) {
    res 
  } else {
    if (length(stream_opts) != 0) {
      stream_opts$con <- textConnection(tt)
      do.call(jsonlite::stream_in, stream_opts)
    } else {
      jsonlite::fromJSON(res, FALSE)
    }
  }
}

scroll_DELETE <- function(path, body, ...) {
  url <- make_url(es_get_auth())
  tt <- DELETE(file.path(url, path), make_up(), es_env$headers, ..., body = body, encode = "json")
  geterror(tt)
  tt$status_code == 200
}

esc <- function(x) {
  if (is.null(x)) {
    NULL
  } else {
    curl::curl_escape(x)
  }
}

pluck <- function(x, name, type) {
  if (missing(type)) {
    lapply(x, "[[", name)
  } else {
    vapply(x, "[[", name, FUN.VALUE = type)
  }
}

make_up <- function() {
  up <- es_get_user_pwd()
  if (nchar(up$user) != 0 && nchar(up$pwd) != 0) {
    authenticate(up$user, up$pwd)
  } else {
    list()
  }
}

stop_es_version <- function(ver_check, fxn) {
  ver <- as.numeric(gsub("\\.", "", info()$version$number))
  if (ver < ver_check) {
    stop(fxn, " is not available for this Elasticsearch version", call. = FALSE)
  }
}

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

strmatch <- function(x, y) regmatches(x, regexpr(y, x))

strloc2match <- function(x, first, y) substring(x, first, regexpr(y, x) - 1)

prune_trailing_slash <- function(x) {
  gsub("\\/$", "", x)
}

construct_url <- function(url, path, index, type = NULL, id = NULL) {
  index <- esc(index)
  type <- esc(type)
  if (is.null(index) && is.null(type)) {
    paste(url, path, sep = "/")
  } else {
    if (is.null(type) && !is.null(index)) {
      paste(url, index, path, sep = "/")
    } else if (!is.null(type) && !is.null(index) && is.null(id)) {
      paste(url, index, type, path, sep = "/")
    } else if (!is.null(type) && !is.null(index) && !is.null(id)) {
      paste(url, index, type, id, path, sep = "/")
    } else if (!is.null(type) && is.null(index) && !is.null(id)) {
      stop("If a document ID is given, an index type must be given", call. = FALSE)
    }
  }
}
