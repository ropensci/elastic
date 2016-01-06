context("alias")

invisible(connect())

test_that("alias_get works", {

  invisible(tryCatch(index_delete("plos", verbose = FALSE), error = function(e) e))
  invisible(index_create("plos", verbose = FALSE))
  invisible(alias_create(index = "plos", alias = "tables"))
  a <- alias_get(index="plos")
  b <- alias_get(alias="tables")
  expect_named(a, "plos")
  expect_is(a, "list")
  expect_is(a$plos, "list")
  expect_equal(length(a$plos$aliases$tables), 0)
})

test_that("aliases_get works", {

  c <- aliases_get()
  expect_is(c, "list")
  expect_is(c$plos, "list")
  expect_named(c$plos, "aliases")
  expect_null(c$adfafafadfasdf)
  expect_equal(alias_get(), aliases_get())
})

test_that("alias_create works", {

  d <- invisible(alias_create(index = "plos", alias = "howdy"))
  expect_true(d$acknowledged)
})

test_that("alias_exists works", {

  expect_false(alias_exists(index = "plos"))
  expect_true(alias_exists(alias = "tables"))
})

test_that("alias_delete works", {

  ff <- alias_delete(index = "plos", alias = "tables")
  expect_is(ff, "list")
  expect_true(ff$acknowledged)
  expect_false(alias_exists(alias = "tables"))
})

test_that("alias_* functions fail as expected", {

  expect_error(alias_get(index = "adfadf"), "no such index || IndexMissing")
  expect_error(alias_get(alias = "adfadfs"), "missing")
  expect_error(alias_create("Adfafasd", "adfadf"))
})
