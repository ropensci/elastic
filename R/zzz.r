ec <- function (l) Filter(Negate(is.null), l)

as_log <- function(x){
  stopifnot(is.logical(x))
  if(x) 'true' else 'false'
}

cl <- function(x) if(is.null(x)) NULL else paste0(x, collapse = ",")

scroll_POST <- function(path, args, body, raw, ...) 
{
  url <- make_url(es_get_auth())
  tt <- POST(file.path(url, path), query=args, body=body)
  if(tt$status_code > 202) stop(error_parser(content(tt)$error, 1))
  res <- content(tt, as = "text")
  if(raw) res else jsonlite::fromJSON(res, FALSE)
}

esc <- function(x){
  if(is.null(x)){
    NULL
  } else {
    RCurl::curlEscape(x)
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
    NULL
  }
}
