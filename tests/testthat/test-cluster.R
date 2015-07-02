context("cluster")

if (!identical(Sys.getenv("NOT_CRAN"), "true")) {
  invisible(connect())
}

test_that("cluster_settings", {
  skip_on_cran()

  out <- cluster_settings()

  expect_named(out, c("persistent", "transient"))
  expect_is(out, "list")
  expect_equal(length(out$transient), 0)
})

test_that("cluster_health", {
  skip_on_cran()

  out2 <- suppressMessages(cluster_health())

  expect_named(out2)
  expect_is(out2, "list")
  expect_equal(out2$cluster_name, "elasticsearch")
  expect_is(cluster_health(raw = TRUE), "elastic_cluster_health")
  expect_is(unclass(cluster_health(raw = TRUE)), "character")
})

test_that("cluster_state", {
  skip_on_cran()

  out3 <- suppressMessages(cluster_state())

  expect_named(out3)
  expect_is(out3, "list")
  expect_equal(out3$cluster_name, "elasticsearch")
  expect_is(cluster_state(raw = TRUE), "elastic_cluster_state")
  expect_error(cluster_state(index = "af"), "missing")
})

test_that("cluster_stats", {
  skip_on_cran()

  out4 <- suppressMessages(cluster_stats())

  expect_named(out4, c('timestamp', 'cluster_name', 'status', 'indices', 'nodes'))
  expect_is(out4, "list")
  expect_is(out4$indices, "list")
  expect_is(cluster_stats(raw = TRUE), "elastic_cluster_stats")
  expect_error(cluster_stats(index = "af"), "missing")
})

test_that("cluster_pending_tasks", {
  skip_on_cran()

  out5 <- suppressMessages(cluster_pending_tasks())

  expect_named(out5, 'tasks')
  expect_is(out5, "list")
  expect_is(out5$tasks, "list")
  expect_equal(length(out5$tasks), 0)
  expect_is(cluster_pending_tasks(raw = TRUE), "elastic_cluster_pending_tasks")
  expect_error(cluster_pending_tasks(index = "af"), "missing")
})
