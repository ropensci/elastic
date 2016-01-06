ec <- function(l) Filter(Negate(is.null), l)

as_log <- function(x){
  stopifnot(is.logical(x))
  if (x) 'true' else 'false'
}

cl <- function(x) if (is.null(x)) NULL else paste0(x, collapse = ",")

scroll_POST <- function(path, args, body, raw, ...) {
  checkconn()
  url <- make_url(es_get_auth())
  tt <- POST(file.path(url, path), make_up(), ..., query = args, body = body)
  geterror(tt)
  # if (tt$status_code > 202) stop(error_parser(content(tt)$error, 1))
  res <- content(tt, as = "text")
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
