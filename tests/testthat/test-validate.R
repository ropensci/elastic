context("validate")

x <- connect()

test_that("validate", {
  if (!index_exists(x, "twitter")) index_create(x, "twitter")
  docs_create(x, 'twitter', type='tweet', id=1, body = list(
     "user" = "foobar", 
     "post_date" = "2014-01-03",
     "message" = "trying out Elasticsearch"
   )
  )
  a <- validate(x, "twitter", q='user:foobar')

  expect_is(a, "list")
  expect_equal(sort(names(a)), c('_shards', 'valid'))
  expect_true(a$valid)
  
  if (es_version(x) >= 700) {
    expect_warning(
      validate(x, "twitter", "tweet", q='user:foobar'),
      "Specifying types in validate query requests is deprecated"
    )
  }
})
