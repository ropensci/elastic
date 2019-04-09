context("ingest/pipeline")

x <- connect()

body1 <- '{
  "description" : "do a thing",
  "version" : 123,
  "processors" : [
    {
      "set" : {
        "field": "foo",
        "value": "bar"
      }
    }
  ]
}'

body2 <- '{
  "description" : "do another thing",
  "processors" : [
    {
      "set" : {
        "field": "stuff",
        "value": "things"
      }
    }
  ]
}'

bodysim <- '{
  "pipeline" : {
    "description" : "do another thing",
    "processors" : [
      {
        "set" : {
          "field": "stuff",
          "value": "things"
        }
      }
    ]
  },
  "docs" : [
    { "_source": {"foo": "bar"} },
    { "_source": {"foo": "world"} }
  ]
}'

test_that("pipeline_create", {
  if (!es_version(x) < 500) {
    a <- pipeline_create(x, id = 'foo', body = body1)
    expect_true(a[[1]])
    expect_named(a, "acknowledged")
    expect_is(a, "list")

    b <- pipeline_create(x, id = 'bar', body = body2)
    expect_true(b[[1]])
    expect_named(b, "acknowledged")
    expect_is(b, "list")    
  }
})

test_that("pipeline_get", {
  if (!es_version(x) < 500) {
    # invisible(pipeline_create(x, id = 'foo', body = body1))

    a <- pipeline_get(x, "foo")
    expect_named(a, "foo")
    expect_is(a, "list")
    expect_is(a$foo, "list")
    expect_equal(a$foo$description, "do a thing")
    
    # can get multiple ids at once  
    # invisible(pipeline_create(x, id = 'bar', body = body2))

    b <- pipeline_get(x, c("foo", "bar"))
    expect_equal(names(b), c("foo", "bar"))
  }
})

test_that("pipeline_delete", {
  if (!es_version(x) < 500) {
    a <- pipeline_delete(x, 'foo')
    expect_named(a, "acknowledged")
    expect_is(a, "list")
    expect_true(a$acknowledged)

    expect_error(pipeline_delete(x, 'stuff'), "pipeline \\[stuff\\] is missing")
  }
})

test_that("pipeline_simulate", {
  if (!es_version(x) < 500) {
    a <- pipeline_simulate(x, bodysim)
    expect_named(a, "docs")
    expect_is(a, "list")
    expect_is(a$docs, "data.frame")

    expect_error(pipeline_delete(x, 'stuff'), "pipeline \\[stuff\\] is missing")
  }
})

test_that("pipeline fxns error well", {
  if (es_version(x) < 500) {
    expect_error(pipeline_get(x, ""), "available in ES v5 and greater")
    expect_error(pipeline_create(x, "", ""), "available in ES v5 and greater")
    expect_error(pipeline_delete(x, "", ""), "available in ES v5 and greater")
    expect_error(pipeline_simulate(x, ""), "available in ES v5 and greater")
  }

  if (!es_version(x) < 500) {
    expect_error(pipeline_get(x, ), "argument \"id\" is missing")
    expect_error(pipeline_create(x, ), "argument \"body\" is missing")
    expect_error(pipeline_delete(x, ), "argument \"id\" is missing")
    expect_error(pipeline_simulate(x, ), "argument \"body\" is missing")
  }
})

## cleanup -----------------------------------
if (!es_version(x) < 502) {
  invisible(pipeline_delete(x, "*"))
}
