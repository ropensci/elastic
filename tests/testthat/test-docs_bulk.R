context("docs_bulk")

invisible(connect())

test_that("docs_bulk - works with bulk format file", {
  # remove index if it exists
  if (index_exists("gbifnewgeo")) {
    index_delete("gbifnewgeo")
  }
  # file
  gsmall <- system.file("examples", "gbif_geo.json", package = "elastic")
  # load bulk
  a <- docs_bulk(x = gsmall, quiet = TRUE)
  
  expect_is(a, "list")
  expect_named(a, c('took', 'errors', 'items'))
  expect_equal(length(a$items), 301)
  expect_equal(a$items[[1]]$index$`_index`, "gbifgeo")
})

test_that("docs_bulk - works with data.frame input", {
  # remove index if it exists
  if (index_exists("hello")) {
    index_delete("hello")
  }
  # load bulk
  iris <- stats::setNames(iris, gsub("\\.", "_", names(iris)))
  a <- docs_bulk(iris[3:NROW(iris),], index = "hello", type = "world", 
    quiet = TRUE)
  
  expect_is(a, "list")
  expect_equal(length(a), 1)
  expect_named(a[[1]], c('took', 'errors', 'items'))
  expect_equal(length(a[[1]]$items), NROW(iris[3:NROW(iris),]))
  if (gsub("\\.", "", ping()$version$number) >= 500) {
    expect_equal(a[[1]]$items[[1]]$index$`_index`, "hello")
  } else {
    expect_equal(a[[1]]$items[[1]]$create$`_index`, "hello")
  }
})

test_that("docs_bulk - works with data.frame where ids are factors", {
  # remove index if it exists
  if (index_exists("hello2")) {
    index_delete("hello2")
  }
  
  # load bulk
  df <- data.frame(name = letters[1:3], size = 1:3, id =c("AB", "CD", "EF"))
  a <- docs_bulk(df, index = "hello2", type = "hello2", quiet = TRUE)
  
  expect_is(df$id, "factor")
  expect_is(a, "list")
  expect_equal(length(a), 1)
  expect_named(a[[1]], c('took', 'errors', 'items'))
  expect_equal(length(a[[1]]$items), NROW(df))
})

test_that("docs_bulk - works with list input", {
  # remove index if it exists
  if (index_exists("arrests")) {
    index_delete("arrests")
  }
  # load bulk
  a <- docs_bulk(apply(USArrests, 1, as.list), index = "arrests", 
    quiet = TRUE)
  
  expect_is(a, "list")
  expect_equal(length(a), 1)
  expect_named(a[[1]], c('took', 'errors', 'items'))
  expect_equal(length(a[[1]]$items), 50)
  
  if (gsub("\\.", "", ping()$version$number) >= 500) {
    expect_equal(a[[1]]$items[[1]]$index$`_index`, "arrests")
  } else {
    expect_equal(a[[1]]$items[[1]]$create$`_index`, "arrests")
  }
})

test_that("docs_bulk - works with list where ids are factors", {
  # remove index if it exists
  if (index_exists("hello3")) {
    index_delete("hello3")
  }
  
  # load bulk
  df <- data.frame(name = letters[1:3], size = 1:3, id =c("AB", "CD", "EF"))
  lst <- apply(df, 1, as.list)
  lst <- lapply(lst, function(z) {z$id <- as.factor(z$id); z})
  a <- docs_bulk(lst, index = "hello3", type = "hello3", quiet = TRUE)
  
  expect_equal(unique(vapply(lst, function(z) class(z$id), character(1))), "factor")
  expect_is(a, "list")
  expect_equal(length(a), 1)
  expect_named(a[[1]], c('took', 'errors', 'items'))
  expect_equal(length(a[[1]]$items), length(lst))
})



