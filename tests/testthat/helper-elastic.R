stop_es_version <- function(ver_check, fxn) {
  ver <- as.numeric(gsub("\\.", "", connection()$es_deets$version$number))
  if (ver < ver_check) {
    stop(fxn, " is not available for this Elasticsearch version", call. = FALSE)
  }
}

es_version <- function(ver_check, fxn) {
  as.numeric(gsub("\\.", "", connection()$es_deets$version$number))
}
