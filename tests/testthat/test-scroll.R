context("scroll")

invisible(connect())

test_that("basic scroll works", {

  a <- Search(index="shakespeare")
  expect_equal(names(a), c('took','timed_out','_shards','hits'))
  expect_is(a, "list")
  expect_is(a$hits$hits, "list")
  expect_equal(names(a$hits$hits[[1]]), c('_index','_type','_id','_score','_source'))
})

test_that("allowed status codes work as expected", {

  a <- Search(index="shakespeare")
  expect_equal(names(a), c('took','timed_out','_shards','hits'))
  expect_is(a, "list")
  expect_is(a$hits$hits, "list")
  expect_equal(names(a$hits$hits[[1]]), c('_index','_type','_id','_score','_source'))
})

test_that("scroll fails as expected", {
  # expect_error(Search(index="shakespeare", terminate_after="Afd"), "terminate_after should be a numeric")
})
