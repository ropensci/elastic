context("docs_bulk_prep")

test_that("docs_bulk_prep - works with data.frame input", {
  ff <- tempfile(fileext = ".json")
  a <- docs_bulk_prep(mtcars, index = "hello", type = "world", 
    path = ff, quiet = TRUE)
  a_res <- readLines(ff)
  
  expect_is(a, "character")
  expect_equal(length(a), 1)
  expect_match(a, "json")
  expect_gt(length(a_res), 50)
  expect_match(a_res[1], "hello")
  expect_match(a_res[2], "disp")

  # cleanup
  unlink(ff, force = TRUE)
})

test_that("docs_bulk_prep - works with data.frame input where ids are factors", {
  ff <- tempfile(fileext = ".json")
  df <- data.frame(name = letters[1:3], size = 1:3, id =c("AB", "CD", "EF"))
  a <- docs_bulk_prep(df, index = "hello2", type = "world2", 
    path = ff, quiet = TRUE)
  a_res <- readLines(ff)
  
  expect_is(a, "character")
  expect_equal(length(a), 1)
  expect_match(a, "json")
  expect_equal(length(a_res), 6)
  expect_match(a_res[1], "hello2")

  # cleanup
  unlink(ff, force = TRUE)
})

test_that("docs_bulk_prep - works with list input", {
  ff <- tempfile(fileext = ".json")
  a <- docs_bulk_prep(apply(iris, 1, as.list), index="iris", type="flowers", 
    path = ff, quiet = TRUE)
  a_res <- readLines(ff)
  
  expect_is(a, "character")
  expect_equal(length(a), 1)
  expect_match(a, "json")
  expect_gt(length(a_res), 200)
  expect_match(a_res[1], "iris")
  expect_match(a_res[2], "Sepal")

  # cleanup
  unlink(ff, force = TRUE)
})

test_that("docs_bulk_prep - works with list input where ids are factors", {
  ff <- tempfile(fileext = ".json")
  df <- data.frame(name = letters[1:3], size = 1:3, id =c("AB", "CD", "EF"))
  lst <- apply(df, 1, as.list)
  lst <- lapply(lst, function(z) {z$id <- as.factor(z$id); z})
  a <- docs_bulk_prep(lst, index = "hello3", type = "world3", 
    path = ff, quiet = TRUE)
  a_res <- readLines(ff)
  
  expect_is(a, "character")
  expect_equal(length(a), 1)
  expect_match(a, "json")
  expect_equal(length(a_res), 6)
  expect_match(a_res[1], "hello3")

  # cleanup
  unlink(ff, force = TRUE)
})

test_that("docs_bulk_prep - chunks gives many file paths, with indexed suffix", {
  ff <- tempfile(fileext = ".json")
  bigiris <- do.call("rbind", replicate(30, iris, FALSE))
  a <- docs_bulk_prep(bigiris, index = "big", path = ff, quiet = TRUE)
  a_res <- readLines(a[1])
  
  indices <- as.numeric(vapply(a, function(x) {
    tmp <- strsplit(x, "", split = "\\.json")[[1]][1]
    substring(tmp, nchar(tmp), nchar(tmp))
  }, ""))
  
  expect_is(a, "character")
  expect_equal(length(a), 5)
  expect_match(a, "json")
  
  expect_equal(indices, 1:5)
  
  expect_equal(length(a_res), 2000)
  expect_match(a_res[1], "big")
  expect_match(a_res[2], "Petal")

  # cleanup
  unlink(ff, force = TRUE)
})

test_that("docs_bulk_prep fails as expected", {
  expect_error(docs_bulk_prep(5), "no 'docs_bulk_prep' method for class numeric")
  expect_error(docs_bulk_prep(matrix(1)), "no 'docs_bulk_prep' method for class matrix")
  expect_error(docs_bulk_prep(TRUE), "no 'docs_bulk_prep' method for class logical")
  expect_error(docs_bulk_prep("adfadf"), "no 'docs_bulk_prep' method for class character")
})

test_that("dataset with NA's", {
  # data.frame
  test4 <- mtcars
  row.names(test4) <- NULL
  test4$mpg[1] <- NA
  test4$disp[1] <- NA
  test4$wt[1] <- NA
  res <- invisible(docs_bulk_prep(test4, "mtcars", "mtcars.json", quiet = TRUE))
  
  expect_is(res, "character")
  expect_equal(res, "mtcars.json")
  
  lns <- readLines(res)
  expect_is(lns, "character")
  expect_gt(length(lns), 20)
  expect_identical(
    jsonlite::fromJSON(lns[2]),
    structure(
      list(mpg = NULL, cyl = 6L, disp = NULL, hp = 110L, drat = 3.9, 
           wt = NULL, qsec = 16.46, vs = 0L, am = 1L, gear = 4L, carb = 4L), 
      .Names = c('mpg', 'cyl', 'disp', 'hp', 'drat', 'wt', 'qsec', 'vs', 'am', 'gear', 'carb'))
  )
  
  # list
  mtcarslist <- apply(test4, 1, as.list)
  res <- invisible(docs_bulk_prep(mtcarslist, "mtcars", "mtcarslist.json", 
    quiet = TRUE))
  
  expect_is(res, "character")
  expect_equal(res, "mtcarslist.json")
  
  lns <- readLines(res)
  expect_is(lns, "character")
  expect_gt(length(lns), 20)
  expect_identical(
    jsonlite::fromJSON(lns[2]),
    structure(
      list(mpg = NULL, cyl = 6L, disp = NULL, hp = 110L, drat = 3.9, 
           wt = NULL, qsec = 16.46, vs = 0L, am = 1L, gear = 4L, carb = 4L),  
      .Names = c('mpg', 'cyl', 'disp', 'hp', 'drat', 'wt', 'qsec', 'vs', 'am', 'gear', 'carb'))
  )
})


test_that("docs_bulk_prep: suppressing progress bar works", {
  quiet_true <- capture.output(invisible(
    docs_bulk_prep(mtcars, index="asdfdafasdf", type="asdfadfsdfsdfdf", 
      path = tempfile(fileext = ".json"), quiet = TRUE)))
  quiet_false <- capture.output(invisible(
    docs_bulk_prep(mtcars, index="asdfdafasdf", type="asdfadfsdfsdfdf", 
      path = tempfile(fileext = ".json"), quiet = FALSE)))
  expect_equal(length(quiet_true), 0)
  expect_match(quiet_false, "=====")
})


