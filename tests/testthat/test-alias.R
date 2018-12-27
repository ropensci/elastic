context("alias")

x <- connect()

test_that("alias_get works", {

  invisible(tryCatch(index_delete(x, "plos", verbose = FALSE), error = function(e) e))
  invisible(index_create(x, "plos", verbose = FALSE))
  invisible(alias_create(x, index = "plos", alias = "tables"))
  a <- alias_get(x, index="plos")
  b <- alias_get(x, alias="tables")
  expect_named(a, "plos")
  expect_is(a, "list")
  expect_is(a$plos, "list")
  expect_equal(length(a$plos$aliases$tables), 0)
})

test_that("aliases_get works", {

  c <- aliases_get(x)
  expect_is(c, "list")
  expect_is(c$plos, "list")
  expect_named(c$plos, "aliases")
  expect_null(c$adfafafadfasdf)
  expect_equal(alias_get(x), aliases_get(x))
})

test_that("alias_create works", {

  d <- invisible(alias_create(x, index = "plos", alias = "howdy"))
  expect_true(d$acknowledged)
})

test_that("alias_exists works", {

  expect_false(alias_exists(x, index = "fog"))
  
  invisible(tryCatch(index_delete(x, "fog", verbose = FALSE), error = function(e) e))
  invisible(index_create(x, "fog", verbose = FALSE))
  invisible(alias_create(x, index = "fog", alias = "tables"))
  expect_true(alias_exists(x, alias = "tables"))
})

test_that("alias_delete works", {
  invisible(tryCatch(index_delete(x, "fog", verbose = FALSE), error = function(e) e))
  invisible(index_create(x, "fog", verbose = FALSE))
  invisible(alias_create(x, index = "fog", alias = "chairs"))
  
  ff <- alias_delete(x, index = "fog", alias = "chairs")
  expect_is(ff, "list")
  expect_true(ff$acknowledged)
  expect_false(alias_exists(x, alias = "chairs"))
})

test_that("alias_* functions fail as expected", {

  expect_error(alias_get(x, index = "adfadf"), "no such index || IndexMissing")
  expect_error(alias_get(x, alias = "adfadfs"), "missing")
  expect_error(alias_create(x, "Adfafasd", "adfadf"))
})

# cleanup
index_delete(x, "fog")
