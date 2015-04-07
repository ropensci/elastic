library('testthat')
library('elastic')

docs_bulk_tests <- function(x, index = NULL, type = NULL, chunk_size = 1000, raw=FALSE, ...) {
  conn <- elastic::es_get_auth()
  url <- paste0(conn$base, ":", conn$port, '/_bulk')
  tt <- httr::POST(url, body = httr::upload_file(x, type = "application/json"), ..., encode = "json")
  if (tt$status_code > 202) {
    if (tt$status_code > 202) stop(httr::content(tt)$error)
    if (httr::content(tt)$status == "ERROR" | httr::content(tt)$status == 500) stop(httr::content(tt)$error_message)
  }
  res <- httr::content(tt, as = "text")
  res <- structure(res, class = "bulk_make")
  if (raw) res else elastic::es_parse(res)
}

invisible(elastic::connect())
shakespeare <- system.file("examples", "shakespeare_data.json", package = "elastic")
invisible(docs_bulk_tests(shakespeare))
plos <- system.file("examples", "plos_data.json", package = "elastic")
invisible(docs_bulk_tests(plos))

test_check('elastic')
