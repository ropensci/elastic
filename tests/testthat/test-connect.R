context("connect")

test_that("connection works", {
  x <- connect(port = Sys.getenv("TEST_ES_PORT"))
  expect_is(x, "Elasticsearch")
  expect_equal(x$port, Sys.getenv("TEST_ES_PORT"))
})

test_that("ignore_version works as expected", {
  x <- connect(port = Sys.getenv("TEST_ES_PORT"), ignore_version=TRUE)
  expect_true(x$ignore_version)

  # ping skips the http request and returns message, returns NULL
  expect_message((z=x$ping()), "is set to TRUE")
  expect_null(z)

  # stop_es_version is skipped, returns NULL
  expect_null((z=x$stop_es_version(110, "cat_aliases")))

  # es_ver doesn't work
  expect_error(suppressMessages(x$es_ver()))
})

test_that("errors choice doesn't affect other client connections", {
  a <- connect(port = Sys.getenv("TEST_ES_PORT"), errors = "simple")
  b <- connect(port = Sys.getenv("TEST_ES_PORT"), errors = "complete")

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
