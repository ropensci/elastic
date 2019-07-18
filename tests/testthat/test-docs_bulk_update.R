context("docs_bulk_update")

x <- connect(warn = FALSE)

test_that("docs_bulk_update - works with data.frame input", {
  # remove index if it exists
  if (index_exists(x, "world")) index_delete(x, "world")

  # iris_mapping <- '{
  #  "mappings": {
  #    "world": {
  #      "properties": {
  #         "Petal_Length": {
  #           "type": "float"
  #         },
  #         "Petal_Width": {
  #           "type": "float"
  #         },
  #         "Sepal_Length": {
  #           "type": "float"
  #         },
  #         "Sepal_Width": {
  #           "type": "float"
  #         },
  #         "Species": {
  #           "type": "%s"
  #         },
  #         "id": {
  #           "type": "long"
  #         }
  #       }
  #    }
  #  }
  # }'

  # iris_mapping2 <- '{
  #  "mappings": {
  #    "properties": {
  #       "Petal_Length": {
  #         "type": "float"
  #       },
  #       "Petal_Width": {
  #         "type": "float"
  #       },
  #       "Sepal_Length": {
  #         "type": "float"
  #       },
  #       "Sepal_Width": {
  #         "type": "float"
  #       },
  #       "Species": {
  #         "type": "%s"
  #       },
  #       "id": {
  #         "type": "long"
  #       }
  #     }
  #  }
  # }'

  # # use 'string' or 'text' depending on ES version
  # string_text <- if (x$es_ver() < 500) "string" else "text"
  # # use mapping without type if ES >= 7
  # mapping <- if (x$es_ver() >= 700) iris_mapping2 else iris_mapping
  # index_create(x, 'world', sprintf(mapping, string_text))

  # load bulk
  iris <- stats::setNames(iris, gsub("\\.", "_", names(iris)))
  iris$id <- seq_len(NROW(iris))
  invisible(docs_bulk(x, iris, "world", quiet = TRUE,
    es_ids = FALSE))

  # get data
  Sys.sleep(2) # sleep a bit to wait for data to be there
  res_before <- Search(x, "world", asdf = TRUE)

  # update data
  iris$Sepal_Length <- iris$Sepal_Length / 10

  # load again
  invisible(a <- docs_bulk_update(x, iris, index = "world",
    quiet = TRUE))

  # get data again
  Sys.sleep(2) # sleep a bit to wait for data to be updated
  res_after <- Search(x, "world", asdf = TRUE)

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
  if (x$es_ver() >= 500) {
    expect_equal(a[[1]]$items[[1]]$update$`_index`, "world")
  } else {
    expect_equal(a[[1]]$items[[1]]$update$`_index`, "world")
  }
})

test_that("docs_bulk_update - works with data.frame where ids are factors", {
  # remove index if it exists
  if (index_exists(x, "mars")) {
    index_delete(x, "mars")
  }

  df <- data.frame(name = letters[1:3], size = 1:3, id =c("AB", "CD", "EF"))
  invisible(docs_bulk(x ,df, index = "mars", type = "mars", quiet = TRUE, es_ids = FALSE))
  # alter data.frame
  df$name <- letters[4:6]
  # update data
  a <- docs_bulk_update(x, df, index = "mars", type = "mars", quiet = TRUE)
  Sys.sleep(1)

  expect_is(df$id, "factor")
  expect_is(a, "list")
  expect_equal(length(a), 1)
  expect_named(a[[1]], c('took', 'errors', 'items'))
  expect_equal(length(a[[1]]$items), NROW(df))
  expect_equal(
    sort(Search(x, 'mars', asdf = TRUE)$hits$hits$`_id`),
    sort(c("CD", "AB", "EF"))
  )
})

