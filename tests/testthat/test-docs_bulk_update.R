context("docs_bulk_update")

invisible(connect())

test_that("docs_bulk_update - works with data.frame input", {
  # remove index if it exists
  if (index_exists("world")) index_delete("world")

  iris_mapping <- '{
   "mappings": {
     "world": {
       "properties": {
          "Petal_Length": {
            "type": "float"
          },
          "Petal_Width": {
            "type": "float"
          },
          "Sepal_Length": {
            "type": "float"
          },
          "Sepal_Width": {
            "type": "float"
          },
          "Species": {
            "type": "%s"
          },
          "id": {
            "type": "long"
          }
        }
     }
   }
  }'

  # use 'string' or 'text' depending on ES version
  string_text <- if (es_ver() < 500) "string" else "text"
  index_create('world', sprintf(iris_mapping, string_text))

  # load bulk
  iris <- stats::setNames(iris, gsub("\\.", "_", names(iris)))
  iris$id <- seq_len(NROW(iris))
  invisible(docs_bulk(iris, "world", "world", quiet = TRUE, 
    es_ids = FALSE))

  # get data
  Sys.sleep(2) # sleep a bit to wait for data to be there
  res_before <- Search("world", asdf = TRUE)

  # update data
  iris$Sepal_Length <- iris$Sepal_Length / 10

  # load again
  invisible(a <- docs_bulk_update(iris, index = "world", type = "world", 
    quiet = TRUE))

  # get data again
  Sys.sleep(2) # sleep a bit to wait for data to be updated
  res_after <- Search("world", asdf = TRUE)
  
  expect_is(a, "list")
  expect_equal(length(a), 1)
  expect_named(a[[1]], c('took', 'errors', 'items'))
  expect_equal(length(a[[1]]$items), NROW(iris))

  expect_is(res_before, "list")
  expect_is(res_after, "list")
  expect_gt(
    mean(as.numeric(res_before$hits$hits$`_source.Sepal_Length`)), 
    mean(as.numeric(res_after$hits$hits$`_source.Sepal_Length`))
  )

  # ES version sensitive test of body results
  if (gsub("\\.", "", ping()$version$number) >= 500) {
    expect_equal(a[[1]]$items[[1]]$update$`_index`, "world")
  } else {
    expect_equal(a[[1]]$items[[1]]$update$`_index`, "world")
  }
})

test_that("docs_bulk_update - works with data.frame where ids are factors", {
  # remove index if it exists
  if (index_exists("mars")) {
    index_delete("mars")
  }
  
  df <- data.frame(name = letters[1:3], size = 1:3, id =c("AB", "CD", "EF"))
  invisible(docs_bulk(df, index = "mars", type = "mars", quiet = TRUE, es_ids = FALSE))
  # alter data.frame
  df$name <- letters[4:6]
  # update data
  a <- docs_bulk_update(df, index = "mars", type = "mars", quiet = TRUE)
  Sys.sleep(1)
  
  expect_is(df$id, "factor")
  expect_is(a, "list")
  expect_equal(length(a), 1)
  expect_named(a[[1]], c('took', 'errors', 'items'))
  expect_equal(length(a[[1]]$items), NROW(df))
  expect_equal(
    sort(Search('mars', asdf = TRUE)$hits$hits$`_id`), 
    sort(c("CD", "AB", "EF"))
  )
})


test_that("docs_bulk_update fails well", {
  # certain classes not supported
  expect_error(docs_bulk_update(5, quiet = TRUE), 
    "no 'docs_bulk_update' method for class numeric")
  expect_error(docs_bulk_update(matrix(1), quiet = TRUE), 
    "no 'docs_bulk_update' method for class matrix")
  expect_error(docs_bulk_update(TRUE, quiet = TRUE), 
    "no 'docs_bulk_update' method for class logical")
})



test_that("docs_bulk_update cleans up temp files", {
  curr_tempdir <- tempdir()
  if (index_exists("googoo")) {
    index_delete("googoo")
  }

  df <- data.frame(name = letters[1:3], size = 1:3, id = 100:102)
  invisible(docs_bulk(df, "googoo", "googoo", quiet = TRUE, es_ids = FALSE))
  aa <- docs_bulk_update(df, index="googoo", type="googoo", 
    quiet = TRUE)

  expect_equal(length(list.files(curr_tempdir, pattern = "elastic__")), 0)
})



test_that("docs_bulk_update: suppressing progress bar works", {
  x <- "asdfasdfasdf"
  if (index_exists(x)) {
    index_delete(x)
  }

  df <- data.frame(name = letters[1:3], size = 1:3, id = 100:102)
  invisible(docs_bulk(df, x, x, quiet = TRUE, es_ids = FALSE))

  quiet_true <- capture.output(invisible(
    docs_bulk_update(df, index=x, type=x, quiet = TRUE)))
  quiet_false <- capture.output(invisible(
    docs_bulk_update(df, index=x, type=x, quiet = FALSE)))
  expect_equal(length(quiet_true), 0)
  expect_match(quiet_false, "=====")
})

