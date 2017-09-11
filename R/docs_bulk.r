#' Use the bulk API to create, index, update, or delete documents.
#'
#' @export
#' @param x A list, data.frame, or character path to a file. required.
#' @param index (character) The index name to use. Required for data.frame
#' input, but optional for file inputs.
#' @param type (character) The type name to use. If left as NULL, will be
#' same name as index.
#' @param chunk_size (integer) Size of each chunk. If your data.frame is smaller
#' thank \code{chunk_size}, this parameter is essentially ignored. We write in
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
#' If \code{TRUE}, \code{doc_ids} is ignored. Default: \code{TRUE}
#' @param raw (logical) Get raw JSON back or not.
#' @param ... Pass on curl options to \code{\link[httr]{POST}}
#'
#' @seealso \code{\link{docs_bulk_prep}}
#'
#' @details More on the Bulk API:
#' \url{https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html}.
#'
#' This function dispatches on data.frame or character input. Character input
#' has to be a file name or the function stops with an error message.
#'
#' If you pass a data.frame to this function, we by default to an index
#' operation, that is, create the record in the index and type given by those
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
#' \code{character} method has no for loop, so no progress bar.
#'
#' @section Document IDs:
#' Document IDs can be passed in via the \code{doc_ids} paramater when passing
#' in data.frame or list, but not with files. If ids not passed to
#' \code{doc_ids}, we assign document IDs from 1 to length of the object
#' (rows of a data.frame, or length of a list). In the future we may allow the
#' user to select whether
#' they want to assign sequential numeric IDs or to allow Elasticsearch to
#' assign IDs, which are UUIDs that are actually sequential, so you still can
#' determine an order of your documents.
#'
#' @section Large numbers for document IDs:
#' Until recently, if you had very large integers for document IDs,
#' \code{docs_bulk} failed. It should be fixed now. Let us know if not.
#'
#' @section Missing data:
#' As of \pkg{elastic} version \code{0.7.8.9515} we convert \code{NA} to
#' \code{null} before loading into Elasticsearch. Previously, fields that
#' had an \code{NA} were dropped - but when you read data back from
#' Elasticsearch into R, you retain those missing values as \pkg{jsonlite}
#' fills those in for you. Now, fields with \code{NA}'s are made into
#' \code{null}, and are not dropped in Elasticsearch.
#'
#' Note also that null values can not be indexed or searched
#' \url{https://www.elastic.co/guide/en/elasticsearch/reference/5.3/null-value.html}
#'
#' @section Tips:
#' This function returns the response from Elasticsearch, but you'll likely
#' not be that interested in the response. If not, wrap your call to
#' \code{docs_bulk} in \code{\link{invisible}}, like so:
#' \code{invisible(docs_bulk(...))}
#'
#' @return A list
#'
#' @examples \dontrun{
#' plosdat <- system.file("examples", "plos_data.json", package = "elastic")
#' docs_bulk(plosdat)
#' aliases_get()
#' index_delete(index='plos')
#' aliases_get()
#'
#' # Curl options
#' library("httr")
#' plosdat <- system.file("examples", "plos_data.json", package = "elastic")
#' docs_bulk(plosdat, config=verbose())
#'
#' # From a data.frame
#' docs_bulk(mtcars, index = "hello", type = "world")
#' ## field names cannot contain dots
#' names(iris) <- gsub("\\.", "_", names(iris))
#' docs_bulk(iris, "iris", "flowers")
#' ## type can be missing, but index can not
#' docs_bulk(iris, "flowers")
#' ## big data.frame, 53K rows, load ggplot2 package first
#' # res <- docs_bulk(diamonds, "diam")
#' # Search("diam")$hits$total
#'
#' # From a list
#' docs_bulk(apply(iris, 1, as.list), index="iris", type="flowers")
#' docs_bulk(apply(USArrests, 1, as.list), index="arrests")
#' # dim_list <- apply(diamonds, 1, as.list)
#' # out <- docs_bulk(dim_list, index="diamfromlist")
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
#'   docs_bulk(d, index = "testes", type = "docs")
#'   Sys.sleep(1)
#' }
#' count("testes", "docs")
#' index_delete("testes")
#'
#' # You can include your own document id numbers
#' ## Either pass in as an argument
#' index_create("testes")
#' files <- c(system.file("examples", "test1.csv", package = "elastic"),
#'            system.file("examples", "test2.csv", package = "elastic"),
#'            system.file("examples", "test3.csv", package = "elastic"))
#' tt <- vapply(files, function(z) NROW(read.csv(z)), numeric(1))
#' ids <- list(1:tt[1],
#'            (tt[1] + 1):(tt[1] + tt[2]),
#'            (tt[1] + tt[2] + 1):sum(tt))
#' for (i in seq_along(files)) {
#'   d <- read.csv(files[[i]])
#'   docs_bulk(d, index = "testes", type = "docs", doc_ids = ids[[i]],
#'     es_ids = FALSE)
#' }
#' count("testes", "docs")
#' index_delete("testes")
#'
#' ## or include in the input data
#' ### from data.frame's
#' index_create("testes")
#' files <- c(system.file("examples", "test1_id.csv", package = "elastic"),
#'            system.file("examples", "test2_id.csv", package = "elastic"),
#'            system.file("examples", "test3_id.csv", package = "elastic"))
#' readLines(files[[1]])
#' for (i in seq_along(files)) {
#'   d <- read.csv(files[[i]])
#'   docs_bulk(d, index = "testes", type = "docs")
#' }
#' count("testes", "docs")
#' index_delete("testes")
#'
#' ### from lists via file inputs
#' index_create("testes")
#' for (i in seq_along(files)) {
#'   d <- read.csv(files[[i]])
#'   d <- apply(d, 1, as.list)
#'   docs_bulk(d, index = "testes", type = "docs")
#' }
#' count("testes", "docs")
#' index_delete("testes")
#'
#' # data.frame's with a single column
#' ## this didn't use to work, but now should work
#' db <- paste0(sample(letters, 10), collapse = "")
#' index_create(db)
#' res <- data.frame(foo = 1:10)
#' out <- docs_bulk(x = res, index = db)
#' count(db)
#' index_delete(db)
#' }
docs_bulk <- function(x, index = NULL, type = NULL, chunk_size = 1000,
                      doc_ids = NULL, es_ids = TRUE, raw = FALSE, ...) {

  UseMethod("docs_bulk")
}

