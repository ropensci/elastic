#' Use the bulk API to create, index, update, or delete documents.
#'
#' @export
#' @param conn an Elasticsearch connection object, see [connect()]
#' @param x A list, data.frame, or character path to a file. required.
#' @param index (character) The index name to use. Required for data.frame
#' input, but optional for file inputs.
#' @param type (character) The type. default: `NULL`. Note that `type` is
#' deprecated in Elasticsearch v7 and greater, and removed in Elasticsearch v8
#' @param chunk_size (integer) Size of each chunk. If your data.frame is smaller
#' thank `chunk_size`, this parameter is essentially ignored. We write in
#' chunks because at some point, depending on size of each document, and
#' Elasticsearch setup, writing a very large number of documents in one go
#' becomes slow, so chunking can help. This parameter is ignored if you
#' pass a file name. Default: 1000
#' @param doc_ids An optional vector (character or numeric/integer) of document
#' ids to use. This vector has to equal the size of the documents you are
#' passing in, and will error if not. If you pass a factor we convert to
#' character. Default: not passed
#' @param es_ids (boolean) Let Elasticsearch assign document IDs as UUIDs.
#' These are sequential, so there is order to the IDs they assign.
#' If `TRUE`, \code{doc_ids} is ignored. Default: `TRUE`
#' @param raw (logical) Get raw JSON back or not. If `TRUE` 
#' you get JSON; if `FALSE` you get a list. Default: `FALSE`
#' @param quiet (logical) Suppress progress bar. Default: `FALSE`
#' @param query (list) a named list of query parameters. optional. 
#' options include: pipeline, refresh, routing, _source, _source_excludes,
#' _source_includes, timeout, wait_for_active_shards. See the docs bulk
#' ES page for details
#' @param ... Pass on curl options to [crul::HttpClient]
#'
#' @details More on the Bulk API:
#' <https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html>
#'
#' This function dispatches on data.frame or character input. Character input
#' has to be a file name or the function stops with an error message.
#'
#' If you pass a data.frame to this function, we by default do an index
#' operation, that is, create the record in the index given by those
#' parameters to the function. Down the road perhaps we will try to support
#' other operations on the bulk API. if you pass a file, of course in that
#' file, you can specify any operations you want.
#'
#' Row names are dropped from data.frame, and top level names for a list
#' are dropped as well.
#'
#' A progress bar gives the progress for data.frames and lists - the progress
#' bar is based around a for loop, where progress indicates progress along
#' the iterations of the for loop, where each iteration is a chunk of data
#' that's converted to bulk format, then pushed into Elasticsearch. The
#' `character` method has no for loop, so no progress bar.
#'
#' @section Document IDs:
#' Document IDs can be passed in via the `doc_ids` paramater when passing
#' in data.frame or list, but not with files. If ids are not passed to
#' `doc_ids`, we assign document IDs from 1 to length of the object
#' (rows of a data.frame, or length of a list). In the future we may allow the
#' user to select whether they want to assign sequential numeric IDs or 
#' to allow Elasticsearch to assign IDs, which are UUIDs that are actually 
#' sequential, so you still can determine an order of your documents.
#' 
#' @section Document IDs and Factors:
#' If you pass in ids that are of class factor, we coerce them to character 
#' with `as.character`. This applies to both data.frame and list inputs, but
#' not to file inputs.
#'
#' @section Large numbers for document IDs:
#' Until recently, if you had very large integers for document IDs,
#' `docs_bulk` failed. It should be fixed now. Let us know if not.
#'
#' @section Missing data:
#' As of \pkg{elastic} version `0.7.8.9515` we convert `NA` to
#' `null` before loading into Elasticsearch. Previously, fields that
#' had an `NA` were dropped - but when you read data back from
#' Elasticsearch into R, you retain those missing values as \pkg{jsonlite}
#' fills those in for you. Now, fields with `NA`'s are made into
#' `null`, and are not dropped in Elasticsearch.
#'
#' Note also that null values can not be indexed or searched
#' <https://www.elastic.co/guide/en/elasticsearch/reference/5.3/null-value.html>
#'
#' @section Tips:
#' This function returns the response from Elasticsearch, but you'll likely
#' not be that interested in the response. If not, wrap your call to
#' `docs_bulk` in [invisible()], like so: `invisible(docs_bulk(...))`
#' 
#' @section Connections/Files:
#' We create temporary files, and connections to those files, when data.frame's 
#' and lists are passed in to `docs_bulk()` (not when a file is passed in 
#' since we don't need to create a file). After inserting data into your 
#' Elasticsearch instance, we close the connections and delete the temporary files.
#' 
#' There are some exceptions though. When you pass in your own file, whether a 
#' tempfile or not, we don't delete those files after using them - in case 
#' you need those files again. Your own tempfile's will be cleaned up/delete 
#' when the R session ends. Non-tempfile's won't be cleaned up/deleted after
#' the R session ends. 
#' 
#' @section Elasticsearch versions that don't support type:
#' See the [type_remover()] function.
#'
#' @return A list
#' @family bulk-functions
#' 
#' @examples \dontrun{
#' # connection setup
#' (x <- connect())
#' 
#' # From a file already in newline delimited JSON format
#' plosdat <- system.file("examples", "plos_data.json", package = "elastic")
#' docs_bulk(x, plosdat)
#' aliases_get(x)
#' index_delete(x, index='plos')
#' aliases_get(x)
#'
#' # From a data.frame
#' docs_bulk(x, mtcars, index = "hello")
#' ## field names cannot contain dots
#' names(iris) <- gsub("\\.", "_", names(iris))
#' docs_bulk(x, iris, "iris")
#' ## type can be missing, but index can not
#' docs_bulk(x, iris, "flowers")
#' ## big data.frame, 53K rows, load ggplot2 package first
#' # res <- docs_bulk(x, diamonds, "diam")
#' # Search(x, "diam")$hits$total
#'
#' # From a list
#' docs_bulk(x, apply(iris, 1, as.list), index="iris")
#' docs_bulk(x, apply(USArrests, 1, as.list), index="arrests")
#' # dim_list <- apply(diamonds, 1, as.list)
#' # out <- docs_bulk(x, dim_list, index="diamfromlist")
#'
#' # When using in a loop
#' ## We internally get last _id counter to know where to start on next bulk
#' ## insert but you need to sleep in between docs_bulk calls, longer the
#' ## bigger the data is
#' files <- c(system.file("examples", "test1.csv", package = "elastic"),
#'            system.file("examples", "test2.csv", package = "elastic"),
#'            system.file("examples", "test3.csv", package = "elastic"))
#' for (i in seq_along(files)) {
#'   d <- read.csv(files[[i]])
#'   docs_bulk(x, d, index = "testes")
#'   Sys.sleep(1)
#' }
#' count(x, "testes")
#' index_delete(x, "testes")
#'
#' # You can include your own document id numbers
#' ## Either pass in as an argument
#' index_create(x, "testes")
#' files <- c(system.file("examples", "test1.csv", package = "elastic"),
#'            system.file("examples", "test2.csv", package = "elastic"),
#'            system.file("examples", "test3.csv", package = "elastic"))
#' tt <- vapply(files, function(z) NROW(read.csv(z)), numeric(1))
#' ids <- list(1:tt[1],
#'            (tt[1] + 1):(tt[1] + tt[2]),
#'            (tt[1] + tt[2] + 1):sum(tt))
#' for (i in seq_along(files)) {
#'   d <- read.csv(files[[i]])
#'   docs_bulk(x, d, index = "testes", doc_ids = ids[[i]],
#'     es_ids = FALSE)
#' }
#' count(x, "testes")
#' index_delete(x, "testes")
#'
#' ## or include in the input data
#' ### from data.frame's
#' index_create(x, "testes")
#' files <- c(system.file("examples", "test1_id.csv", package = "elastic"),
#'            system.file("examples", "test2_id.csv", package = "elastic"),
#'            system.file("examples", "test3_id.csv", package = "elastic"))
#' readLines(files[[1]])
#' for (i in seq_along(files)) {
#'   d <- read.csv(files[[i]])
#'   docs_bulk(x, d, index = "testes")
#' }
#' count(x, "testes")
#' index_delete(x, "testes")
#'
#' ### from lists via file inputs
#' index_create(x, "testes")
#' for (i in seq_along(files)) {
#'   d <- read.csv(files[[i]])
#'   d <- apply(d, 1, as.list)
#'   docs_bulk(x, d, index = "testes")
#' }
#' count(x, "testes")
#' index_delete(x, "testes")
#'
#' # data.frame's with a single column
#' ## this didn't use to work, but now should work
#' db <- paste0(sample(letters, 10), collapse = "")
#' index_create(x, db)
#' res <- data.frame(foo = 1:10)
#' out <- docs_bulk(x, res, index = db)
#' count(x, db)
#' index_delete(x, db)
#' 
#' 
#' # data.frame with a mix of actions
#' ## make sure you use a column named 'es_action' or this won't work
#' ## if you need to delete or update you need document IDs
#' if (index_exists(x, "baz")) index_delete(x, "baz")
#' df <- data.frame(a = 1:5, b = 6:10, c = letters[1:5], stringsAsFactors = FALSE) 
#' invisible(docs_bulk(x, df, "baz"))
#' Sys.sleep(3)
#' (res <- Search(x, 'baz', asdf=TRUE)$hits$hits)
#' df[1, "a"] <- 99
#' df[1, "c"] <- "aa"
#' df[3, "c"] <- 33
#' df[3, "c"] <- "cc"
#' df$es_action <- c('update', 'delete', 'update', 'delete', 'delete')
#' df$id <- res$`_id`
#' df
#' invisible(docs_bulk(x, df, "baz", es_ids = FALSE))
#' ### or es_ids = FALSE and pass in document ids to doc_ids
#' # invisible(docs_bulk(df, "baz", es_ids = FALSE, doc_ids = df$id))
#' Search(x, 'baz', asdf=TRUE)$hits$hits
#' 
#' 
#' # Curl options
#' plosdat <- system.file("examples", "plos_data_notypes.json",
#'   package = "elastic")
#' invisible(docs_bulk(x, plosdat, verbose = TRUE))
#' 
#' 
#' # suppress progress bar
#' invisible(docs_bulk(x, mtcars, index = "hello", quiet = TRUE))
#' ## vs. 
#' invisible(docs_bulk(x, mtcars, index = "hello", quiet = FALSE))
#' }
docs_bulk <- function(conn, x, index = NULL, type = NULL, chunk_size = 1000,
  doc_ids = NULL, es_ids = TRUE, raw = FALSE, quiet = FALSE, query = list(), ...) {

  UseMethod("docs_bulk", x)
}

