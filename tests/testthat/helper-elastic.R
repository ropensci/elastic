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
  } else if (conn$es_ver() >= 700) {
    shakespeare <- system.file("examples", "shakespeare_data_notypes.json",
      package = "elastic")
  } else {
    shakespeare <- system.file("examples", "shakespeare_data_.json",
      package = "elastic")
  }
  if (index_exists(conn, 'shakespeare')) index_delete(conn, 'shakespeare')
  invisible(suppressWarnings(elastic::docs_bulk(conn, shakespeare)))
}

load_plos <- function(conn) {
  if (conn$es_ver() >= 700) {
    plos <- system.file("examples", "plos_data_notypes.json",
      package = "elastic")
  } else {
    plos <- system.file("examples", "plos_data.json",
      package = "elastic")
  }
  if (index_exists(conn, 'plos')) index_delete(conn, 'plos')
  invisible(suppressWarnings(elastic::docs_bulk(conn, plos)))
}

load_omdb <- function(conn) {
  omdb <- system.file("examples", "omdb.json", package = "elastic")
  if (!index_exists(conn, 'omdb'))
    invisible(suppressWarnings(elastic::docs_bulk(conn, omdb)))
}
