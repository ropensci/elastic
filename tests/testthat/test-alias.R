context("alias")

if (!identical(Sys.getenv("NOT_CRAN"), "true")) {
  invisible(connect())
}

test_that("alias_get works", {
  skip_on_cran()

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
  skip_on_cran()

  c <- aliases_get()
  expect_is(c, "list")
  expect_is(c$plos, "list")
  expect_named(c$plos, "aliases")
  expect_null(c$adfafafadfasdf)
  expect_equal(alias_get(), aliases_get())
})

test_that("alias_create works", {
  skip_on_cran()

  d <- invisible(alias_create(index = "plos", alias = "howdy"))
  expect_true(d$acknowledged)
})

test_that("alias_exists works", {
  skip_on_cran()

  expect_false(alias_exists(index = "plos"))
  expect_true(alias_exists(alias = "tables"))
})

test_that("alias_delete works", {
  skip_on_cran()

  ff <- alias_delete(index = "plos", alias = "tables")
  expect_is(ff, "list")
  expect_true(ff$acknowledged)
  expect_false(alias_exists(alias = "tables"))
})

test_that("alias_* functions fail as expected", {
  skip_on_cran()

  expect_error(alias_get("adfadf"), "missing")
  expect_error(alias_get(alias = "adfadfs"), "missing")
  expect_error(alias_create("Adfafasd", "adfadf"))
})
