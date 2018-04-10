context("explain")

invisible(connect())

test_that("explain", {
  type_ <- if (es_ver() < 600) "scene" else "line"

  a <- explain(index = "shakespeare", type = type_, id = 324, q = "palace")

  body <- '{
   "query": {
     "term": { "text_entry": "palace" }
   }
  }'
  b <- explain(index = "shakespeare", type = type_, id = 324, body = body)

  body <- '{
   "query": {
     "term": { "text_entry": "stuff" }
   }
  }'
  c <- explain(index = "shakespeare", type = type_, id = 324, body = body)

  expect_is(a, "list")
  expect_is(b, "list")
  expect_is(c, "list")

  if (es_ver() < 600) {
    if (es_ver() >= 200) {
      expect_match(a$explanation$description, "sum of")
      expect_match(b$explanation$description, "sum of")
      expect_match(c$explanation$description, "Failure to meet condition")  
    }
  } else {
    expect_match(a$explanation$description, "max of")
    expect_match(b$explanation$description, "weight")
    expect_match(c$explanation$description, "no matching term")
  }

  expect_true(a$matched)
  expect_true(b$matched)
  expect_false(c$matched)
})
