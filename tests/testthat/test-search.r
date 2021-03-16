context("search")

x <- connect(port = Sys.getenv("TEST_ES_PORT"), warn = FALSE)
z <- connect(port = Sys.getenv("TEST_ES_PORT"), warn = TRUE)
load_shakespeare(x)
load_shakespeare(z)
Sys.sleep(2) # wait for data to be available

test_that("basic search works", {

  a <- Search(x, index="shakespeare")
  expect_equal(names(a), c('took','timed_out','_shards','hits'))
  expect_is(a, "list")
  expect_is(a$hits$hits, "list")
  if (x$es_ver() >= 700) {
    expect_is(a$hits$total, "list")
  } else {
    expect_type(a$hits$total, "integer")
  }
  expect_equal(names(a$hits$hits[[1]]),
    c('_index','_type','_id','_score','_source'))
})

test_that("search for document type works, and differently for different ES versions", {
  if (z$es_ver() >= 700) {
    expect_warning(
      bb <- Search(z, index="shakespeare", type="line"),
      "Specifying types in search requests is deprecated"
    )
  } else {
    cc <- Search(z, index="shakespeare", type="line")
    expect_match(vapply(cc$hits$hits, "[[", "", "_type"), "line")
  }
})

test_that("search for specific fields works", {

  if (gsub("\\.", "", x$ping()$version$number) >= 500) {
    c <- Search(x, index="shakespeare", body = '{
      "_source": ["play_name", "speaker"]
    }')
    expect_equal(sort(unique(lapply(c$hits$hits, function(x) names(x$`_source`)))[[1]]), c('play_name','speaker'))
  } else {
    c <- Search(x, index="shakespeare", fields=c('play_name','speaker'))
    expect_equal(sort(unique(lapply(c$hits$hits, function(x) names(x$fields)))[[1]]), c('play_name','speaker'))
  }
})

test_that("search paging works", {

  if (gsub("\\.", "", x$ping()$version$number) >= 500) {
    d <- Search(x, index = "shakespeare", size = 1, body = '{
      "_source": ["text_entry"]
    }')$hits$hits
  } else {
    d <- Search(x, index="shakespeare", size=1, fields='text_entry')$hits$hits
  }
  expect_equal(length(d), 1)
})

test_that("search terminate_after parameter works", {

  e <- Search(x, index="shakespeare", terminate_after=1)
  expect_is(e, "list")
})

test_that("getting json data back from search works", {

  suppressMessages(require('jsonlite'))

  if (z$es_ver() >= 700) {
    expect_warning(
      f <- Search(z, index="shakespeare", type="scene", raw=TRUE),
      "Specifying types in search requests is deprecated"
    )
  } else {
    f <- Search(z, index="shakespeare", type="scene", raw=TRUE)
  }
  expect_is(f, "character")
  expect_true(jsonlite::validate(f))
  expect_is(jsonlite::fromJSON(f), "list")
})

test_that("Search works with special characters - +", {
  if (x$es_ver() < 200) skip('skipping for this ES version')
  invisible(tryCatch(index_delete(x, "a+b"), error = function(e) e))
  invisible(index_create(x, "a+b"))
  invisible(docs_create(x, index = "a+b", type = "wiz", id=1, body=list(a="ddd", b="eee")))
  
  Sys.sleep(1)
  aplusb <- Search(x, index = "a+b")
  
  expect_is(aplusb, "list")
  expect_equal(length(aplusb$hits$hits), 1)
  expect_equal(vapply(aplusb$hits$hits, "[[", "", "_index"), 'a+b')
})

test_that("Search works with special characters - ^", {
  invisible(tryCatch(index_delete(x, "a^z"), error = function(e) e))
  invisible(index_create(x, "a^z"))
  invisible(docs_create(x, index = "a^z", type = "bang", id=1, body=list(a="fff", b="ggg")))
  
  Sys.sleep(1)
  ahatz <- Search(x, index = "a^z")
  
  expect_is(ahatz, "list")
  expect_equal(length(ahatz$hits$hits), 1)
  expect_equal(vapply(ahatz$hits$hits, "[[", "", "_index"), 'a^z')
})
  
test_that("Search works with special characters - $", {
  invisible(tryCatch(index_delete(x, "a$z"), error = function(e) e))
  invisible(index_create(x, "a$z"))
  invisible(docs_create(x, index = "a$z", type = "bang", id=1, body=list(a="fff", b="ggg")))
  
  Sys.sleep(1)
  adollarz <- Search(x, index = "a$z")
  
  expect_is(adollarz, "list")
  expect_equal(length(adollarz$hits$hits), 1)
  expect_equal(vapply(adollarz$hits$hits, "[[", "", "_index"), 'a$z')
})

test_that("Search works with wild card", {
  if (index_exists(x, "voobardang1")) {
    invisible(index_delete(x, "voobardang1"))
  }
  invisible(index_create(x, "voobardang1"))
  invisible(docs_create(x, index = "voobardang1", type = "wiz", id=1, body=list(a="ddd", b="eee")))

  if (index_exists(x, "voobardang2")) {
    invisible(index_delete(x, "voobardang2"))
  }
  index_create(x, "voobardang2")
  invisible(docs_create(x, index = "voobardang2", type = "bang", id=1, body=list(a="fff", b="ggg")))
  
  Sys.sleep(1)
  aster <- Search(x, index = "voobardang*")
  
  expect_is(aster, "list")
  expect_equal(length(aster$hits$hits), 2)
  expect_equal(vapply(aster$hits$hits, "[[", "", "_index"), c('voobardang1', 'voobardang2'))
  expect_equal(vapply(aster$hits$hits, "[[", "", "_id"), c('1', '1'))
})

test_that("Search fails as expected", {

  aggs <- list(aggs = list(stats = list(stfff = list(field = "text_entry"))))
  if (gsub("\\.", "", x$ping()$version$number) >= 500) {
    if (gsub("\\.", "", x$ping()$version$number) >= 770) {
      expect_error(Search(x, index = "shakespeare", body = aggs), 
                   "known")
    } else if (gsub("\\.", "", x$ping()$version$number) >= 630) {
      expect_error(Search(x, index = "shakespeare", body = aggs))
    } else if (gsub("\\.", "", x$ping()$version$number) >= 530) {
      expect_error(Search(x, index = "shakespeare", body = aggs), 
                   "Unknown BaseAggregationBuilder \\[stfff\\]")
    } else {
      expect_error(Search(x, index = "shakespeare", body = aggs), 
                   "Could not find aggregator type \\[stfff\\] in \\[stats\\]")
    }
  } else {
    expect_error(Search(x, index = "shakespeare", body = aggs), "all shards failed")
  }

  expect_error(Search(x, index = "shakespeare", type = "act", sort = "text_entryasasfd"), "all shards failed")

  expect_error(Search(x, index = "shakespeare", size = "adf"), "size should be a numeric or integer class value")

  expect_error(Search(x, index = "shakespeare", from = "asdf"), "from should be a numeric or integer class value")

  expect_error(Search(x, index="shakespeare", q="~text_entry:ma~"), "all shards failed")
  
  if (x$es_ver() < 600) {
    expect_error(Search(x, index="shakespeare", q="line_id:[10 TO x]"), 
                 "all shards failed||SearchPhaseExecutionException")
  }

  expect_error(Search(x, index="shakespeare", terminate_after="Afd"), 
               "terminate_after should be a numeric")
})
