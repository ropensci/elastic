library('testthat')
library('elastic')

invisible(elastic::connect())

shakespeare <- system.file("examples", "shakespeare_data.json", package = "elastic")
invisible(elastic::docs_bulk(shakespeare))

plos <- system.file("examples", "plos_data.json", package = "elastic")
invisible(elastic::docs_bulk(plos))

omdb <- system.file("examples", "omdb.json", package = "elastic")
invisible(elastic::docs_bulk(omdb))

test_check('elastic')
