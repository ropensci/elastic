context("indices")

x <- connect(port = Sys.getenv("TEST_ES_PORT"), warn = FALSE)
load_shakespeare(x)

test_that("index_get", {
  if (!es_version(x) < 120) {
    # get index
    a <- index_get(x, index = 'shakespeare')
    # and delete any aliases
    if (length(a$shakespeare$aliases) > 0) {
      for (i in seq_along(a$shakespeare$aliases)) {
        alias_delete(x, index = "shakespeare", 
          alias = names(a$shakespeare$aliases)[i])
      }
    }
    # re-fetch index
    a <- index_get(x, index = 'shakespeare')
    expect_equal(names(a), "shakespeare")
    expect_is(a, "list")
    expect_is(a$shakespeare, "list")
    expect_equal(length(a$shakespeare$aliases), 0)
    expect_error(index_get(x, "adfadfadsfasdfadfasdfsf"), 
      'no such index||IndexMissingException')
  }
})

test_that("index_exists", {
  expect_true(index_exists(x, index = 'shakespeare'))
  expect_false(index_exists(x, index = 'asdfasdfadfasdfasfasdf'))
})

test_that("index_create", {
  ind <- "stuff_yy"
  invisible(tryCatch(index_delete(x, index = ind, verbose = FALSE), 
    error = function(e) e))
  a <- index_create(x, index = ind, verbose = FALSE)
  expect_true(a[[1]])
  if (gsub("\\.", "", x$ping()$version$number) >= 500) {
    if (gsub("\\.", "", x$ping()$version$number) >= 560) {
      expect_named(a, c("acknowledged", "shards_acknowledged", "index"))
    } else {
      expect_named(a, c("acknowledged", "shards_acknowledged"))
    }
  } else {
    expect_named(a, "acknowledged")
  }
  expect_is(a, "list")
  expect_error(index_create(x, "/"), "Invalid index name")
})

test_that("index_create fails on illegal characters", {
  expect_error(index_create(x, "a\\b"), "Invalid index name")
  expect_error(index_create(x, "a/b"), "Invalid index name")
  expect_error(index_create(x, "a*b"), "Invalid index name")
  expect_error(index_create(x, "a?b"), "Invalid index name")
  expect_error(index_create(x, "a\"b"), "Invalid index name")
  expect_error(index_create(x, "a<b"), "Invalid index name")
  expect_error(index_create(x, "a>b"), "Invalid index name")
  expect_error(index_create(x, "a|b"), "Invalid index name")
  expect_error(index_create(x, "a,b"), "Invalid index name")
  expect_error(index_create(x, "a b"), "Invalid index name")
})

test_that("index_delete", {
  nm <- "stuff_zz"
  invisible(tryCatch(index_delete(x, index = nm, verbose = FALSE), 
    error = function(e) e))
  a <- index_create(x, index = nm, verbose = FALSE)
  b <- index_delete(x, nm, verbose = FALSE)
  expect_true(b[[1]])
  expect_named(b, expected = "acknowledged")
  expect_is(b, "list")
  expect_error(index_delete(x, "adfadfafafasdfasdfasfasfasfd", verbose=FALSE), 
    "no such index||IndexMissingException")
})

test_that("index_stats", {
  a <- index_stats(x, 'shakespeare')
  expect_is(a, "list")
  expect_named(a$indices, "shakespeare")
  expect_error(index_stats(x, "adfadfafafasdfasdfasfasfasfd", verbose=FALSE), 
    "no such index||IndexMissingException")
})

test_that("index_segments", {
  a <- index_segments(x, 'shakespeare')
  expect_is(a, "list")
  expect_named(a$indices, "shakespeare")
  expect_error(index_segments(x, "adfadfafafasdfasdfasfasfasfd", verbose=FALSE), 
    "no such index||IndexMissingException")
})

test_that("index_recovery", {
  if (!es_version(x) < 110) {
    a <- index_recovery(x, 'shakespeare')
    expect_is(a, "list")
    expect_named(a$shakespeare, "shards")
    expect_error(index_recovery(x, "adfadfafafasdfasdfasfasfasfd", verbose=FALSE), 
      "no such index||IndexMissingException")
  }
})

test_that("index_analyze", {
  expect_warning(
    index_analyze(x, text = 'this is a test', analyzer='standard'),
    NA
  )
})

## cleanup -----------------------------------
invisible(index_delete(x, "stuff_yy", verbose = FALSE))
