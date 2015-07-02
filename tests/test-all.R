library('testthat')
library('elastic')

res = tryCatch(elastic::connect(), error = function(e) e)
if (!is(res, "simpleError")) {
	shakespeare <- system.file("examples", "shakespeare_data.json", package = "elastic")
	invisible(elastic::docs_bulk(shakespeare))
}

test_check('elastic')
