library('testthat')
library('elastic')

x <- elastic::connect()
try_conn <- tryCatch(x$ping(), error = function(e) e)
if (inherits(try_conn, "error")) {
  cat("Elasticsearch not available, skipping tests")
} else {
  if (x$es_ver() < 600) {
    shakespeare <- system.file("examples", "shakespeare_data.json", package = "elastic")
  } else {
    shakespeare <- system.file("examples", "shakespeare_data_.json", package = "elastic")
  }
  invisible(elastic::docs_bulk(x, shakespeare))

  plos <- system.file("examples", "plos_data.json", package = "elastic")
  invisible(elastic::docs_bulk(x, plos))

  omdb <- system.file("examples", "omdb.json", package = "elastic")
  invisible(elastic::docs_bulk(x, omdb))

  test_check('elastic')  
}
