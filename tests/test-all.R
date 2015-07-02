library('testthat')
library('elastic')

if (!identical(Sys.getenv("NOT_CRAN"), "true")) {
  invisible(elastic::connect())
  shakespeare <- system.file("examples", "shakespeare_data.json", package = "elastic")
  invisible(elastic::docs_bulk(shakespeare))
}

test_check('elastic')
