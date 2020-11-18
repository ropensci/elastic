context("nodes")

x <- connect(port = Sys.getenv("TEST_ES_PORT"))

test_that("nodes_stats", {

  out <- nodes_stats(x)
  out2 <- nodes_stats(x, node = names(out$nodes))

  if (gsub("\\.", "", x$ping()$version$number) >= 500) {
    expect_equal(sort(names(out)), c("_nodes", "cluster_name", "nodes"))
  } else {
    expect_equal(sort(names(out)), c("cluster_name", "nodes"))
  }
  expect_is(out, "list")
  expect_is(out2, "list")
  expect_is(nodes_stats(x, metric = 'jvm'), "list")
  expect_is(nodes_stats(x, metric = c('os', 'process')), "list")
  expect_equal(length(nodes_stats(x, node = "$$%%$$$")$nodes), 0)
})

test_that("nodes_info", {

  out <- nodes_info(x)
  out2 <- nodes_info(x, node = names(out$nodes))

  if (gsub("\\.", "", x$ping()$version$number) >= 500) {
    expect_equal(sort(names(out)), c("_nodes", "cluster_name", "nodes"))
  } else {
    expect_equal(sort(names(out)), c("cluster_name", "nodes"))
  }
  expect_is(out, "list")
  expect_is(out2, "list")
  expect_is(nodes_info(x, metric = 'get'), "list")
  expect_is(nodes_info(x, metric = 'jvm'), "list")
  expect_is(nodes_info(x, metric = c('os', 'process')), "list")
  expect_equal(length(nodes_info(x, node = "$$%%$$$")$nodes), 0)
})
