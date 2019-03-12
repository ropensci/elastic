context("type_remover")

test_that("type_remover", {
  z <- system.file("examples/omdb.json", package = "elastic")
  a <- readLines(z, 6)
  ff <- type_remover(z)
  b <- readLines(ff, 6)

  expect_is(a, "character")
  invisible(lapply(a[c(1, 3, 5)], expect_match, regexp = "_type"))

  expect_is(b, "character")
  invisible(lapply(b[c(1, 3, 5)], function(z) expect_false(grepl("_type", z))))

  # cleanup
  unlink(ff)
})

