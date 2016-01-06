context("indices")

invisible(connect())

test_that("index_get", {
  if (!es_version() < 120) {
    a <- index_get(index = 'shakespeare')
    expect_equal(names(a), "shakespeare")
    expect_is(a, "list")
    expect_is(a$shakespeare, "list")
    expect_equal(length(a$shakespeare$aliases), 0)
    expect_error(index_get("adfadfadsfasdfadfasdfsf"), 'no such index||IndexMissingException')
  }
})

test_that("index_exists", {
  expect_true(index_exists(index = 'shakespeare'))
  expect_false(index_exists(index = 'asdfasdfadfasdfasfasdf'))
})

test_that("index_create", {
  ind <- "stuff_yy"
  invisible(tryCatch(index_delete(index = ind, verbose = FALSE), error = function(e) e))
  a <- index_create(index = ind, verbose = FALSE)
  expect_true(a[[1]])
  expect_named(a, expected = "acknowledged")
  expect_is(a, "list")
  expect_error(index_create("/"), "Invalid index name")
})

test_that("index_delete", {
  nm <- "stuff_zz"
  invisible(tryCatch(index_delete(index = nm, verbose = FALSE), error = function(e) e))
  a <- index_create(index = nm, verbose = FALSE)
  b <- index_delete(nm, verbose = FALSE)
  expect_true(b[[1]])
  expect_named(b, expected = "acknowledged")
  expect_is(b, "list")
  expect_error(index_delete("adfadfafafasdfasdfasfasfasfd", verbose=FALSE), "no such index||IndexMissingException")
})

# test_that("index_close, index_open", {
#   invisible(tryCatch(index_delete('test_close_open', verbose = FALSE), error = function(e) e))
#   index_create('test_close_open', verbose = FALSE)
#   index_open('test_close_open')
#
#   expect_true(index_close('test_close_open')[[1]])
#   expect_true(index_open('test_close_open')[[1]])
#   expect_error(index_close("adfadfafafasdfasdfasfasfasfd"), "Not Found")
#   expect_error(index_open("adfadfafafasdfasdfasfasfasfd"), "Not Found")
# })

test_that("index_stats", {
  a <- index_stats('shakespeare')
  expect_is(a, "list")
  expect_named(a$indices, "shakespeare")
  expect_error(index_stats("adfadfafafasdfasdfasfasfasfd", verbose=FALSE), "no such index||IndexMissingException")
})

test_that("index_segments", {
  a <- index_segments('shakespeare')
  expect_is(a, "list")
  expect_named(a$indices, "shakespeare")
  expect_error(index_segments("adfadfafafasdfasdfasfasfasfd", verbose=FALSE), "no such index||IndexMissingException")
})

test_that("index_recovery", {
  if (!es_version() < 110) {
    a <- index_recovery('shakespeare')
    expect_is(a, "list")
    expect_named(a$shakespeare, "shards")
    expect_error(index_recovery("adfadfafafasdfasdfasfasfasfd", verbose=FALSE), "no such index||IndexMissingException")
  }
})

## cleanup -----------------------------------
invisible(index_delete("stuff_yy", verbose = FALSE))
# invisible(index_delete('test_close_open', verbose = FALSE))