#' @export
docs_bulk.default <- function(conn, x, index = NULL, type = NULL, chunk_size = 1000,
  doc_ids = NULL, es_ids = TRUE, raw = FALSE, quiet = FALSE, query = list(), ...) {

  stop("no 'docs_bulk' method for class ", class(x), call. = FALSE)
}

#' @export
docs_bulk.data.frame <- function(conn, x, index = NULL, type = NULL, chunk_size = 1000,
  doc_ids = NULL, es_ids = TRUE, raw = FALSE, quiet = FALSE, query = list(), ...) {

  is_conn(conn)
  assert(quiet, "logical")
  if (is.null(index)) {
    stop("index can't be NULL when passing a data.frame",
         call. = FALSE)
  }
  check_doc_ids(x, doc_ids)
  if (is.factor(doc_ids)) doc_ids <- as.character(doc_ids)
  row.names(x) <- NULL
  rws <- seq_len(NROW(x))
  data_chks <- split(rws, ceiling(seq_along(rws) / chunk_size))
  if (!is.null(doc_ids)) {
    id_chks <- split(doc_ids, ceiling(seq_along(doc_ids) / chunk_size))
  } else if (has_ids(x)) {
    rws <- if (inherits(x$id, "factor")) as.character(x$id) else x$id
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
    resl[[i]] <- docs_bulk(conn, make_bulk(x[data_chks[[i]], , drop = FALSE], 
      index, id_chks[[i]], es_ids, type), query = query, ...)
  }
  return(resl)
}

