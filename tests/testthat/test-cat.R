context("cat")

invisible(tryCatch(elastic::connect(), error = function(e) e))

test_that("cat_", {
  skip_on_cran()

  a <- cat_(parse = TRUE)
  expect_is(a, "data.frame")
  expect_is(a$V1, "character")
  expect_equal(length(a$V1), 22)
  expect_is(capture.output(cat_()), "character")
  expect_error(cat_(verbose = "adf"), "is not TRUE")
})

test_that("cat_indices", {
  skip_on_cran()

  b <- cat_indices(index = 'shakespeare', parse = TRUE, verbose = TRUE)
  c <- cat_indices(index = 'shakespeare', parse = TRUE, bytes = TRUE, verbose = TRUE)
  expect_is(b, "data.frame")
  expect_named(b)

  expect_is(b$store.size, "character")
  expect_is(c$store.size, "integer")

  expect_error(cat_indices(index = "adf"), "missing")
  expect_error(cat_indices(bytes = "adfad"), "is not TRUE")
})

test_that("cat_master", {
  skip_on_cran()

  d <- cat_master(parse = TRUE, verbose = TRUE)
  expect_is(d, "data.frame")
  expect_named(d)

  expect_is(d$host, "character")

  expect_error(cat_master(help = "Adf"), "is not TRUE")
})
