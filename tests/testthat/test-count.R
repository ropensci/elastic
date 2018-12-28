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
  
  if (es_version(x) > 246) {
    expect_equal(suppressWarnings(count(x, type = "adfad")), 0)
  } else {
    expect_error(count(x, type = "adfad"), 
      "no such index||IndexMissingException")
  }

  if (es_version(x) >= 700) {
    expect_warning(count(x, 'shakespeare', type = "line"), 
      "Specifying types in count requests is deprecated")
  }
})