#' @export
docs_bulk.list <- function(conn, x, index = NULL, type = NULL, chunk_size = 1000,
                           doc_ids = NULL, es_ids = TRUE, raw = FALSE, 
                           quiet = FALSE, query = list(), ...) {

  is_conn(conn)
  assert(quiet, "logical")
  if (is.null(index)) {
    stop("index can't be NULL when passing a list",
         call. = FALSE)
  }
  check_doc_ids(x, doc_ids)
  if (is.factor(doc_ids)) doc_ids <- as.character(doc_ids)
  x <- unname(x)
  x <- check_named_vectors(x)
  rws <- seq_len(length(x))
  data_chks <- split(rws, ceiling(seq_along(rws) / chunk_size))
  if (!is.null(doc_ids)) {
    id_chks <- split(doc_ids, ceiling(seq_along(doc_ids) / chunk_size))
  } else if (has_ids(x)) {
    rws <- sapply(x, "[[", "id")
    rws <- if (inherits(rws, "factor")) as.character(rws) else rws
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
    resl[[i]] <- docs_bulk(conn, make_bulk(x[data_chks[[i]]], index, 
      id_chks[[i]], es_ids, type), query = query, ...)
  }
  return(resl)
}

#' @export
docs_bulk.character <- function(conn, x, index = NULL, type = NULL, chunk_size = 1000,
                                doc_ids = NULL, es_ids = TRUE, raw=FALSE, 
                                quiet = FALSE, query = list(), ...) {

  is_conn(conn)
  stopifnot(file.exists(x))
  stopifnot(is.list(query))
  on.exit(close_conns())
  on.exit(cleanup_file(x), add = TRUE)
  url <- file.path(conn$make_url(), '_bulk')
  cli <- crul::HttpClient$new(url = url,
    headers = conn$headers, 
    opts = c(conn$opts, ...),
    auth = crul::auth(conn$user, conn$pwd)
  )
  if (length(query) > 0) {
    for (i in seq_along(query)) {
      query[[i]] <- if (is.logical(query[[i]])) tolower(as.character(query[[i]])) else query[[i]]
    }
  }
  tt <- cli$post(body = crul::upload(x, type = "application/x-ndjson"), 
    query = query, encode = "json")
  if (conn$warn) catch_warnings(tt)
  geterror(conn, tt)
  res <- tt$parse("UTF-8")
  res <- structure(res, class = "bulk_make")
  if (raw) res else es_parse(res)
}
