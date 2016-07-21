stop_es_version <- function(ver_check, fxn) {
  ver <- es_version()
  if (ver < ver_check) {
    stop(fxn, " is not available for this Elasticsearch version", call. = FALSE)
  }
}

es_version <- function(ver_check, fxn) {
  as.numeric(gsub("\\.", "", info()$version$number))
}
