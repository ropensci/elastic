#' Scroll search function
#'
#' @export
#' 
#' @param scroll_id (character) Scroll id
#' @param scroll (character) Specify how long a consistent view of the index should be maintained 
#' for scrolled search, e.g., "30s", "1m". See \code{\link{units-time}}.
#' @param raw If TRUE (default), data is parsed to list. If FALSE, then raw JSON.
#' @param ... Curl args passed on to \code{\link[httr]{POST}}
#' @seealso \code{\link{Search}}
#' @examples \dontrun{
#' # Get a scroll_id
#' res <- Search(index = 'shakespeare', q="a*", scroll="1m")
#' res$`_scroll_id`
#' 
#' # Setting search_type=scan turns off sorting of results, is faster
#' res <- Search(index = 'shakespeare', q="a*", scroll="1m", search_type = "scan")
#' res$`_scroll_id`
#' 
#' # Pass scroll_id to scroll function
#' scroll(scroll_id = res$`_scroll_id`)
#' 
#' # Get all results - one approach is to use a while loop
#' res <- Search(index = 'shakespeare', q="a*", scroll="5m", search_type = "scan")
#' out <- list()
#' hits <- 1
#' while(hits != 0){
#'   res <- scroll(scroll_id = res$`_scroll_id`)
#'   hits <- length(res$hits$hits)
#'   if(hits > 0)
#'     out <- c(out, res$hits$hits)
#' }
#' length(out)
#' out[[1]]
#' }

scroll <- function(scroll_id, scroll="1m", raw=FALSE, ...){
  scroll_POST(path = "_search/scroll", args=list(scroll=scroll), body=scroll_id, raw=raw, ...)
}
