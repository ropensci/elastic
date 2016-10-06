#' Allowed HTTP status codes
#' 
#' @export
#' @param ... HTTP status codes, either numeric, integer, or character
#' @details xxxx
#' @return An S3 object of class \code{allstat} to be passed to
#' @references \url{https://en.wikipedia.org/wiki/List_of_HTTP_status_codes}
#' @examples \dontrun{
#' allowed_status_codes(404)
#' allowed_status_codes(400, 404, 406)
#' }
allowed_status_codes <- function(...) {
  structure(unlist(list(...)), class = "allowed_status_codes")
}

print.allowed_status_codes <- function(x, ...) {
  cat('<allowed status codes>', sep = "\n")
  cat(paste('   allowed: ', paste0(x, collapse = ", ")), "\n")
}
