#' Use the bulk API to update documents
#' 
#' @export
#' @inheritParams docs_bulk
#' @details 
#' 
#' - `doc_as_upsert` - is set to `TRUE` for all records 
#' 
#' For doing updates with a file already prepared for the bulk API, 
#' see [docs_bulk()]
#' 
#' Only data.frame's are supported for now.
#' @seealso [docs_bulk()] [docs_bulk_prep()]
#' @references <https://www.elastic.co/guide/en/elasticsearch/reference/6.2/docs-bulk.html#bulk-update>
#' @examples \dontrun{
#' connect()
#' if (index_exists("foobar")) index_delete("foobar")
#' 
#' df <- data.frame(name = letters[1:3], size = 1:3, id = 100:102)
#' invisible(docs_bulk(df, 'foobar', 'foobar', es_ids = FALSE))
#' 
#' # add new rows in existing fields
#' (df2 <- data.frame(size = c(45, 56), id = 100:101))
#' Search("foobar", asdf = TRUE)$hits$hits
#' invisible(docs_bulk_update(df2, index = 'foobar', type = 'foobar'))
#' Search("foobar", asdf = TRUE)$hits$hits
#' 
#' # add new fields (and new rows by extension)
#' (df3 <- data.frame(color = c("blue", "red", "green"), id = 100:102))
#' Search("foobar", asdf = TRUE)$hits$hits
#' invisible(docs_bulk_update(df3, index = 'foobar', type = 'foobar'))
#' Search("foobar", asdf = TRUE)$hits$hits
#' }
docs_bulk_update <- function(x, index = NULL, type = NULL, chunk_size = 1000,
                             doc_ids = NULL, raw = FALSE, ...) {
  
  UseMethod("docs_bulk_update")
}

#' @export
docs_bulk_update.default <- function(x, index = NULL, type = NULL, 
                                     chunk_size = 1000, doc_ids = NULL, 
                                     raw = FALSE, quiet = FALSE, ...) {
  
  stop("no 'docs_bulk_update' method for class ", class(x)[[1L]], 
    call. = FALSE)
}

#' @export
docs_bulk_update.data.frame <- function(x, index = NULL, type = NULL, 
                                        chunk_size = 1000, doc_ids = NULL, 
                                        raw = FALSE, quiet = FALSE, ...) {
  
  assert(quiet, "logical")
  if (is.null(index)) {
    stop("index can't be NULL when passing a data.frame",
         call. = FALSE)
  }
  if (is.null(type)) type <- index
  check_doc_ids(x, doc_ids)
  # make sure document ids passed 
  if (!'id' %in% names(x) && is.null(doc_ids)) {
    stop('data.frame must have a column "id" or pass param "doc_ids"')
  }
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
    resl[[i]] <- docs_bulk(make_bulk_update(x[data_chks[[i]], , drop = FALSE], 
                                     index, type, id_chks[[i]]), ...)
  }
  return(resl)
}

# helpers
make_bulk_update <- function(df, index, type, counter, path = NULL) {
  if (!is.character(counter)) {
    if (max(counter) >= 10000000000) {
      scipen <- getOption("scipen")
      options(scipen = 100)
      on.exit(options(scipen = scipen))
    }
  }
  metadata_fmt <- if (is.character(counter)) {
    '{"update":{"_index":"%s","_type":"%s","_id":"%s"}}'
  } else {
    '{"update":{"_index":"%s","_type":"%s","_id":%s}}'
  }
  
  metadata <- sprintf(
    metadata_fmt,
    index,
    type,
    counter
  )
  
  tmp <- lapply(seq_len(nrow(df)), function(i) {
    r <- df[i,]
    r$id <- NULL
    list(doc = as.list(r), doc_as_upsert = TRUE)
  })

  data <- lapply(tmp, jsonlite::toJSON, na = "null", auto_unbox = TRUE)
  tmpf <- if (is.null(path)) tempfile("elastic__") else path
  write_utf8(paste(metadata, data, sep = "\n"), tmpf)
  invisible(tmpf)
}
