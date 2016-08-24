context("mtermvectors")

invisible(connect())

if (!index_exists('omdb')) {
  omdb <- system.file("examples", "omdb.json", package = "elastic")
  invisible(docs_bulk(omdb))
}

ids <- vapply(Search("omdb", size = 2)$hits$hits, "[[", "", "_id")
body <- sprintf('{
       "ids" : ["%s", "%s"],
       "parameters": {
           "fields": [
               "Plot"
           ],
           "term_statistics": true
       }
  }', ids[1], ids[2])

test_that("mtermvectors works", {
  skip_on_travis()
  if (gsub("\\.", "", ping()$version$number) < 130) skip('feature not in this ES version')

  aa <- mtermvectors('omdb', 'omdb', body = body)

  expect_is(aa, 'list')
  expect_named(aa, 'docs')

  expect_equal(aa$docs[[1]]$`_index`, "omdb")
  expect_equal(aa$docs[[1]]$`_type`, "omdb")
  expect_is(aa$docs[[1]]$`_id`, "character")

  expect_is(aa$docs[[1]]$term_vectors, "list")
  expect_named(aa$docs[[1]]$term_vectors, 'Plot')
  expect_named(aa$docs[[1]]$term_vectors$Plot, c('field_statistics', 'terms'))
  expect_is(aa$docs[[1]]$term_vectors$Plot$field_statistics, "list")
  expect_is(aa$docs[[1]]$term_vectors$Plot$terms, "list")
  expect_is(aa$docs[[1]]$term_vectors$Plot$terms[[1]], "list")
  expect_named(aa$docs[[1]]$term_vectors$Plot$terms[[1]]$tokens[[1]], c('position', 'start_offset', 'end_offset'))
})

test_that("mtermvectors fails well", {
  skip_on_travis()

  expect_error(mtermvectors(body = body), "index is missing")
  expect_error(mtermvectors("omdb", body = body), "type is missing")
})
