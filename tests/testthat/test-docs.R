context("docs")

invisible(connect())

## create indices first -----------------------------------
ind <- "stuff_l"
invisible(tryCatch(index_delete(index = ind, verbose = FALSE), error = function(e) e))
invisible(index_create(index = ind, verbose = FALSE))

test_that("docs_create works", {

  invisible(docs_create(index = ind, type = 'article', id = 1002, body = list(id = "12345", title = "New title")))
  a <- docs_get(index = ind, type = 'article', id = 1002, verbose = FALSE)
  expect_is(a, "list")
  expect_is(a$`_source`, "list")
  expect_equal(a$`_id`, "1002")
  expect_equal(a$`_source`$id[[1]], "12345")
  expect_equal(length(a), 6)

  # can create docs with an index that doesn't exist yet, should create index on the fly
  b <- docs_create("bbbbbbb", "stuff", 1, list(a = 5))
  expect_true(index_exists("bbbbbbb"))
})

test_that("docs_create fails as expected", {

  expect_error(docs_create("adfadf"), "argument \"type\" is missing, with no default")
  expect_error(docs_create("adfadf", "asdfadf"), "argument \"id\" is missing, with no default")
  expect_error(docs_create("adfadf", "asdfadf", 1), "argument \"body\" is missing, with no default")

  expect_error(docs_get("bbbbbbb"), "argument \"type\" is missing, with no default")
  expect_error(docs_get("bbbbbbb", "stuff"), "argument \"id\" is missing, with no default")
  expect_error(docs_get("bbbbbbb", "stuff", 1, source = "adf"), "argument is not interpretable as logical")
})

## create indices first
ind2 <- "stuff_f"
invisible(tryCatch(index_delete(index = ind2, verbose = FALSE), error = function(e) e))
invisible(index_create(index = ind2, verbose = FALSE))

test_that("docs_get works", {

  invisible(docs_create(index = ind2, type = "things", id = 45, body = '{"hello": "world"}'))
  c <- docs_get(index = ind2, type = "things", id = 45, verbose = FALSE)
  expect_is(c, "list")
  expect_is(c$`_source`, "list")
  expect_true(c$found)
  expect_equal(c$`_id`, "45")

  # If field doesn't exist no source returned
  d <- docs_get("bbbbbbb", "stuff", 1, fields = "b", verbose = FALSE)
  expect_null(d$`_source`)
  expect_null(d$fields)
})


## create indices first
ind3 <- "stuff_t"
invisible(tryCatch(index_delete(index = ind3, verbose = FALSE), error = function(e) e))
invisible(index_create(index = ind3, verbose = FALSE))

test_that("docs_mget works", {

  invisible(docs_create(index = ind3, type = "holla", id = 1, body = '{"hello": "world"}'))
  invisible(docs_create(index = ind3, type = "holla", id = 2, body = '{"foo": "bar"}'))
  invisible(docs_create(index = ind3, type = "holla", id = 3, body = '{"tables": "chairs"}'))
  e <- docs_mget(index = ind3, type = "holla", ids = 1:3, verbose = FALSE)
  expect_is(e, "list")
  expect_named(e, "docs")
  expect_is(e$docs, "list")
  expect_true(e$docs[[1]]$found)
  expect_equal(vapply(e$docs, "[[", "", "_id"), c("1", "2", "3"))
})

test_that("docs_delete works", {

  f <- docs_delete(index = ind3, type = "holla", id = 3)
  expect_is(f, "list")
  expect_true(f$found)
  # error if try again to delete since document is gone
  expect_error(docs_delete(index = ind3, type = "holla", id = 3), "Not Found")
})

## cleanup -----------------------------------
invisible(index_delete(ind, verbose = FALSE))
invisible(index_delete(ind2, verbose = FALSE))
invisible(index_delete(ind3, verbose = FALSE))
