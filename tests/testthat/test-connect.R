context("connect")

test_that("connection works", {
  x <- connect()
  expect_is(x, "Elasticsearch")
  expect_equal(x$port, 9200)
})

test_that("errors choice doesn't affect other client connections", {
  a <- connect(errors = "simple")
  b <- connect(errors = "complete")

  expect_is(a, "Elasticsearch")
  expect_is(b, "Elasticsearch")

  expect_equal(a$errors, "simple")
  expect_equal(b$errors, "complete")

  # the env var ELASTIC_RCLIENT_ERRORS is no longer found
  expect_equal(Sys.getenv("ELASTIC_RCLIENT_ERRORS"), "")
})

test_that("connect fails as expected", {
  # setting options works via options() call
  options(es_port = 9200)
  expect_equal(getOption('es_port'), 9200)
  options(es_base = "fred")
  expect_equal(getOption('es_base'), "fred")
})
