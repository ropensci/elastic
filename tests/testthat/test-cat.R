context("cat")

invisible(connect())

test_that("cat_", {
  if (!es_version() < 110) {
    a <- cat_(parse = TRUE)
    expect_is(a, "data.frame")
    expect_is(a$V1, "character")
    expect_gt(length(a$V1), 10)
    expect_is(capture.output(cat_()), "character")
  }
})

test_that("cat_indices", {
  if (!es_version() < 110) {
    b <- cat_indices(index = 'shakespeare', parse = TRUE, verbose = TRUE)
    c <- cat_indices(index = 'shakespeare', parse = TRUE, bytes = TRUE, verbose = TRUE)
    expect_is(b, "data.frame")
    expect_named(b)
    
    expect_is(b$store.size, "character")
    expect_is(c$store.size, "integer")
    
    if (es_version() < 120) {
      expect_message(cat_indices(index = "adf"), "Nothing to print")
    } else {
      expect_error(cat_indices(index = "adf"), "no such index||IndexMissing")
    }
    expect_error(cat_indices(bytes = "adfad"), "is not TRUE")
  }
})

# test_that("cat_master", {
# 
#   d <- cat_master(parse = TRUE, verbose = TRUE)
#   expect_is(d, "data.frame")
#   expect_named(d)
# 
#   expect_is(d$host, "character")
# 
#   expect_error(cat_master(help = "Adf"), "is not TRUE")
# })
