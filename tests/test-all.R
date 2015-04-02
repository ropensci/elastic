library('testthat')
library('elastic')

shakespeare <- system.file("examples", "shakespeare_data.json", package = "elastic")
invisible(elastic::connect())
invisible(elastic::docs_bulk(shakespeare))

test_check('elastic')
