context("msearch")

x <- connect()

test_that("basic multi-search works", {
  tf <- tempfile(fileext = ".json")
  cat('{"index" : "shakespeare"}', file = tf, sep = "\n")
  cat('{"query" : {"match_all" : {}}, "from" : 0, "size" : 5}',  sep = "\n",
      file = tf, append = TRUE)
  aa <- msearch(x, tf)

  expect_is(aa, "list")
  expect_equal(length(aa), 1)
  expect_equal(length(aa$responses), 1)
  expect_is(aa$responses, "list")

  msearch1 <- system.file("examples", "msearch_eg1.json", package = "elastic")
  bb <- msearch(x, msearch1)

  msearch2 <- system.file("examples", "msearch_eg2.json", package = "elastic")
  cc <- msearch(x, msearch2)

  expect_is(bb, "list")
  expect_equal(length(bb$responses), 1)

  expect_is(cc, "list")
  expect_equal(length(cc$responses), 3)
})

test_that("multi-search fails well", {

  ## no index specified
  ff <- tempfile(fileext = ".json")
  cat('{"query" : {"match_all" : {}}, "from" : 0, "size" : 5}',  sep = "\n",
      file = ff, append = TRUE)
  expect_error(msearch(x, ff), "Validation Failed")

  ### same, but complete errors
  x <- connect(errors = "complete")
  expect_error(msearch(x, ff), 
    "action_request_validation_exception||ActionRequestValidationException")

  ## same as above
  ff <- tempfile(fileext = ".json")
  cat('{}',  sep = "\n", file = ff, append = TRUE)
  expect_error(msearch(x, ff), "Validation Failed")

  ## file does not exist
  expect_error(msearch(x, "asdf"), "file asdf does not exist")
})
