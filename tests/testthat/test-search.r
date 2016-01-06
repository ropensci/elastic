context("search")

invisible(connect())

test_that("basic search works", {

  a <- Search(index="shakespeare")
  expect_equal(names(a), c('took','timed_out','_shards','hits'))
  expect_is(a, "list")
  expect_is(a$hits$hits, "list")
  expect_equal(names(a$hits$hits[[1]]), c('_index','_type','_id','_score','_source'))
})

test_that("search for document type works", {

  b <- Search(index="shakespeare", type="line")
  expect_match(vapply(b$hits$hits, "[[", "", "_type"), "line")
})

test_that("search for specific fields works", {

  c <- Search(index="shakespeare", fields=c('play_name','speaker'))
  expect_equal(sort(unique(lapply(c$hits$hits, function(x) names(x$fields)))[[1]]), c('play_name','speaker'))
})

test_that("search paging works", {

  d <- Search(index="shakespeare", size=1, fields='text_entry')$hits$hits
  expect_equal(length(d), 1)
})

test_that("search terminate_after parameter works", {

  e <- Search(index="shakespeare", terminate_after=1)
  expect_is(e, "list")
})

test_that("getting json data back from search works", {

  suppressMessages(require('jsonlite'))
  f <- Search(index="shakespeare", type="scene", raw=TRUE)
  expect_is(f, "character")
  expect_true(jsonlite::validate(f))
  expect_is(jsonlite::fromJSON(f), "list")
})

test_that("Search fails as expected", {

  aggs <- list(aggs = list(stats = list(stfff = list(field = "text_entry"))))
  expect_error(Search(index = "shakespeare", body = aggs), "all shards failed")

  expect_error(Search(index = "shakespeare", type = "act", sort = "text_entryasasfd"), "all shards failed")

  expect_error(Search(index = "shakespeare", size = "adf"), "size should be a numeric or integer class value")

  expect_error(Search(index = "shakespeare", from = "asdf"), "from should be a numeric or integer class value")

  expect_error(Search(index="shakespeare", q="~text_entry:ma~"), "all shards failed")

  expect_error(Search(index="shakespeare", q="line_id:[10 TO x]"), "all shards failed||SearchPhaseExecutionException")

  expect_error(Search(index="shakespeare", terminate_after="Afd"), "terminate_after should be a numeric")
})
