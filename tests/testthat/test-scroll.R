context("scroll")

x <- connect()

test_that("basic scroll works", {
  res <- Search(x, time_scroll = "1m")
  a <- scroll(x, res$`_scroll_id`)
  
  expect_is(res, "list")
  expect_equal(attr(res, "scroll"), "1m")
  expect_is(res$`_scroll_id`, "character")
  
  expect_is(vapply(a$hits$hits, "[[", 1, "_score"), "numeric")
  expect_equal(names(a$hits$hits[[1]]), 
               c('_index','_type','_id','_score','_source'))
})

test_that("scroll: on specific index", {
  res <- Search(x, index = 'shakespeare', q = "a*", time_scroll = "1m")
  a <- scroll(x, res$`_scroll_id`)
  
  expect_is(res, "list")
  expect_is(res$hits$hits, "list")
  expect_equal(attr(res, "scroll"), "1m")
  expect_is(res$`_scroll_id`, "character")
  expect_is(a, "list")
  expect_is(a$hits$hits, "list")
  expect_equal(attr(a, "scroll"), "1m")
  expect_is(a$`_scroll_id`, "character")
})

test_that("scroll: list input", {
  res <- Search(x, index = 'shakespeare', q = "a*", time_scroll = "1m")
  expect_is(scroll(x, res), "list")
})

test_that("scroll::list - scroll value is taken from list", {
  res <- Search(x, index = 'shakespeare', q = "a*", time_scroll = "1m")
  expect_is(scroll(x, res), "list")
})

test_that("scroll::list - force_scroll works as expected", {
  res <- Search(x, index = 'shakespeare', q = "a*", time_scroll = "1m")
  a <- scroll(x, res, time_scroll = "30s", force_scroll = TRUE)
  expect_equal(attr(a, "scroll"), "30s")
  
  b <- scroll(x, res, time_scroll = "30s")
  expect_equal(attr(b, "scroll"), "1m")
})

test_that("scroll - scroll parameter is gone", {
  expect_error(scroll(x, 'foobar', scroll = "1m"), 
    "The parameter `scroll` has been removed")
})

test_that("scroll fails well", {
  # types
  expect_error(scroll(x, 5), "no 'scroll\\(\\)' method for numeric")
  expect_error(scroll(x, matrix()), "no 'scroll\\(\\)' method for matrix")
  expect_error(scroll(x, mtcars), "no 'scroll\\(\\)' method for data.frame")
  
  # inputs
  expect_error(scroll(x, ), "argument \"x\" is missing")
  if (x$es_ver() >= 500) {
    expect_error(scroll(x, "asdf"), "Cannot parse scroll id")
  } else {
    if (x$es_ver() > 100) {
      expect_error(scroll(x, "asdf"), "Malformed scrollId")
    } else {
      expect_error(scroll(x, "asdf"), "ArrayIndexOutOfBoundsException")
    }
  }
  
  # skip if ES version < 2
  if (x$es_ver() >= 200) {
    if (x$es_ver() >= 620) {
      expect_error(
        Search(x, time_scroll = "1m", size = 0),
        "\\[size\\] cannot be \\[0\\] in a scroll context"
      )
    } else {
      tt <- Search(x, time_scroll = "1m", size = 0)
      expect_error(
        scroll(x, tt$`_scroll_id`, time_scroll = "5"),
        "parse setting \\[scroll\\] with value \\[5\\]"
      )
    }
  }
})
