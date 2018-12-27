context("ping")

x <- connect()

test_that("ping", {
  expect_is(x$ping(), "list")
})

