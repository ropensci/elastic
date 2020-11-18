context("validate")

x <- connect(port = Sys.getenv("TEST_ES_PORT"), warn = FALSE)
z <- connect(port = Sys.getenv("TEST_ES_PORT"), warn = TRUE)

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
  
  if (z$es_ver() >= 700) {
    expect_warning(
      validate(z, "twitter", "tweet", q='user:foobar'),
      "Specifying types in validate query requests is deprecated"
    )
  }
})
