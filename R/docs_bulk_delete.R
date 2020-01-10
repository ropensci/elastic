#' Use the bulk API to delete documents
#'
#' @export
#' @inheritParams docs_bulk
#' @details
#'
#' For doing deletes with a file already prepared for the bulk API,
#' see [docs_bulk()]
#'
#' Only data.frame's are supported for now.
#' @family bulk-functions
#' @references
#' <https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html>
#' @examples \dontrun{
#' x <- connect()
#' if (index_exists(x, "foobar")) index_delete(x, "foobar")
#'
#' df <- data.frame(name = letters[1:3], size = 1:3, id = 100:102)
#' invisible(docs_bulk(x, df, 'foobar', es_ids = FALSE))
#' Search(x, "foobar", asdf = TRUE)$hits$hits
#'
#' # delete using doc ids from the data.frame you used to create
#' invisible(docs_bulk_delete(x, df, index = 'foobar'))
#' Search(x, "foobar", asdf = TRUE)$hits$total$value
#'
#' # delete by passing in doc ids
#' ## recreate data first
#' if (index_exists(x, "foobar")) index_delete(x, "foobar")
#' df <- data.frame(name = letters[1:3], size = 1:3, id = 100:102)
#' invisible(docs_bulk(x, df, 'foobar', es_ids = FALSE))
#' docs_bulk_delete(x, df, index = 'foobar', doc_ids = df$id)
#' Search(x, "foobar", asdf = TRUE)$hits$total$value
#' }
docs_bulk_delete <- function(conn, x, index = NULL, type = NULL,
  chunk_size = 1000, doc_ids = NULL, raw = FALSE, quiet = FALSE,
  query = list(), ...) {

  UseMethod("docs_bulk_delete", x)
}

#' @export
docs_bulk_delete.default <- function(conn, x, index = NULL, type = NULL,
  chunk_size = 1000, doc_ids = NULL, raw = FALSE, quiet = FALSE,
  query = list(), ...) {

  stop("no 'docs_bulk_delete' method for class ", class(x)[[1L]],
    call. = FALSE)
}

#' @export
docs_bulk_delete.data.frame <- make_bulk_df_generator(make_bulk_delete)

# helpers
make_bulk_delete <- function(df, index, counter, type = NULL, path = NULL) {
  if (!is.character(counter)) {
    if (max(counter) >= 10000000000) {
      scipen <- getOption("scipen")
      options(scipen = 100)
      on.exit(options(scipen = scipen))
    }
  }
  metadata_fmt <- if (is.character(counter)) {
    if (!is.null(type)) {
      '{"delete":{"_index":"%s","_type":"%s","_id":"%s"}}'
    } else {
      '{"delete":{"_index":"%s","_id":"%s"}}'
    }
  } else {
    if (!is.null(type)) {
      '{"delete":{"_index":"%s","_type":"%s","_id":%s}}'
    } else {
      '{"delete":{"_index":"%s","_id":%s}}'
    }
  }
  metadata <- if (!is.null(type)) {
    sprintf(metadata_fmt, index, type, counter)
  } else {
    sprintf(metadata_fmt, index, counter)
  }
  tmpf <- if (is.null(path)) tempfile("elastic__") else path
  write_utf8(paste(metadata, sep = "\n"), tmpf)
  invisible(tmpf)
}
