context("connect")

test_that("connection works", {
	skip_on_cran()

  connect("http://127.0.0.1", 9200)
  con <- connection()
  expect_is(con, "es_conn")
  expect_equal(con$port, 9200)
})

test_that("connect fails as expected", {
	skip_on_cran()

  # setting options works via options() call
  options(es_port = 9200)
  expect_equal(getOption('es_port'), 9200)
  options(es_base = "fred")
  expect_equal(getOption('es_base'), "fred")
})
