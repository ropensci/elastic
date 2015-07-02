context("mlt")

invisible(connect())

## create plos index first -----------------------------------
invisible(tryCatch(index_delete(index = "plos", verbose = FALSE), error = function(e) e))
plosdat <- system.file("examples", "plos_data.json", package = "elastic")
invisible(docs_bulk(plosdat))

test_that("mlt basic", {

  mlt1 <- mlt(index = "plos", type = "article", id = 5)$hits$total
  mlt2 <- mlt(index = "plos", type = "article", id = 5, min_doc_freq = 12)$hits$total
  mlt3 <- mlt(index = "plos", type = "article", id = 800)$hits$total

  expect_is(mlt1, "integer")
  expect_is(mlt2, "integer")
  expect_is(mlt3, "integer")

  expect_equal(mlt1, 58)

  expect_is(mlt(index = "plos", type = "article", id = 5), "list")
  expect_error(mlt(index = "plos", type = "article", id = 343424234), "document missing")
})

test_that("Return different number of results", {

  mlt4 <- mlt(index = "plos", type = "article", id = 800, search_size = 1)$hits
  mlt5 <- mlt(index = "plos", type = "article", id = 800, search_size = 2)$hits

  expect_is(mlt4, "list")
  expect_is(mlt4$total, "integer")
  expect_is(mlt5$total, "integer")

  expect_equal(mlt4$total, 884)

  expect_equal(length(mlt4$hits), 1)
  expect_equal(length(mlt5$hits), 2)
})

test_that("Exclude stop words", {

  mlt6 <- mlt(index = "plos", type = "article", id = 800)$hits
  mlt7 <- mlt(index = "plos", type = "article", id = 800, stop_words = "the,and")$hits

  expect_is(mlt6, "list")
  expect_is(mlt7, "list")

  expect_equal(mlt6$total, 884)
})

test_that("Maximum query terms to be included in the generated query", {

  mlt8 <- mlt(index = "plos", type = "article", id = 800, max_query_terms = 1)$hits$total
  mlt9 <- mlt(index = "plos", type = "article", id = 800, max_query_terms = 2)$hits$total
  mlt10 <- mlt(index = "plos", type = "article", id = 800, max_query_terms = 3)$hits$total

  expect_is(mlt8, "integer")
  expect_is(mlt9, "integer")
  expect_is(mlt10, "integer")

  expect_true(mlt8 < mlt9)
  expect_true(mlt8 < mlt10)
  expect_true(mlt9 < mlt10)
})

# cleanup -----------
invisible(index_delete("plos", verbose = FALSE))
