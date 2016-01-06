#' elastic: An Elasticsearch R client.
#'
#' @section About:
#'
#' This package gives you access to local or remote Elasticsearch databases.
#'
#' @section Quick start:
#'
#' If you're connecting to a Elasticsearch server already running, skip ahead to \bold{Search}.
#'
#' Install Elasticsearch (on OSX)
#' \itemize{
#'  \item Download zip or tar file from Elasticsearch see here for download:
#'  \url{https://www.elastic.co/downloads/elasticsearch}
#'  \item Unzip it: \code{untar elasticsearch-2.1.1.tar.gz}
#'  \item Move it: \code{sudo mv elasticsearch-2.1.1 /usr/local}
#'  (replace version with your version)
#'  \item Navigate to /usr/local: \code{cd /usr/local}
#'  \item Add shortcut: \code{sudo ln -s elasticsearch-2.1.1 elasticsearch}
#'  (replace version with your verioon)
#' }
#'
#' For help on other platforms, see
#' \url{https://www.elastic.co/guide/en/elasticsearch/reference/current/_installation.html}
#'
#' \bold{Start Elasticsearch}
#'
#' \itemize{
#'  \item Navigate to elasticsearch: \code{cd /usr/local/elasticsearch}
#'  \item Start elasticsearch: \code{bin/elasticsearch}
#' }
#'
#' \bold{Initialization:}
#'
#' The function \code{\link{connect}} is used before doing anything else to set
#' the connection details to your remote or local elasticsearch store. The
#' details created by \code{\link{connect}} are written to your options for the
#' current session, and are used by \code{elastic} functions.
#'
#' \bold{Search:}
#'
#' The main way to search Elasticsearch is via the \code{\link{Search}} function. E.g.:
#'
#' \code{Search()}
#'
#' @section Security:
#'
#' Elasticsearch is insecure out of the box! If you are running Elasticsearch
#' locally on your own machine without exposing a port to the outside world, no
#' worries, but if you install on a server with a public IP address, take the
#' necessary precautions. There are a few options:
#'
#' \itemize{
#'  \item Shield \url{https://www.elastic.co/products/shield} - This is a paid
#'  product - so probably only applicable to enterprise users
#'  \item DIY security - there are a variety of techniques for securing your
#'  Elasticsearch. I collected a number of resources in a blog post at
#'  \url{http://recology.info/2015/02/secure-elasticsearch/}
#' }
#'
#' @section Elasticsearch changes:
#' As of Elasticsearch v2:
#' \itemize{
#'  \item You can no longer create fields with dots in the name.
#'  \item Type names may not start with a dot (other than the special \code{.percolator} type)
#'  \item Type names may not be longer than 255 characters
#'  \item Types may no longer be deleted
#'  \item Queries and filters have been merged - all filter clauses are now query clauses.
#'     Instead, query clauses can now be used in query context or in filter context. See
#'     examples in \code{\link{Search}} or \code{\link{Search_uri}}
#'}
#'
#' @importFrom utils read.table read.delim txtProgressBar setTxtProgressBar URLdecode modifyList
#' @importFrom methods is
#' @importFrom httr HEAD GET POST PUT DELETE content authenticate stop_for_status upload_file http_status
#' @importFrom curl curl_escape
#' @importFrom jsonlite fromJSON toJSON
#' @docType package
#' @aliases elastic-package
#' @author Scott Chamberlain \email{myrmecocystus@@gmail.com}
#' @name elastic
NULL