test_that("docs_bulk_update - works with data.frame with boolean types", {
  # remove index if it exists
  if (index_exists(x, "mixed")) index_delete(x, "mixed")

  # create a data frame with mixed bool and non-bool types
  mixed <- data.frame(
    id = as.character(1:3),
    x = c(TRUE, FALSE, TRUE),
    y = c("a", "b", "c"),
    stringsAsFactors = FALSE
  )

  # mixed_mapping_gt_v5 <- '{
  #   "mappings": {
  #     "mixed": {
  #       "properties": {
  #         "x": { "type": "boolean" },
  #         "y": { "type": "keyword" }
  #       }
  #     }
  #   }
  # }'
  # mixed_mapping_lt_v5 <- '{
  #   "mappings": {
  #     "mixed": {
  #       "properties": {
  #         "x": { "type": "boolean" },
  #         "y": { "type": "string" }
  #       }
  #     }
  #   }
  # }'
  # mixed_mapping_lt_v7<- '{
  #   "mappings": {
  #     "properties": {
  #       "x": { "type": "boolean" },
  #       "y": { "type": "text" }
  #     }
  #   }
  # }'

  # # toggle mapping types based on ES version
  # mixed_mapping <- if (x$es_ver() < 500) {
  #   mixed_mapping_lt_v5 
  # } else if (x$es_ver() >= 700) {
  #   mixed_mapping_lt_v7
  # } else {
  #   mixed_mapping_gt_v5
  # }
  # index_create(x, "mixed", mixed_mapping)

  # load via bulk update
  invisible(docs_bulk(x, mixed, index = "mixed", quiet = TRUE,
    es_ids = FALSE))

  # add a new row
  mixed <- rbind(mixed, data.frame(id = 4, x = TRUE, y = "d"))

  # update data
  update_res <- docs_bulk_update(x, mixed, index = "mixed",
    quiet = TRUE)
  Sys.sleep(1) # sleep a bit to wait for data to be there

  # get data frame back from search
  mixed_es <- Search(x, 'mixed', asdf = TRUE)$hits$hits
  mixed_es <- mixed_es[order(mixed_es$`_id`),]

  # ensure bulk update succeeded
  expect_is(update_res, "list")
  expect_equal(length(update_res), 1)
  expect_named(update_res[[1]], c('took', 'errors', 'items'))
  expect_equal(length(update_res[[1]]$items), nrow(mixed))

  # ensure search result types and values match original
  expect_equal(mixed$id, mixed_es$`_id`)
  expect_equal(mixed$x, mixed_es$`_source.x`)
  expect_equal(mixed$y, mixed_es$`_source.y`)
})

test_that("docs_bulk_update fails well", {
  # certain classes not supported
  expect_error(docs_bulk_update(x, 5, quiet = TRUE),
    "no 'docs_bulk_update' method for class numeric")
  expect_error(docs_bulk_update(x, matrix(1), quiet = TRUE),
    "no 'docs_bulk_update' method for class matrix")
  expect_error(docs_bulk_update(x, TRUE, quiet = TRUE),
    "no 'docs_bulk_update' method for class logical")
})



test_that("docs_bulk_update cleans up temp files", {
  curr_tempdir <- tempdir()
  if (index_exists(x, "googoo")) {
    index_delete(x, "googoo")
  }

  df <- data.frame(name = letters[1:3], size = 1:3, id = 100:102)
  invisible(docs_bulk(x ,df, "googoo", "googoo", quiet = TRUE, es_ids = FALSE))
  aa <- docs_bulk_update(x, df, index="googoo", type="googoo",
    quiet = TRUE)

  expect_equal(length(list.files(curr_tempdir, pattern = "elastic__")), 0)
})



test_that("docs_bulk_update: suppressing progress bar works", {
  z <- "asdfasdfasdf"
  if (index_exists(x, z)) {
    index_delete(x, z)
  }

  df <- data.frame(name = letters[1:3], size = 1:3, id = 100:102)
  invisible(docs_bulk(x, df, z, z, quiet = TRUE, es_ids = FALSE))

  quiet_true <- capture.output(invisible(
    docs_bulk_update(x, df, index=z, type=z, quiet = TRUE)))
  quiet_false <- capture.output(invisible(
    docs_bulk_update(x, df, index=z, type=z, quiet = FALSE)))
  expect_equal(length(quiet_true), 0)
  expect_match(quiet_false, "=====")
})

