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
#' @family bulk-functions
#' @references <https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html#bulk-update>
#' @examples \dontrun{
#' x <- connect()
#' if (index_exists(x, "foobar")) index_delete(x, "foobar")
#' 
#' df <- data.frame(name = letters[1:3], size = 1:3, id = 100:102)
#' invisible(docs_bulk(x, df, 'foobar', 'foobar', es_ids = FALSE))
#' 
#' # add new rows in existing fields
#' (df2 <- data.frame(size = c(45, 56), id = 100:101))
#' Search(x, "foobar", asdf = TRUE)$hits$hits
#' invisible(docs_bulk_update(x, df2, index = 'foobar', type = 'foobar'))
#' Search(x, "foobar", asdf = TRUE)$hits$hits
#' 
#' # add new fields (and new rows by extension)
#' (df3 <- data.frame(color = c("blue", "red", "green"), id = 100:102))
#' Search(x, "foobar", asdf = TRUE)$hits$hits
#' invisible(docs_bulk_update(x, df3, index = 'foobar', type = 'foobar'))
#' Sys.sleep(2) # wait for a few sec to make sure you see changes reflected
#' Search(x, "foobar", asdf = TRUE)$hits$hits
#' }
docs_bulk_update <- function(conn, x, index = NULL, type = NULL, chunk_size = 1000,
                             doc_ids = NULL, raw = FALSE, ...) {
  
  UseMethod("docs_bulk_update", x)
}

#' @export
docs_bulk_update.default <- function(conn, x, index = NULL, type = NULL, 
                                     chunk_size = 1000, doc_ids = NULL, 
                                     raw = FALSE, quiet = FALSE, ...) {
  
  stop("no 'docs_bulk_update' method for class ", class(x)[[1L]], 
    call. = FALSE)
}

#' @export
docs_bulk_update.data.frame <- make_bulk_df_generator(make_bulk_update)

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
  
  df$id <- NULL
  
  data <- lapply(seq_len(nrow(df)), function(i) {
    z <- list(doc = jsonlite::unbox(df[i,,drop=FALSE]), doc_as_upsert = TRUE)
    jsonlite::toJSON(z, auto_unbox = TRUE, na = "null", null = "null")
  })

  tmpf <- if (is.null(path)) tempfile("elastic__") else path
  write_utf8(paste(metadata, data, sep = "\n"), tmpf)
  invisible(tmpf)
}
