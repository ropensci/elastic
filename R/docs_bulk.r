#' Use the bulk API to create, index, update, or delete documents.
#'
#' @export
#' @param x A data.frame or path to a file to load in the bulk API
#' @param index (character) The index name to use. Required for data.frame input, but
#' optional for file inputs.
#' @param type (character) The type name to use. If left as NULL, will be same name as index.
#' @param chunk_size (integer) Size of each chunk. If your data.frame is smaller
#' thank \code{chunk_size}, this parameter is essentially ignored. We write in chunks because
#' at some point, depending on size of each document, and Elasticsearch setup, writing a very
#' large number of documents in one go becomes slow, so chunking can help. This parameter
#' is ignored if you pass a file name. Default: 1000
#' @param doc_ids An optional vector (character or numeric/integer) of document ids to use.
#' This vector has to equal the size of the documents you are passing in, and will error
#' if not. If you pass a factor we convert to character. Default: not passed
#' @param raw (logical) Get raw JSON back or not.
#' @param ... Pass on curl options to \code{\link[httr]{POST}}
#' @details More on the Bulk API:
#' \url{https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html}.
#'
#' This function dispatches on data.frame or character input. Character input has
#' to be a file name or the function stops with an error message.
#'
#' If you pass a data.frame to this function, we by default to an index operation,
#' that is, create the record in the index and type given by those parameters to the
#' function. Down the road perhaps we will try to support other operations on the
#' bulk API. if you pass a file, of course in that file, you can specify any
#' operations you want.
#'
#' Row names are dropped from data.frame, and top level names for a list are dropped
#' as well.
#'
#' A progress bar gives the progress for data.frames and lists
#'
#' @section Large numbers for document IDs:
#' Until recently, if you had very large integers for document IDs, \code{docs_bulk}
#' failed. It should be fixed now. Let us know if not.
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
#' ## We internally get last _id counter to know where to start on next bulk insert
#' ## but you need to sleep in between docs_bulk calls, longer the bigger the data is
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
#'   docs_bulk(d, index = "testes", type = "docs", doc_ids = ids[[i]])
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
#' }
docs_bulk <- function(x, index = NULL, type = NULL, chunk_size = 1000,
                      doc_ids = NULL, raw=FALSE, ...) {

  UseMethod("docs_bulk")
}

#' @export
docs_bulk.data.frame <- function(x, index = NULL, type = NULL, chunk_size = 1000,
                                 doc_ids = NULL, raw = FALSE, ...) {

  checkconn()
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
  for (i in seq_along(data_chks)) {
    setTxtProgressBar(pb, i)
    docs_bulk(make_bulk(x[data_chks[[i]], ], index, type, id_chks[[i]]), ...)
  }
}

#' @export
docs_bulk.list <- function(x, index = NULL, type = NULL, chunk_size = 1000,
                           doc_ids = NULL, raw = FALSE, ...) {

  checkconn()
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
  for (i in seq_along(data_chks)) {
    setTxtProgressBar(pb, i)
    docs_bulk(make_bulk(x[data_chks[[i]]], index, type, id_chks[[i]]), ...)
  }
}

#' @export
docs_bulk.character <- function(x, index = NULL, type = NULL, chunk_size = 1000,
                                doc_ids = NULL, raw=FALSE, ...) {

  on.exit(close_conns())
  checkconn()
  stopifnot(file.exists(x))
  conn <- es_get_auth()
  url <- paste0(conn$base, ":", conn$port, '/_bulk')
  tt <- POST(url, make_up(), ..., body = upload_file(x, type = "application/json"), encode = "json")
  if (tt$status_code > 202) {
    if (tt$status_code > 202) stop(content(tt)$error)
    if (content(tt)$status == "ERROR" | content(tt)$status == 500) stop(content(tt)$error_message)
  }
  res <- content(tt, as = "text")
  res <- structure(res, class = "bulk_make")
  if (raw) res else es_parse(res)
}

make_bulk <- function(df, index, type, counter) {
  if (!is.character(counter)) {
    if (max(counter) >= 10000000000) {
      scipen <- getOption("scipen")
      options(scipen = 100)
      on.exit(options(scipen = scipen))
    }
  }
  metadata_fmt <- if (is.character(counter)) {
    '{"index":{"_index":"%s","_type":"%s","_id":"%s"}}'
  } else {
    '{"index":{"_index":"%s","_type":"%s","_id":%s}}'
  }
  metadata <- sprintf(
    metadata_fmt,
    index,
    type,
    if (is.numeric(counter)) {
      counter - 1L
    } else {
      counter
    }
  )
  data <- jsonlite::toJSON(df, collapse = FALSE)
  tmpf <- tempfile("elastic__")
  writeLines(paste(metadata, data, sep = "\n"), tmpf)
  invisible(tmpf)
}