test_that("docs_bulk fails as expected", {
  # certain classes not supported
  expect_error(docs_bulk(5, quiet = TRUE), 
    "no 'docs_bulk' method for class numeric")
  expect_error(docs_bulk(matrix(1), quiet = TRUE), 
    "no 'docs_bulk' method for class matrix")
  expect_error(docs_bulk(TRUE, quiet = TRUE), 
    "no 'docs_bulk' method for class logical")
  
  # character string has to be a file that exists on disk
  expect_error(docs_bulk("adfadf", quiet = TRUE), 
    "file.exists\\(x\\) is not TRUE")
})


test_that("dataset with NA's", {
  # data.frame
  # remove index if it exists
  if (index_exists("mtcars")) {
    index_delete("mtcars")
  }
  test1 <- mtcars
  row.names(test1) <- NULL
  test1[] <- lapply(test1, function(x) {
    n <- sample(seq_len(NROW(test1)), size = sample(seq_len(NROW(test1))))
    x[n] <- NA
    x
  })
  res <- invisible(docs_bulk(test1, "mtcars", "mtcars", quiet = TRUE))
  
  expect_is(res, "list")
  expect_is(res[[1]]$items[[1]], "list")
  
  Sys.sleep(2)
  out <- Search("mtcars", asdf = TRUE)$hits$hits
  expect_is(out, "data.frame")
  expect_true(any(is.na(out)))
  
  # list
  # remove index if it exists
  if (index_exists("mtcars")) {
    index_delete("mtcars")
  }
  test2 <- mtcars
  row.names(test2) <- NULL
  test2[] <- lapply(test2, function(x) {
    n <- sample(seq_len(NROW(test2)), size = sample(seq_len(NROW(test2))))
    x[n] <- NA
    x
  })
  mtcarslist <- apply(test2, 1, as.list)
  res <- invisible(docs_bulk(mtcarslist, "mtcars", "mtcars", quiet = TRUE))
  
  expect_is(res, "list")
  expect_is(res[[1]]$items[[1]], "list")
  
  Sys.sleep(2)
  out <- Search("mtcars", asdf = TRUE)$hits$hits
  expect_is(out, "data.frame")
  expect_true(any(is.na(out)))
  
  # file
  # remove index if it exists
  if (index_exists("mtcars")) {
    index_delete("mtcars")
  }
  test3 <- mtcars
  row.names(test3) <- NULL
  test3[] <- lapply(test3, function(x) {
    n <- sample(seq_len(NROW(test3)), size = sample(seq_len(NROW(test3))))
    x[n] <- NA
    x
  })
  tfile <- tempfile(pattern = "mtcars_file", fileext = ".json")
  res <- invisible(docs_bulk_prep(test3, "mtcars", path = tfile, quiet = TRUE))
  res <- invisible(docs_bulk(res, quiet = TRUE))
  
  expect_is(res, "list")
  expect_is(res$items[[1]], "list")
  
  Sys.sleep(2)
  out <- Search("mtcars", asdf = TRUE)$hits$hits
  expect_is(out, "data.frame")
  expect_true(any(is.na(out)))
})


test_that("docs_bulk cleans up temp files", {
  curr_tempdir <- tempdir()
  if (index_exists("iris")) {
    index_delete("iris")
  }
  aa <- docs_bulk(apply(iris, 1, as.list), index="iris", type="flowers", 
    quiet = TRUE)

  expect_equal(length(list.files(curr_tempdir, pattern = "elastic__")), 0)
})



test_that("docs_bulk: suppressing progress bar works", {
  if (index_exists("asdfdafasdf")) {
    index_delete("asdfdafasdf")
  }

  quiet_true <- capture.output(invisible(
    docs_bulk(mtcars, index="asdfdafasdf", type="asdfadfsdfsdfdf", 
      quiet = TRUE)))
  quiet_false <- capture.output(invisible(
    docs_bulk(mtcars, index="asdfdafasdf", type="asdfadfsdfsdfdf", 
      quiet = FALSE)))
  expect_equal(length(quiet_true), 0)
  expect_match(quiet_false, "=====")
})

