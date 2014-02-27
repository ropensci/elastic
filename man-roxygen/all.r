#' @param conn Connection object describing base url, port, and any authentication 
#' details.
#' @param index Index
#' @param type Document type
#' @param raw If TRUE (default), data is parsed to list. If FALSE, then raw JSON.
#' @param callopts Curl args passed on to httr::POST.
#' @param verbose If TRUE (default) the url call used printed to console.
#' @param ... Further args passed on to elastic search HTTP API as parameters.