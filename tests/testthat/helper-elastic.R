stop_es_version <- function(conn, ver_check, fxn) {
  ver <- es_version(conn)
  if (ver < ver_check) {
    stop(fxn, " is not available for this Elasticsearch version",
      call. = FALSE)
  }
}

es_version <- function(conn, ver_check, fxn) {
  xx <- conn$info()$version$number
  xx <- gsub("[A-Za-z]", "", xx)
  as.numeric(gsub("\\.|-", "", xx))
}

load_shakespeare <- function(conn) {
  if (conn$es_ver() < 600) {
    shakespeare <- system.file("examples", "shakespeare_data.json",
      package = "elastic")
  } else {
    shakespeare <- system.file("examples", "shakespeare_data_.json",
      package = "elastic")
  }
  if (!index_exists(conn, 'shakespeare'))
    invisible(elastic::docs_bulk(conn, shakespeare))
}

load_omdb <- function(conn) {
  omdb <- system.file("examples", "omdb.json", package = "elastic")
  if (!index_exists(conn, 'omdb'))
    invisible(elastic::docs_bulk(conn, omdb))
}
