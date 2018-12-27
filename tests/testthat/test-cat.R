context("cat")

x <- connect()

shakespeare <- system.file("examples", "shakespeare_data.json", package = "elastic")
if (!index_exists(x, 'shakespeare')) invisible(elastic::docs_bulk(x, shakespeare))

test_that("cat_", {
  if (!es_version(x) < 110) {
    a <- cat_(x, parse = TRUE)
    expect_is(a, "data.frame")
    expect_is(a$V1, "character")
    expect_gt(length(a$V1), 10)
    expect_is(capture.output(cat_(x)), "character")
  }
})

test_that("cat_indices", {
  if (!es_version(x) < 110) {
    b <- cat_indices(x, index = 'shakespeare', parse = TRUE, verbose = TRUE)
    c <- cat_indices(x, index = 'shakespeare', parse = TRUE, bytes = TRUE, verbose = TRUE)
    expect_is(b, "data.frame")
    expect_named(b)
    
    expect_is(b$store.size, "character")
    expect_is(c$store.size, "integer")
    
    if (es_version(x) < 120) {
      expect_message(cat_indices(x, index = "adf"), "Nothing to print")
    } else {
      expect_error(cat_indices(x, index = "adf"), "no such index||IndexMissing")
    }
    expect_error(cat_indices(x, bytes = "adfad"), "is not TRUE")
  }
})
