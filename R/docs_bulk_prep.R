#' Use the bulk API to prepare bulk format data
#'
#' @export
#' @inheritParams docs_bulk
#' @param x A data.frame or a list. required.
#' @param index (character) The index name. required.
#' @param path (character) Path to the file. If data is broken into chunks,
#' we'll use this path as the prefix, and suffix each file path with a number.
#' required.
#' @return File path(s). By default we use temporary files; these are cleaned
#' up at the end of a session
#' 
#' @section Tempfiles:
#' In \code{docs_bulk} we create temporary files in some cases, and delete 
#' those before the function exits. However, we don't clean up those files
#' in this function because the point of the function is to create the 
#' newline delimited JSON files that you need. Tempfiles are cleaned up
#' when you R session ends though - be aware of that. If you want to 
#' keep the files make sure to move them outside of the temp directory.
#'
#' @seealso \code{\link{docs_bulk}}
#'
#' @examples \dontrun{
#' # From a data.frame
#' ff <- tempfile(fileext = ".json")
#' docs_bulk_prep(mtcars, index = "hello", type = "world", path = ff)
#' readLines(ff)
#' 
#' ## field names cannot contain dots
#' names(iris) <- gsub("\\.", "_", names(iris))
#' docs_bulk_prep(iris, "iris", "flowers", path = tempfile(fileext = ".json"))
#' 
#' ## type can be missing, but index can not
#' docs_bulk_prep(iris, "flowers", path = tempfile(fileext = ".json"))
#'
#' # From a list
#' docs_bulk_prep(apply(iris, 1, as.list), index="iris", type="flowers",
#'    path = tempfile(fileext = ".json"))
#' docs_bulk_prep(apply(USArrests, 1, as.list), index="arrests",
#'    path = tempfile(fileext = ".json"))
#'
#' # when chunking
#' ## multiple files created, one for each chunk
#' bigiris <- do.call("rbind", replicate(30, iris, FALSE))
#' docs_bulk_prep(bigiris, index = "big", path = tempfile(fileext = ".json"))
#'
#' # When using in a loop
#' ## We internally get last _id counter to know where to start on next bulk
#' ## insert but you need to sleep in between docs_bulk_prep calls, longer the
#' ## bigger the data is
#' files <- c(system.file("examples", "test1.csv", package = "elastic"),
#'            system.file("examples", "test2.csv", package = "elastic"),
#'            system.file("examples", "test3.csv", package = "elastic"))
#' paths <- vector("list", length = length(files))
#' for (i in seq_along(files)) {
#'   d <- read.csv(files[[i]])
#'   paths[i] <- docs_bulk_prep(d, index = "stuff", type = "docs",
#'      path = tempfile(fileext = ".json"))
#' }
#' unlist(paths)
#'
#' # You can include your own document id numbers
#' ## Either pass in as an argument
#' files <- c(system.file("examples", "test1.csv", package = "elastic"),
#'            system.file("examples", "test2.csv", package = "elastic"),
#'            system.file("examples", "test3.csv", package = "elastic"))
#' tt <- vapply(files, function(z) NROW(read.csv(z)), numeric(1))
#' ids <- list(1:tt[1],
#'            (tt[1] + 1):(tt[1] + tt[2]),
#'            (tt[1] + tt[2] + 1):sum(tt))
#' paths <- vector("list", length = length(files))
#' for (i in seq_along(files)) {
#'   d <- read.csv(files[[i]])
#'   paths[i] <- docs_bulk_prep(d, index = "testes", type = "docs",
#'     doc_ids = ids[[i]], es_ids = FALSE, path = tempfile(fileext = ".json"))
#' }
#' unlist(paths)
#'
#' ## or include in the input data
#' ### from data.frame's
#' files <- c(system.file("examples", "test1_id.csv", package = "elastic"),
#'            system.file("examples", "test2_id.csv", package = "elastic"),
#'            system.file("examples", "test3_id.csv", package = "elastic"))
#' paths <- vector("list", length = length(files))
#' for (i in seq_along(files)) {
#'   d <- read.csv(files[[i]])
#'   paths[i] <- docs_bulk_prep(d, index = "testes", type = "docs",
#'      path = tempfile(fileext = ".json"))
#' }
#' unlist(paths)
#'
#' ### from lists via file inputs
#' paths <- vector("list", length = length(files))
#' for (i in seq_along(files)) {
#'   d <- read.csv(files[[i]])
#'   d <- apply(d, 1, as.list)
#'   paths[i] <- docs_bulk_prep(d, index = "testes", type = "docs",
#'       path = tempfile(fileext = ".json"))
#' }
#' unlist(paths)
#'
#' 
#' # suppress progress bar
#' docs_bulk_prep(mtcars, index = "hello", type = "world", 
#'   path = tempfile(fileext = ".json"), quiet = TRUE)
#' ## vs. 
#' docs_bulk_prep(mtcars, index = "hello", type = "world", 
#'   path = tempfile(fileext = ".json"), quiet = FALSE)
#' }
docs_bulk_prep <- function(x, index, path, type = NULL, chunk_size = 1000,
  doc_ids = NULL, quiet = FALSE) {

  UseMethod("docs_bulk_prep")
}

