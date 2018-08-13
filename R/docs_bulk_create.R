#' Use the bulk API to create documents
#' 
#' @export
#' @inheritParams docs_bulk
#' @details 
#' 
#' For doing create with a file already prepared for the bulk API, 
#' see [docs_bulk()]
#' 
#' Only data.frame's are supported for now.
#' @family bulk-functions
#' @references 
#' <https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html>
#' @examples \dontrun{
#' connect()
#' if (index_exists("foobar")) index_delete("foobar")
#' 
#' df <- data.frame(name = letters[1:3], size = 1:3, id = 100:102)
#' docs_bulk_create(df, 'foobar', 'foobar', es_ids = FALSE)
#' Search("foobar", asdf = TRUE)$hits$hits
#' 
#' # more examples
#' docs_bulk_create(mtcars, index = "hello", type = "world")
#' ## field names cannot contain dots
#' names(iris) <- gsub("\\.", "_", names(iris))
#' docs_bulk_create(iris, "iris", "flowers")
#' ## type can be missing, but index can not
#' docs_bulk_create(iris, "flowers")
#' ## big data.frame, 53K rows, load ggplot2 package first
#' # res <- docs_bulk_create(diamonds, "diam")
#' # Search("diam")$hits$total
#' }
docs_bulk_create <- function(x, index = NULL, type = NULL, chunk_size = 1000,
  doc_ids = NULL, es_ids = TRUE, raw = FALSE, quiet = FALSE, ...) {
  
  UseMethod("docs_bulk_create")
}

#' @export
docs_bulk_create.default <- function(x, index = NULL, type = NULL, 
  chunk_size = 1000, doc_ids = NULL, es_ids = FALSE, raw = FALSE, 
  quiet = FALSE, ...) {
  
  stop("no 'docs_bulk_create' method for class ", class(x)[[1L]], 
    call. = FALSE)
}

#' @export
docs_bulk_create.data.frame <- bulk_ci_generator("create", FALSE)
