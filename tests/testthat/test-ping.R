context("ping")

invisible(connect())

test_that("ping", {
  expect_equal(ping()$status, 200)
  expect_is(ping(), "list")
})

