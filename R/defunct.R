#' This function is defunct
#' @export
#' @rdname mlt-defunct
#' @keywords internal
mlt <- function(...){
  .Defunct(msg = "The MLT API has been removed. See ?`elastic-defunct`")
}

#' This function is defunct
#' @export
#' @rdname nodes-defunct
#' @keywords internal
nodes_shutdown <- function(...){
  .Defunct(msg = "The _shutdown API has been removed. See ?`elastic-defunct`")
}

#' This function is defunct
#' @export
#' @rdname index_status-defunct
#' @keywords internal
index_status <- function(...) {
  .Defunct(msg = "_status route for the index API has been removed. See ?`elastic-defunct`")
}

#' Defunct functions in elastic
#'
#' \itemize{
#'  \item \code{\link{mlt}}: The MLT API has been removed, use More Like This Query 
#'  via \code{\link{Search}}
#'  \item \code{\link{nodes_shutdown}}: The _shutdown API has been removed. Instead, 
#'  setup Elasticsearch to run as a service (see Running as a Service on Linux 
#'  (\url{https://www.elastic.co/guide/en/elasticsearch/reference/2.0/setup-service.html}) or 
#'  Running as a Service on Windows 
#'  (\url{https://www.elastic.co/guide/en/elasticsearch/reference/2.0/setup-service-win.html})) 
#'  or use the -p command line option to write the PID to a file.
#'  \item \code{\link{index_status}}: _status route for the index API has been removed. 
#'  Replaced with the Indices Stats and Indices Recovery APIs.
#' }
#' 
#' @name elastic-defunct
NULL
