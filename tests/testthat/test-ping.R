context("ping")

invisible(tryCatch(elastic::connect(), error = function(e) e))

test_that("ping", {
	skip_on_cran()

  expect_equal(ping()$status, 200)
  expect_is(ping(), "list")
})

