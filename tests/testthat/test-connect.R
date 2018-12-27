context("connect")

test_that("connection works", {

  x <- connect()
  expect_is(x, "Elasticsearch")
  expect_equal(x$port, 9200)
})

test_that("connect fails as expected", {

  # setting options works via options() call
  options(es_port = 9200)
  expect_equal(getOption('es_port'), 9200)
  options(es_base = "fred")
  expect_equal(getOption('es_base'), "fred")
})
