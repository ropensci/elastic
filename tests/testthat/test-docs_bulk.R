context("docs_bulk")

invisible(connect())

test_that("docs_bulk - works with bulk format file", {
  # remove index if it exists
  if (index_exists("gbifnewgeo")) {
    index_delete("gbifnewgeo")
  }
  # file
  gsmall <- system.file("examples", "gbif_geosmall.json", package = "elastic")
  # load bulk
  a <- docs_bulk(x = gsmall)
  
  expect_is(a, "list")
  expect_named(a, c('took', 'errors', 'items'))
  expect_equal(length(a$items), 2)
  expect_equal(a$items[[1]]$index$`_index`, "gbifnewgeo")
})

test_that("docs_bulk - works with data.frame input", {
  # remove index if it exists
  if (index_exists("hello")) {
    index_delete("hello")
  }
  # load bulk
  iris <- stats::setNames(iris, gsub("\\.", "_", names(iris)))
  a <- docs_bulk(iris[3:NROW(iris),], index = "hello", type = "world")
  
  expect_is(a, "list")
  expect_equal(length(a), 1)
  expect_named(a[[1]], c('took', 'errors', 'items'))
  expect_equal(length(a[[1]]$items), NROW(iris[3:NROW(iris),]))
  if (gsub("\\.", "", ping()$version$number) >= 500) {
    expect_equal(a[[1]]$items[[1]]$index$`_index`, "hello")
  } else {
    expect_equal(a[[1]]$items[[1]]$create$`_index`, "hello")
  }
})

test_that("docs_bulk - works with list input", {
  # remove index if it exists
  if (index_exists("arrests")) {
    index_delete("arrests")
  }
  # load bulk
  a <- docs_bulk(apply(USArrests, 1, as.list), index = "arrests")
  
  expect_is(a, "list")
  expect_equal(length(a), 1)
  expect_named(a[[1]], c('took', 'errors', 'items'))
  expect_equal(length(a[[1]]$items), 50)
  
  if (gsub("\\.", "", ping()$version$number) >= 500) {
    expect_equal(a[[1]]$items[[1]]$index$`_index`, "arrests")
  } else {
    expect_equal(a[[1]]$items[[1]]$create$`_index`, "arrests")
  }
})

test_that("docs_bulk fails as expected", {
  # certain classes not supported
  expect_error(docs_bulk(5), "no 'docs_bulk' method for class numeric")
  expect_error(docs_bulk(matrix(1)), "no 'docs_bulk' method for class matrix")
  expect_error(docs_bulk(TRUE), "no 'docs_bulk' method for class logical")
  
  # character string has to be a file that exists on disk
  expect_error(docs_bulk("adfadf"), "file.exists\\(x\\) is not TRUE")
})