#' @export
docs_bulk.default <- function(x, index = NULL, type = NULL, chunk_size = 1000,
                      doc_ids = NULL, es_ids = TRUE, raw = FALSE, ...) {

  stop("no 'docs_bulk' method for class ", class(x), call. = FALSE)
}

#' @export
docs_bulk.data.frame <- function(x, index = NULL, type = NULL, chunk_size = 1000,
                                 doc_ids = NULL, 
                                 es_ids = TRUE, raw = FALSE, ...) {

  if (is.null(index)) {
    stop("index can't be NULL when passing a data.frame",
         call. = FALSE)
  }
  if (is.null(type)) type <- index
  check_doc_ids(x, doc_ids)
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
  pb <- txtProgressBar(min = 0, max = length(data_chks), initial = 0, style = 3)
  on.exit(close(pb))
  resl <- vector(mode = "list", length = length(data_chks))
  for (i in seq_along(data_chks)) {
    setTxtProgressBar(pb, i)
    resl[[i]] <- docs_bulk(make_bulk(x[data_chks[[i]], , drop = FALSE], 
                                     index, type, id_chks[[i]], es_ids), ...)
  }
  return(resl)
}

#' @export
docs_bulk.list <- function(x, index = NULL, type = NULL, chunk_size = 1000,
                           doc_ids = NULL, es_ids = TRUE, raw = FALSE, ...) {

  if (is.null(index)) {
    stop("index can't be NULL when passing a list",
         call. = FALSE)
  }
  if (is.null(type)) type <- index
  check_doc_ids(x, doc_ids)
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
  pb <- txtProgressBar(min = 0, max = length(data_chks), initial = 0, style = 3)
  on.exit(close(pb))
  resl <- vector(mode = "list", length = length(data_chks))
  for (i in seq_along(data_chks)) {
    setTxtProgressBar(pb, i)
    resl[[i]] <- docs_bulk(make_bulk(x[data_chks[[i]]], index, 
                                     type, id_chks[[i]], es_ids), ...)
  }
  return(resl)
}

#' @export
docs_bulk.character <- function(x, index = NULL, type = NULL, chunk_size = 1000,
                                doc_ids = NULL, es_ids = TRUE, raw=FALSE, ...) {

  on.exit(close_conns())
  stopifnot(file.exists(x))
  url <- paste0(make_url(es_get_auth()), '/_bulk')
  tt <- POST(url, make_up(), es_env$headers, ..., 
             body = upload_file(x, type = "application/x-ndjson"), 
             encode = "json")
  geterror(tt)
  res <- cont_utf8(tt)
  res <- structure(res, class = "bulk_make")
  if (raw) res else es_parse(res)
}
