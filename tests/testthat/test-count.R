context("count")

x <- connect()

test_that("count", {
  a <- count(x)
  b <- count(x, index = 'shakespeare')
  c <- count(x, index = 'shakespeare', q = "a*")
  d <- count(x, index = 'shakespeare', q = "z*")

  expect_is(a, "integer")
  expect_is(b, "integer")
  expect_is(c, "integer")
  expect_is(d, "integer")

  expect_gt(b, 10)

  expect_error(count(x, "adfadf"), "no such index||IndexMissing")
  expect_equal(count(x, type = "adfad"), 0)
})
