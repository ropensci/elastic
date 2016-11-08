context("docs_bulk_prep")

test_that("docs_bulk_prep - works with data.frame input", {
  ff <- tempfile(fileext = ".json")
  a <- docs_bulk_prep(mtcars, index = "hello", type = "world", path = ff)
  a_res <- readLines(ff)
  
  expect_is(a, "character")
  expect_equal(length(a), 1)
  expect_match(a, "json")
  expect_gt(length(a_res), 50)
  expect_match(a_res[1], "hello")
  expect_match(a_res[2], "disp")
})

test_that("docs_bulk_prep - works with list input", {
  ff <- tempfile(fileext = ".json")
  a <- docs_bulk_prep(apply(iris, 1, as.list), index="iris", type="flowers", path = ff)
  a_res <- readLines(ff)
  
  expect_is(a, "character")
  expect_equal(length(a), 1)
  expect_match(a, "json")
  expect_gt(length(a_res), 200)
  expect_match(a_res[1], "iris")
  expect_match(a_res[2], "Sepal")
})

test_that("docs_bulk_prep - chunks gives many file paths, with indexed suffix", {
  ff <- tempfile(fileext = ".json")
  bigiris <- do.call("rbind", replicate(30, iris, FALSE))
  a <- docs_bulk_prep(bigiris, index = "big", path = ff)
  a_res <- readLines(a[1])
  
  indices <- as.numeric(vapply(a, function(x) {
    tmp <- strsplit(x, "", split = "\\.json")[[1]][1]
    substring(tmp, nchar(tmp), nchar(tmp))
  }, ""))
  
  expect_is(a, "character")
  expect_equal(length(a), 5)
  expect_match(a, "json")
  
  expect_equal(indices, 1:5)
  
  expect_equal(length(a_res), 2000)
  expect_match(a_res[1], "big")
  expect_match(a_res[2], "Petal")
})

test_that("docs_bulk_prep fails as expected", {
  expect_error(docs_bulk_prep(5), "no 'docs_bulk_prep' method for class numeric")
  expect_error(docs_bulk_prep(matrix(1)), "no 'docs_bulk_prep' method for class matrix")
  expect_error(docs_bulk_prep(TRUE), "no 'docs_bulk_prep' method for class logical")
  expect_error(docs_bulk_prep("adfadf"), "no 'docs_bulk_prep' method for class character")
})
