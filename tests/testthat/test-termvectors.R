context("termvectors")

invisible(connect())

if (!index_exists('omdb')) {
  omdb <- system.file("examples", "omdb.json", package = "elastic")
  invisible(docs_bulk(omdb))
}

test_that("termvectors works", {
  
  body <- '{
    "fields" : ["Plot"],
    "offsets" : true,
    "positions" : true,
    "term_statistics" : true,
    "field_statistics" : true
  }'
  
  aa <- termvectors('omdb', 'omdb', 'AVXdx8Eqg_0Z_tpMDyP_', body = body)
  
  
  expect_is(aa, 'list')
  expect_equal(aa$`_index`, "omdb")
  expect_equal(aa$`_type`, "omdb")
  expect_is(aa$`_id`, "character")
  
  expect_is(aa$term_vectors, "list")
  expect_named(aa$term_vectors, 'Plot')
  expect_named(aa$term_vectors$Plot, c('field_statistics', 'terms'))
  expect_is(aa$term_vectors$Plot$field_statistics, "list")
  expect_is(aa$term_vectors$Plot$terms, "list")
  expect_is(aa$term_vectors$Plot$terms[[1]], "list")
  expect_named(aa$term_vectors$Plot$terms[[1]]$tokens[[1]], c('position', 'start_offset', 'end_offset'))
})

test_that("termvectors fails well", {
  expect_error(termvectors(), "argument \"index\" is missing")
  expect_error(termvectors("omdb"), "argument \"type\" is missing")
  expect_error(termvectors("omdb", "omdb"), "Validation Failed")
  
  body <- '{
     "fields" : ["Plot"],
     "offsets" : true,
     "positions" : true,
     "term_statistics" : true,
    "field_statistics" : true
  }'
  
  expect_error(termvectors('omdb', 'omdb', body = body), 
               "Validation Failed")
  expect_equal(length(termvectors('omdb', 'omdb', 'AVXdx8Eqg_0Z_tpMDyP_')$term_vectors), 
               0)
})
