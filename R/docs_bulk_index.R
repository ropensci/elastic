#' Use the bulk API to index documents
#' 
#' @export
#' @inheritParams docs_bulk
#' @details 
#' 
#' For doing index with a file already prepared for the bulk API, 
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
#' docs_bulk_index(x, df, 'foobar', 'foobar')
#' docs_bulk_index(x, df, 'foobar', 'foobar', es_ids = FALSE)
#' Search(x, "foobar", asdf = TRUE)$hits$hits
#' 
#' # more examples
#' docs_bulk_index(x, mtcars, index = "hello", type = "world")
#' ## field names cannot contain dots
#' names(iris) <- gsub("\\.", "_", names(iris))
#' docs_bulk_index(x, iris, "iris", "flowers")
#' ## type can be missing, but index can not
#' docs_bulk_index(x, iris, "flowers")
#' ## big data.frame, 53K rows, load ggplot2 package first
#' # res <- docs_bulk_index(x, diamonds, "diam")
#' # Search(x, "diam")$hits$total
#' }
docs_bulk_index <- function(conn, x, index = NULL, type = NULL, chunk_size = 1000,
  doc_ids = NULL, es_ids = TRUE, raw = FALSE, quiet = FALSE, ...) {
  
  UseMethod("docs_bulk_index", x)
}

#' @export
docs_bulk_index.default <- function(conn, x, index = NULL, type = NULL, 
  chunk_size = 1000, doc_ids = NULL, es_ids = TRUE, raw = FALSE, 
  quiet = FALSE, ...) {
  
  stop("no 'docs_bulk_index' method for class ", class(x)[[1L]], 
    call. = FALSE)
}

#' @export
docs_bulk_index.data.frame <- bulk_ci_generator()
