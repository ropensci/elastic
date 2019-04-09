unlink("mtcars.json")
unlink("mtcarslist.json")
x <- elastic::connect()
invisible(elastic::index_delete(x, index="*", verbose = FALSE))
