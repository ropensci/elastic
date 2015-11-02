context("ping")

invisible(connect())

test_that("ping", {
  expect_equal(ping()$cluster_name, "elasticsearch")
  expect_is(ping(), "list")
})

