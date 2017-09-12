stop_es_version <- function(ver_check, fxn) {
  ver <- es_version()
  if (ver < ver_check) {
    stop(fxn, " is not available for this Elasticsearch version", call. = FALSE)
  }
}

es_version <- function(ver_check, fxn) {
  xx <- info()$version$number
  xx <- gsub("[A-Za-z]", "", xx)
  as.numeric(gsub("\\.|-", "", xx))
}