#' @export
docs_bulk_prep.default <- function(x, index, path, type = NULL,
  chunk_size = 1000, doc_ids = NULL, quiet = FALSE) {

  stop("no 'docs_bulk_prep' method for class ", class(x), call. = FALSE)
}

#' @export
docs_bulk_prep.data.frame <- function(x, index, path, type = NULL,
  chunk_size = 1000, doc_ids = NULL, quiet = FALSE) {

  assert(quiet, "logical")
  if (is.null(type)) type <- index
  check_doc_ids(x, doc_ids)
  es_ids <- if (!is.null(doc_ids)) FALSE else TRUE
  if (is.factor(doc_ids)) doc_ids <- as.character(doc_ids)
  row.names(x) <- NULL
  rws <- seq_len(NROW(x))
  data_chks <- split(rws, ceiling(seq_along(rws) / chunk_size))
  if (!is.null(doc_ids)) {
    id_chks <- split(doc_ids, ceiling(seq_along(doc_ids) / chunk_size))
  } else if (has_ids(x)) {
    rws <- x$id
    id_chks <- split(rws, ceiling(seq_along(rws) / chunk_size))
  } else {
    rws <- shift_start(rws, index, type)
    id_chks <- split(rws, ceiling(seq_along(rws) / chunk_size))
  }

  if (!quiet) {
    pb <- txtProgressBar(min = 0, max = length(data_chks), initial = 0, style = 3)
    on.exit(close(pb))
  }
  resl <- vector(mode = "list", length = length(data_chks))
  for (i in seq_along(data_chks)) {
    if (!quiet) setTxtProgressBar(pb, i)
    resl[[i]] <- make_bulk(
      x[data_chks[[i]], , drop = FALSE], index, type, id_chks[[i]], es_ids,
      path = if (length(data_chks) > 1) adjust_path(path, i) else path
    )
  }
  return(unlist(resl))
}

#' @export
docs_bulk_prep.list <- function(x, index, path, type = NULL,
  chunk_size = 1000, doc_ids = NULL, quiet = FALSE) {

  assert(quiet, "logical")
  if (is.null(type)) type <- index
  check_doc_ids(x, doc_ids)
  es_ids <- if (!is.null(doc_ids)) TRUE else FALSE
  if (is.factor(doc_ids)) doc_ids <- as.character(doc_ids)
  x <- unname(x)
  x <- check_named_vectors(x)
  rws <- seq_len(length(x))
  data_chks <- split(rws, ceiling(seq_along(rws) / chunk_size))
  if (!is.null(doc_ids)) {
    id_chks <- split(doc_ids, ceiling(seq_along(doc_ids) / chunk_size))
  } else if (has_ids(x)) {
    rws <- as.numeric(sapply(x, "[[", "id"))
    id_chks <- split(rws, ceiling(seq_along(rws) / chunk_size))
  } else {
    rws <- shift_start(rws, index, type)
    id_chks <- split(rws, ceiling(seq_along(rws) / chunk_size))
  }

  if (!quiet) {
    pb <- txtProgressBar(min = 0, max = length(data_chks), initial = 0, style = 3)
    on.exit(close(pb))
  }
  resl <- vector(mode = "list", length = length(data_chks))
  for (i in seq_along(data_chks)) {
    if (!quiet) setTxtProgressBar(pb, i)
    resl[[i]] <- make_bulk(
      x[data_chks[[i]]], index, type, id_chks[[i]], es_ids,
      path = if (length(data_chks) > 1) adjust_path(path, i) else path
    )
  }
  return(unlist(resl))
}
