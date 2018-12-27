#' Get the basic info from the current cluster
#'
#' @export
#' @param ... Further args passed on to print for the es_conn class.
#' @examples \dontrun{
#' connect()
#' info()
#' }
# info <- function(...) {
#   res <- tryCatch(GET(make_url(es_get_auth()), make_up(), ...), error = function(e) e)
#   if (inherits(res, "error")) {
#     stop(sprintf("\n  Failed to connect to %s\n  Remember to start Elasticsearch before connecting", 
#                  make_url(es_get_auth())), call. = FALSE)
#   }
#   if (res$status_code > 200) {
#     stop(sprintf("Error:", res$headers$statusmessage), call. = FALSE)
#   }
#   tt <- cont_utf8(res)
#   jsonlite::fromJSON(tt, FALSE)
# }
