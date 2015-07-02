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
#'  \item Unzip it: \code{untar elasticsearch-1.5.2.tar.gz}
#'  \item Move it: \code{sudo mv /path/to/elasticsearch-1.5.2 /usr/local}
#'  (replace version with your version)
#'  \item Navigate to /usr/local: \code{cd /usr/local}
#'  \item Add shortcut: \code{sudo ln -s elasticsearch-1.5.2 elasticsearch}
#'  (replace version with your verioon)
#' }
#'
#' For help on other platforms, see
#' \url{http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/_installation.html}
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
#' @importFrom utils read.table txtProgressBar setTxtProgressBar URLdecode modifyList
#' @importFrom methods is
#' @importFrom httr HEAD GET POST PUT DELETE content authenticate stop_for_status upload_file http_status
#' @importFrom curl curl_escape
#' @docType package
#' @aliases elastic-package
#' @author Scott Chamberlain \email{myrmecocystus@@gmail.com}
#' @name elastic
NULL
