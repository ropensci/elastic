context("ping")

if (!identical(Sys.getenv("NOT_CRAN"), "true")) {
  invisible(connect())
}

test_that("ping", {
	skip_on_cran()

  expect_equal(ping()$status, 200)
  expect_is(ping(), "list")
})

