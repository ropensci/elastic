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
#' @param raw (logical) Get raw JSON back or not.
#' @param ... Pass on curl options to \code{\link[httr]{POST}}
#' @details More on the Bulk API:
#' \url{http://www.elasticsearch.org/guide/en/elasticsearch/guide/current/bulk.html}.
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
#' docs_bulk(mtcars, "hello", "world")
#' docs_bulk(iris, "iris", "flowers")
#' ## type can be missing, but index can not
#' docs_bulk(iris, "flowers")
#' ## big data.frame, 53K rows
#' res <- docs_bulk(diamonds, "diam")
#' Search("diam")$hits$total
#' 
#' # From a list
#' docs_bulk(apply(iris, 1, as.list), index="iris", type="flowers")
#' docs_bulk(apply(USArrests, 1, as.list), index="arrests")
#' dim_list <- apply(diamonds, 1, as.list)
#' out <- docs_bulk(dim_list, index="diamfromlist")
#' }
docs_bulk <- function(x, index = NULL, type = NULL, chunk_size = 1000, raw=FALSE, ...) {
  UseMethod("docs_bulk")
}

#' @export
docs_bulk.data.frame <- function(x, index = NULL, type = NULL, chunk_size = 1000, raw = FALSE, ...) {
  checkconn()
  if (is.null(index)) {
    stop("index can't be NULL when passing a data.frame")
  }
  if (is.null(type)) type <- index
  row.names(x) <- NULL
  rws <- seq_len(NROW(x))
  chks <- split(rws, ceiling(seq_along(rws) / chunk_size))
  pb <- txtProgressBar(min = 0, max = length(chks), initial = 0, style = 3)
  for (i in seq_along(chks)) {
    setTxtProgressBar(pb, i)
    docs_bulk(make_bulk(x[chks[[i]], ], index, type, chks[[i]]), ...)
  }
}

#' @export
docs_bulk.list <- function(x, index = NULL, type = NULL, chunk_size = 1000, raw = FALSE, ...) {
  checkconn()
  if (is.null(index)) {
    stop("index can't be NULL when passing a list")
  }
  if (is.null(type)) type <- index
  x <- unname(x)
  rws <- seq_len(length(x))
  chks <- split(rws, ceiling(seq_along(rws) / chunk_size))
  pb <- txtProgressBar(min = 0, max = length(chks), initial = 0, style = 3)
  for (i in seq_along(chks)) {
    setTxtProgressBar(pb, i)
    docs_bulk(make_bulk(x[chks[[i]]], index, type, chks[[i]]), ...)
  }
}

#' @export
docs_bulk.character <- function(x, index = NULL, type = NULL, chunk_size = 1000, raw=FALSE, ...) {
  checkconn()
  stopifnot(file.exists(x))
  conn <- es_get_auth()
  url <- paste0(conn$base, ":", conn$port, '/_bulk')
  tt <- POST(url, body = upload_file(x, type = "application/json"), ..., encode = "json")
  if (tt$status_code > 202) {
    if (tt$status_code > 202) stop(content(tt)$error)
    if (content(tt)$status == "ERROR" | content(tt)$status == 500) stop(content(tt)$error_message)
  }
  res <- content(tt, as = "text")
  res <- structure(res, class = "bulk_make")
  if (raw) res else es_parse(res)
}

make_bulk <- function(df, index, type, counter) {
  metadata_fmt <- '{"index":{"_index":"%s","_type":"%s","_id":%d}}'
  metadata <- sprintf(metadata_fmt, index, type, counter - 1L)
  data <- jsonlite::toJSON(df, collapse = FALSE)
  tmpf <- tempfile()
  writeLines(paste(metadata, data, sep = "\n"), tmpf)
  invisible(tmpf)
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