shift_start <- function(vals, index, type = NULL) {
  num <- tryCatch(count(index, type), error = function(e) e)
  if (is(num, "error")) {
    vals
  } else {
    vals + num
  }
}

check_doc_ids <- function(x, ids) {
  if (!is.null(ids)) {
    # check class type
    if (!class(ids) %in% c('character', 'factor', 'numeric', 'integer')) {
      stop("doc_ids must be of class character, numeric or integer", call. = FALSE)
    }

    # check appropriate length
    if (!all(1:NROW(x) == 1:length(ids))) {
      stop("doc_ids length must equal number of documents", call. = FALSE)
    }
  }
}

has_ids <- function(x) {
  if (is(x, "data.frame")) {
    "id" %in% names(x)
  } else if (is(x, "list")) {
    ids <- ec(sapply(x, "[[", "id"))
    if (length(ids) > 0) {
      tmp <- length(ids) == length(x)
      if (tmp) TRUE else stop("id field not in every document", call. = FALSE)
    } else {
      FALSE
    }
  } else {
    stop("input must be list or data.frame", call. = FALSE)
  }
}

close_conns <- function() {
  cons <- showConnections()
  ours <- as.integer(rownames(cons)[grepl("/elastic__", cons[, "description"], fixed = TRUE)])
  for (i in ours) {
    close(getConnection(i))
  }
}

check_named_vectors <- function(x) {
  lapply(x, function(z) {
    if (!is(z, "list")) {
      as.list(z)
    } else {
      z
    }
  })
}

# make_bulk_plos(index_name='plosmore', fields=c('id','journal','title','abstract','author'), filename="inst/examples/plos_more_data.json")
make_bulk_plos <- function(n = 1000, index='plos', type='article', fields=c('id','title'), filename = "~/plos_data.json"){
  unlink(filename)
  args <- ec(list(q = "*:*", rows=n, fl=paste0(fields, collapse = ","), fq='doc_type:full', wt='json'))
  res <- GET("http://api.plos.org/search", query=args)
  stop_for_status(res)
  tt <- jsonlite::fromJSON(content(res, as = "text"), FALSE)
  docs <- tt$response$docs
  docs <- lapply(docs, function(x){
    x[sapply(x, length)==0] <- "null"
    lapply(x, function(y) if(length(y) > 1) paste0(y, collapse = ",") else y)
  })
  for(i in seq_along(docs)){
    dat <- list(index = list(`_index` = index, `_type` = type, `_id` = i-1))
    cat(proc_doc(dat), sep = "\n", file = filename, append = TRUE)
    cat(proc_doc(docs[[i]]), sep = "\n", file = filename, append = TRUE)
  }
  message(sprintf("File written to %s", filename))
}

proc_doc <- function(x){
  b <- jsonlite::toJSON(x, auto_unbox = TRUE)
  gsub("\\[|\\]", "", as.character(b))
}

# make_bulk_gbif(900, filename="inst/examples/gbif_data.json")
# make_bulk_gbif(600, "gbifgeo", filename="inst/examples/gbif_geo.json", add_coordinates = TRUE)
make_bulk_gbif <- function(n = 600, index='gbif', type='record', filename = "~/gbif_data.json", add_coordinates=FALSE){
  unlink(filename)
  res <- lapply(seq(1, n, 300), getgbif)
  res <- do.call(c, res)
  res <- lapply(res, function(x){
    x[sapply(x, length)==0] <- "null"
    lapply(x, function(y) if(length(y) > 1) paste0(y, collapse = ",") else y)
  })
  if(add_coordinates) res <- lapply(res, function(x) c(x, coordinates = sprintf("[%s,%s]", x$decimalLongitude, x$decimalLatitude)))
  for(i in seq_along(res)){
    dat <- list(index = list(`_index` = index, `_type` = type, `_id` = i-1))
    cat(proc_doc(dat), sep = "\n", file = filename, append = TRUE)
    cat(proc_doc(res[[i]]), sep = "\n", file = filename, append = TRUE)
  }
  message(sprintf("File written to %s", filename))
}

getgbif <- function(x){
  res <- GET("http://api.gbif.org/v1/occurrence/search", query=list(limit=300, offset=x))
  jsonlite::fromJSON(content(res, "text"), FALSE)$results
}
