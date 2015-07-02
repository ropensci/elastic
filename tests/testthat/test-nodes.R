context("nodes")

invisible(connect())

test_that("nodes_stats", {

  out <- nodes_stats()
  out2 <- nodes_stats(node = names(out$nodes))

  expect_named(out, c("cluster_name", "nodes"))
  expect_is(out, "list")
  expect_is(out2, "list")
  expect_is(nodes_stats(metric = 'get'), "list")
  expect_is(nodes_stats(metric = 'jvm'), "list")
  expect_is(nodes_stats(metric = c('os', 'process')), "list")
  expect_equal(length(nodes_stats(node = "$$%%$$$")$nodes), 0)
})

test_that("nodes_info", {

  out <- nodes_info()
  out2 <- nodes_info(node = names(out$nodes))

  expect_named(out, c("cluster_name", "nodes"))
  expect_is(out, "list")
  expect_is(out2, "list")
  expect_is(nodes_info(metric = 'get'), "list")
  expect_is(nodes_info(metric = 'jvm'), "list")
  expect_is(nodes_info(metric = c('os', 'process')), "list")
  expect_equal(length(nodes_info(node = "$$%%$$$")$nodes), 0)
})
