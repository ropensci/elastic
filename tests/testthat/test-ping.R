context("ping")

invisible(connect())

test_that("ping", {
  expect_is(ping(), "list")
})

