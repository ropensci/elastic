context("mlt")

invisible(connect())

## get data in --------------------
plosdat <- system.file("examples", "plos_data.json", package = "elastic")
invisible(tryCatch(index_delete(index = "plos", verbose = FALSE), error = function(e) e))
invisible(docs_bulk(plosdat))

test_that("mlt works", {
  b1 <- mlt(index = "plos", type = "article", id = 5, min_doc_freq=12)
  # b2 <- mlt(index = "plos", type = "article", id = 5, min_doc_freq=5)
  c1 <- mlt(index = "plos", type = "article", id = 800, search_size=1)
  c2 <- mlt(index = "plos", type = "article", id = 800, search_size=2)
  d <- mlt(index = "plos", type = "article", id = 800, stop_words="the,and")
  e <- mlt(index = "plos", type = "article", id = 800, percent_terms_to_match=0.7)
  f1 <- mlt(index = "plos", type = "article", id = 800, max_query_terms=3)
  f2 <- mlt(index = "plos", type = "article", id = 800, max_query_terms=1)
  
  expect_is(b1, "list")
  expect_is(c1, "list")
  expect_is(c2, "list")
  expect_is(d, "list")
  expect_is(e, "list")
  expect_is(f1, "list")
  expect_is(f2, "list")
  
  # expect_less_than(b1$hits$total, b2$hits$total)
  
  # expect_equal(length(c1$hits$hits), 1)
  # expect_equal(length(c2$hits$hits), 2)
  
  expect_is(d, "list")
  expect_is(d$hits$hits, "list")
  
  expect_is(e, "list")
  expect_is(e$hits$hits, "list")
  
  expect_is(f1, "list")
  expect_is(f2$hits$hits, "list")
  # expect_less_than(f2$hits$total, f1$hits$total)
})

test_that("mlt fails correctly", {
  expect_error(mlt(), "argument \"index\" is missing, with no default")
  expect_error(mlt(index = "plos", type = "article", id = 5, min_doc_freq="Adfad"), 
               "min_doc_freq should be a numeric or integer")
  expect_error(mlt(index = "plos", type = "article", id = 5, search_size="adf"), 
               "search_size should be a numeric or integer")
  expect_error(mlt(index = "plos", type = "article", id = 5, max_query_terms="adf"), 
               "max_query_terms should be a numeric or integer")
  expect_error(mlt(index = "plos", type = "article", id = 5, percent_terms_to_match="adf"), 
               "percent_terms_to_match should be a numeric or integer")
  expect_error(mlt(index = "plos", type = "article", id = 5, max_word_length="adf"), 
               "max_word_length should be a numeric or integer")
})
