context("Search_template")

invisible(connect())

body1 <- '{
   "inline" : {
     "query": { "match" : { "{{my_field}}" : "{{my_value}}" } },
     "size" : "{{my_size}}"
   },
   "params" : {
     "my_field" : "Species",
     "my_value" : "setosa",
     "my_size" : 3
   }
}'

body2 <- '{
 "inline": {
   "query": {
      "match": {
          "Species": "{{query_string}}"
      }
   }
 },
 "params": {
   "query_string": "versicolor"
 }
}'

test_that("basic Search_template works", {
  if (!index_exists("iris")) invisible(docs_bulk(iris, "iris"))

  a <- Search_template(body = body1)
  expect_equal(names(a), c('took','timed_out','_shards','hits'))
  expect_is(a, "list")
  expect_is(a$hits$hits, "list")
  expect_equal(
    unique(vapply(a$hits$hits, "[[", "", c('_source', 'Species'))),
    "setosa"
  )
  expect_equal(length(a$hits$hits), 3)
})

test_that("Search_template - raw parameter works", {
  b <- Search_template(body = body1, raw = TRUE)
  expect_is(b, "character")
})

test_that("Search_template pre-registration works", {
  if (!index_exists("iris")) invisible(docs_bulk(iris, "iris"))

  a <- Search_template_register('foobar', body = body2)
  expect_is(a, "list")
  expect_equal(a$`_id`, "foobar")
  
  b <- Search_template_get('foobar')
  expect_is(b, "list")
  expect_equal(b$`_id`, "foobar")
  expect_equal(b$lang, "mustache")
  expect_is(b$template, "character")
  
  c <- Search_template_delete('foobar')
  expect_is(c, "list")
  expect_equal(c$`_id`, "foobar")
  expect_true(c$found)
  expect_error(Search_template_get("foobar"), 
               "Not Found")
})

test_that("Search_template validate works", {
  a <- Search_template_render(body = body1)
  
  expect_is(a, "list")
  expect_equal(names(a), 'template_output')
  expect_is(a$template_output, "list")
  expect_equal(a$template_output$size, "3")
  expect_named(a$template_output$query, 'match')
  expect_named(a$template_output$query$match, 'Species')
  expect_equal(a$template_output$query$match$Species, 'setosa')
})

test_that("search_template fails as expected", {
  expect_error(Search_template(index = "shakespeare", body = list(a = 5)),
               "all shards failed")
  expect_error(Search_template(body = 5), "all shards failed")
  expect_error(Search_template(raw = 4), "'raw' parameter must be")
})
