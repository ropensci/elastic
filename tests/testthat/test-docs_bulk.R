context("docs_bulk")

x <- connect(warn = FALSE)

test_that("docs_bulk - works with bulk format file", {
  # remove index if it exists
  if (index_exists(x, "gbifnewgeo")) {
    index_delete(x, "gbifnewgeo")
  }
  
  gsmall <- system.file("examples", "gbif_geo.json",
    package = "elastic")
  if (x$es_ver() >= 700) gsmall <- type_remover(gsmall)
  a <- docs_bulk(x, x = gsmall, quiet = TRUE)

  expect_is(a, "list")
  expect_named(a, c('took', 'errors', 'items'))
  expect_equal(length(a$items), 301)
  expect_equal(a$items[[1]]$index$`_index`, "gbifgeo")
})

test_that("docs_bulk - works with data.frame input", {
  # remove index if it exists
  if (index_exists(x, "hello")) {
    index_delete(x, "hello")
  }
  
  iris <- stats::setNames(iris, gsub("\\.", "_", names(iris)))
  if (x$es_ver() < 700) {
    a <- docs_bulk(x, iris[3:NROW(iris),], index = "hello", type = "world",
      quiet = TRUE)
  } else {
    a <- docs_bulk(x, iris[3:NROW(iris),], index = "hello",
      quiet = TRUE)
  }

  expect_is(a, "list")
  expect_equal(length(a), 1)
  expect_named(a[[1]], c('took', 'errors', 'items'))
  expect_equal(length(a[[1]]$items), NROW(iris[3:NROW(iris),]))
  if (gsub("\\.", "", x$ping()$version$number) >= 500) {
    expect_equal(a[[1]]$items[[1]]$index$`_index`, "hello")
  } else {
    expect_equal(a[[1]]$items[[1]]$create$`_index`, "hello")
  }
})

test_that("docs_bulk - works with data.frame where ids are factors", {
  # remove index if it exists
  if (index_exists(x, "hello2")) {
    index_delete(x, "hello2")
  }

  df <- data.frame(name = letters[1:3], size = 1:3, id =c("AB", "CD", "EF"))
  if (x$es_ver() < 700) {
    a <- docs_bulk(x, df, index = "hello2", type = "hello2", quiet = TRUE)
  } else {
    a <- docs_bulk(x, df, index = "hello2", quiet = TRUE)
  }

  expect_is(df$id, "character")
  expect_is(a, "list")
  expect_equal(length(a), 1)
  expect_named(a[[1]], c('took', 'errors', 'items'))
  expect_equal(length(a[[1]]$items), NROW(df))
})

test_that("docs_bulk - works with list input", {
  # remove index if it exists
  if (index_exists(x, "arrests")) {
    index_delete(x, "arrests")
  }

  # load bulk
  if (x$es_ver() < 700) {
    a <- docs_bulk(x, apply(USArrests, 1, as.list),
      index = "arrests", type = "arrests", quiet = TRUE)
  } else {
    a <- docs_bulk(x, apply(USArrests, 1, as.list),
      index = "arrests", quiet = TRUE)
  }

  expect_is(a, "list")
  expect_equal(length(a), 1)
  expect_named(a[[1]], c('took', 'errors', 'items'))
  expect_equal(length(a[[1]]$items), 50)

  if (gsub("\\.", "", x$ping()$version$number) >= 500) {
    expect_equal(a[[1]]$items[[1]]$index$`_index`, "arrests")
  } else {
    expect_equal(a[[1]]$items[[1]]$create$`_index`, "arrests")
  }
})

test_that("docs_bulk - works with list where ids are factors", {
  # remove index if it exists
  if (index_exists(x, "hello3")) {
    index_delete(x, "hello3")
  }

  # load bulk
  df <- data.frame(name = letters[1:3], size = 1:3, id =c("AB", "CD", "EF"))
  lst <- apply(df, 1, as.list)
  lst <- lapply(lst, function(z) {z$id <- as.factor(z$id); z})
  if (x$es_ver() < 700) {
    a <- docs_bulk(x, lst, index = "hello3", type = "hello3",
      quiet = TRUE)
  } else {
    a <- docs_bulk(x, lst, index = "hello3", quiet = TRUE)
  }

  expect_equal(unique(vapply(lst, function(z) class(z$id), character(1))), "factor")
  expect_is(a, "list")
  expect_equal(length(a), 1)
  expect_named(a[[1]], c('took', 'errors', 'items'))
  expect_equal(length(a[[1]]$items), length(lst))
})



test_that("docs_bulk fails as expected", {
  # certain classes not supported
  expect_error(docs_bulk(x, 5, quiet = TRUE),
    "no 'docs_bulk' method for class numeric")
  expect_error(docs_bulk(x, matrix(1), quiet = TRUE),
    "no 'docs_bulk' method for class matrix")
  expect_error(docs_bulk(x, TRUE, quiet = TRUE),
    "no 'docs_bulk' method for class logical")

  # character string has to be a file that exists on disk
  expect_error(docs_bulk(x, "adfadf", quiet = TRUE),
    "file.exists\\(x\\) is not TRUE")
})


