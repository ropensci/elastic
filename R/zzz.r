ec <- function(l) Filter(Negate(is.null), l)

cont_utf8 <- function(x) content(x, as = "text", encoding = "UTF-8")

as_log <- function(x){
  stopifnot(is.logical(x))
  if (x) 'true' else 'false'
}

cl <- function(x) if (is.null(x)) NULL else paste0(x, collapse = ",")

scroll_POST <- function(path, args, body, raw, allowed_codes, ...) {
  checkconn()
  url <- make_url(es_get_auth())
  tt <- POST(file.path(url, path), make_up(), es_env$headers, ..., query = args, body = body)
  geterror(tt, allowed_codes)
  res <- cont_utf8(tt)
  if (raw) res else jsonlite::fromJSON(res, FALSE)
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
  ver <- as.numeric(gsub("\\.", "", connection()$es_deets$version$number))
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

construct_url <- function(url, path, index, type) {
  if (is.null(index) && is.null(type)) {
    paste(url, path, sep = "/")
  } else {
    if (is.null(type) && !is.null(index)) {
      paste(url, index, path, sep = "/")
    } else {
      paste(url, index, type, path, sep = "/")
    }
  } 
}
