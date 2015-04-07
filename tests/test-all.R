library('testthat')
library('elastic')

docs_bulk_tests <- function(x, index = NULL, type = NULL, chunk_size = 1000, raw=FALSE, ...) {
  conn <- es_get_auth()
  url <- paste0(conn$base, ":", conn$port, '/_bulk')
  tt <- POST(url, body = upload_file(x, type = "application/json"), ..., encode = "json")
  if (tt$status_code > 202) {
    if (tt$status_code > 202) stop(content(tt)$error)
    if (content(tt)$status == "ERROR" | content(tt)$status == 500) stop(content(tt)$error_message)
  }
  res <- content(tt, as = "text")
  res <- structure(res, class = "bulk_make")
  if (raw) res else es_parse(res)
}

invisible(elastic::connect())
shakespeare <- system.file("examples", "shakespeare_data.json", package = "elastic")
invisible(docs_bulk_tests(shakespeare))
plos <- system.file("examples", "plos_data.json", package = "elastic")
invisible(docs_bulk_tests(plos))

test_check('elastic')