test_that("dataset with NA's", {
  # data.frame
  # remove index if it exists
  if (index_exists(x, "mtcars")) {
    index_delete(x, "mtcars")
  }
  test1 <- mtcars
  row.names(test1) <- NULL
  test1[] <- lapply(test1, function(x) {
    n <- sample(seq_len(NROW(test1)), size = sample(seq_len(NROW(test1)), 1))
    x[n] <- NA
    x
  })
  res <- invisible(docs_bulk(x, test1, "mtcars", "mtcars", quiet = TRUE))

  expect_is(res, "list")
  expect_is(res[[1]]$items[[1]], "list")

  Sys.sleep(2)
  out <- Search(x, "mtcars", asdf = TRUE)$hits$hits
  expect_is(out, "data.frame")
  expect_true(any(is.na(out)))

  # list
  # remove index if it exists
  if (index_exists(x, "mtcars")) {
    index_delete(x, "mtcars")
  }
  test2 <- mtcars
  row.names(test2) <- NULL
  test2[] <- lapply(test2, function(x) {
    n <- sample(seq_len(NROW(test2)), size = sample(seq_len(NROW(test2)), 1))
    x[n] <- NA
    x
  })
  mtcarslist <- apply(test2, 1, as.list)
  res <- invisible(docs_bulk(x, mtcarslist, "mtcars", "mtcars", quiet = TRUE))

  expect_is(res, "list")
  expect_is(res[[1]]$items[[1]], "list")

  Sys.sleep(2)
  out <- Search(x, "mtcars", asdf = TRUE)$hits$hits
  expect_is(out, "data.frame")
  expect_true(any(is.na(out)))

  # file
  # remove index if it exists
  if (index_exists(x, "mtcars")) {
    index_delete(x, "mtcars")
  }
  test3 <- mtcars
  row.names(test3) <- NULL
  test3[] <- lapply(test3, function(x) {
    n <- sample(seq_len(NROW(test3)), size = sample(seq_len(NROW(test3)), 1))
    x[n] <- NA
    x
  })
  tfile <- tempfile(pattern = "mtcars_file", fileext = ".json")
  if (x$es_ver() < 700) {
    res <- invisible(docs_bulk_prep(test3, "mtcars", path = tfile,
      type = "mtcars", quiet = TRUE))
  } else {
    res <- invisible(docs_bulk_prep(test3, "mtcars", path = tfile,
      quiet = TRUE))
  }
  res <- invisible(docs_bulk(x, res, quiet = TRUE))

  expect_is(res, "list")
  expect_is(res$items[[1]], "list")

  Sys.sleep(2)
  out <- Search(x, "mtcars", asdf = TRUE)$hits$hits
  expect_is(out, "data.frame")
  expect_true(any(is.na(out)))
})


test_that("docs_bulk cleans up temp files", {
  curr_tempdir <- tempdir()
  if (index_exists(x, "iris")) {
    index_delete(x, "iris")
  }
  aa <- docs_bulk(x, apply(iris, 1, as.list), index="iris", type="flowers",
    quiet = TRUE)

  expect_equal(length(list.files(curr_tempdir, pattern = "elastic__")), 0)
})



test_that("docs_bulk: suppressing progress bar works", {
  if (index_exists(x, "asdfdafasdf")) {
    index_delete(x, "asdfdafasdf")
  }

  quiet_true <- capture.output(invisible(
    docs_bulk(x, mtcars, index="asdfdafasdf", type="asdfadfsdfsdfdf",
      quiet = TRUE)))
  quiet_false <- capture.output(invisible(
    docs_bulk(x, mtcars, index="asdfdafasdf", type="asdfadfsdfsdfdf",
      quiet = FALSE)))
  expect_equal(length(quiet_true), 0)
  expect_match(quiet_false, "=====")
})


test_that("docs_bulk: pipline attachments work", {
  body <- '{
    "description" : "Extract attachment information",
    "processors" : [
      {
        "attachment" : {
          "field" : "data",
          "target_field": "fulltext",
          "indexed_chars" : -1,
          "on_failure" : [
            {
              "set" : {
                "field" : "error",
                "value" : "{{ _ingest.on_failure_message }}"
              }
            }
          ]
        },
      "remove": {
        "field": "data"
      }
      }
    ]
  }'
  pipeline_create(x, id = "attachment", body = body)
  if (index_exists(x, "myindex")) index_delete(x, "myindex")
  index_create(x, "myindex")
  docs <- list(
    list(data = "e1xydGYxXGFuc2kNCkxvcmVtIGlwc3VtIGRvbG9yIHNpdCBhbWV0DQpccGFyIH0=",
         category = "lorem ipsum"),
    list(data = "aGVsbG8gd29ybGQgaGVsbG8gd29ybGQ=",
         category = "hello world")
  )
  invisible(docs_bulk(x, docs, index = "myindex", doc_ids = 1:2, es_ids = FALSE,
    quiet = TRUE, query = list(pipeline = 'attachment')))
  Sys.sleep(1)
  docs <- Search(x, "myindex")
  doc1 <- docs$hits$hits[[1]]$`_source`
  expect_equal(sort(names(doc1)), c("category", "fulltext"))
  expect_equal(sort(names(doc1$fulltext)),
    c("content", "content_length", "content_type", "language"))
  expect_equal(doc1$fulltext$content_type, "application/rtf")
})
