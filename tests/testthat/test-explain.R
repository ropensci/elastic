context("explain")

invisible(tryCatch(elastic::connect(), error = function(e) e))

test_that("explain", {
  skip_on_cran()

  a <- explain(index = "shakespeare", type = "line", id = 42, q = "adfad")

  body <- '{
   "query": {
     "term": { "text_entry": "stuff" }
   }
  }'
  b <- explain(index = "shakespeare", type = "line", id = 42, body = body)

  body <- '{
   "query": {
     "term": { "text_entry": "irregular" }
   }
  }'
  c <- explain(index = "shakespeare", type = "line", id = 42, body = body)

  expect_is(a, "list")
  expect_is(b, "list")
  expect_is(c, "list")

  expect_match(a$explanation$description, "no matching term")
  expect_match(b$explanation$description, "no matching term")
  expect_match(c$explanation$description, "weight")

  expect_false(a$matched)
  expect_false(b$matched)
  expect_true(c$matched)
})
