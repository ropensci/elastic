context("msearch")

invisible(connect())

test_that("basic multi-search works", {

  cat('{"index" : "shakespeare"}', file = "~/mysearch.json", sep = "\n")
  cat('{"query" : {"match_all" : {}}, "from" : 0, "size" : 5}',  sep = "\n",
      file = "~/mysearch.json", append = TRUE)
  aa <- msearch("~/mysearch.json")

  expect_is(aa, "list")
  expect_equal(length(aa), 1)
  expect_equal(length(aa$responses), 1)
  expect_is(aa$responses, "list")

  msearch1 <- system.file("examples", "msearch_eg1.json", package = "elastic")
  bb <- msearch(msearch1)

  msearch2 <- system.file("examples", "msearch_eg2.json", package = "elastic")
  cc <- msearch(msearch2)

  expect_is(bb, "list")
  expect_equal(length(bb$responses), 1)

  expect_is(cc, "list")
  expect_equal(length(cc$responses), 4)
})

test_that("multi-search fails well", {

  ## no index specified
  ff <- tempfile(fileext = ".json")
  cat('{"query" : {"match_all" : {}}, "from" : 0, "size" : 5}',  sep = "\n",
      file = ff, append = TRUE)
  expect_error(msearch(ff), "Validation Failed")

  ### same, but complete errors
  invisible(connect(errors = "complete"))
  expect_error(msearch(ff), "action_request_validation_exception||ActionRequestValidationException")

  ## same as above
  ff <- tempfile(fileext = ".json")
  cat('{}',  sep = "\n", file = ff, append = TRUE)
  expect_error(msearch(ff), "Validation Failed")

  ## file does not exist
  expect_error(msearch("asdf"), "file asdf does not exist")
})
