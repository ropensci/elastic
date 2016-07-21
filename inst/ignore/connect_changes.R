#' Set connection details to an Elasticsearch engine.
#'
#' @name connect
#' @export
#'
#' @param es_host (character) The base host, defaults to \code{127.0.0.1}
#' @param es_port (character) port to connect to, defaults to \code{9200} (optional)
#' @param es_transport_schema (character) http or https. Default: \code{http}
#' @param es_user (character) User name, if required for the connection. You can specify,
#' but ignored for now.
#' @param es_pwd (character) Password, if required for the connection. You can specify, but
#' ignored for now.
#' @param force (logical) Force re-load of connection details
#' @param errors (character) One of simple (Default) or complete. Simple gives http code and
#' error message on an error, while complete gives both http code and error message,
#' and stack trace, if available.
#' @param headers Either an object of class \code{request} or a list that can be coerced to
#' an object of class \code{request} via \code{\link[httr]{add_headers}}. These headers are
#' used in all requests. To use headers in individual requests and not others, pass in
#' headers using \code{\link[httr]{add_headers}} via \code{...} in a function call.
#' @param ... Further args passed on to print for the es_conn class.
#' @param es_base (character) Deprecated, use \code{es_host}
#'
#' @details The default configuration is set up for localhost access on port 9200,
#' with no username or password.
#'
#' \code{\link{connection}} does not ping the Elasticsearch server, but only
#' prints connection details.
#'
#' On package load, \code{\link{connect}} is run to set the default base url and port.
#'
#' Internally, we store your preferences with environment variables. That means you
#' can set your env vars permanently in .Renviron file, and use them on a server e.g.,
#' as private env vars.
#'
#' @examples \dontrun{
#' # the default is set to localhost and port 9200
#' connect()
#'
#' # or set to a different base url
#' # connect('162.243.152.53')
#'
#' # See connection details
#' connection()
#'
#' # set headers
#' library('httr')
#'
#' connect(headers = list(a = 5))
#'
#' ## or
#' connect(headers = httr::add_headers(a = 5))
#'
#' ## use a proxy
#' connect(headers = use_proxy(url = "189.219.131.88", port = 16003))
#' }
connect <- function(es_host = "127.0.0.1", es_port = 9200,
                    es_transport_schema = "http", es_user = NULL,
                    es_pwd = NULL, force = FALSE, errors = "simple",
                    es_base = NULL, headers = NULL, ...) {

  calls <- names(sapply(match.call(), deparse))[-1]
  calls_vec <- "es_base" %in% calls
  if (any(calls_vec)) {
    stop("The parameter es_base has been deprecated, use es_host", call. = FALSE)
  }

  # strip off transport if found
  if (grepl("^http[s]?://", es_host)) {
    message("Found http or https on es_host, stripping off, see the docs")
    es_host <- sub("^http[s]?://", "", es_host)
  }

  auth <- es_auth(es_host = es_host, es_port = es_port,
                  es_transport_schema = es_transport_schema, es_user = es_user,
                  es_pwd = es_pwd, force = force)
  if (is.null(auth$port) || nchar(auth$port) == 0) {
    baseurl <- sprintf("%s://%s", auth$transport, auth$host)
  } else {
    baseurl <- sprintf("%s://%s:%s", auth$transport, auth$host, auth$port)
  }

  userpwd <- if (!is.null(es_user) && !is.null(es_pwd)) {
    authenticate(es_user, es_pwd)
  } else {
    NULL
  }

  # cache headers in an environment
  rm(list = ls(envir = es_env), envir = es_env)
  es_env$headers <- as_headers(headers)

  res <- tryCatch(GET(baseurl, c(userpwd, es_env$headers, ...)), error = function(e) e)
  connecterror(res, baseurl)
  tt <- cont_utf8(res)
  out <- jsonlite::fromJSON(tt, FALSE)

  # errors
  errors <- match.arg(errors, c('simple', 'complete'))
  Sys.setenv("ELASTIC_RCLIENT_ERRORS" = errors)

  structure(list(
    host = auth$host,
    port = auth$port,
    transport = auth$transport,
    user = es_user,
    pwd = es_pwd,
    es_deets = out,
    headers = es_env$headers,
    errors = Sys.getenv("ELASTIC_RCLIENT_ERRORS")),
    class = 'es_conn')
}

connecterror <- function(z, url) {
  UseMethod('connecterror')
}

connecterror.error <- function(z, url) {
  msg <- sprintf("\n  Failed to connect to %s\n  Remember to start Elasticsearch before connecting", url)
  stop(msg, call. = FALSE)
}

connecterror.response <- function(z, url) {
  httr::stop_for_status(z)
}

#' @export
#' @rdname connect
connection <- function() {
  auth <- list(host = Sys.getenv("ES_HOST"),
               port = Sys.getenv("ES_PORT"),
               transport = Sys.getenv("ES_TRANSPORT"),
               user = Sys.getenv("ES_USER"))
  if (is.null(auth$port) || nchar(auth$port) == 0) {
    baseurl <- sprintf("%s://%s", auth$transport, auth$host)
  } else {
    baseurl <- sprintf("%s://%s:%s", auth$transport, auth$host, auth$port)
  }
  res <- tryCatch(GET(baseurl, make_up()), error = function(e) e)
  if ("error" %in% class(res)) {
    stop(sprintf("\n  Failed to connect to %s\n  Remember to start Elasticsearch before connecting", baseurl), call. = FALSE)
  }
  if (res$status_code > 200) {
    stop(sprintf("Error:", res$headers$statusmessage), call. = FALSE)
  }
  tt <- cont_utf8(res)
  out <- jsonlite::fromJSON(tt, FALSE)
  structure(list(
    transport = auth$transport,
    host = auth$host,
    port = auth$port,
    user = auth$user,
    pwd = "<secret>",
    es_deets = out,
    headers = es_env$headers,
    errors = Sys.getenv("ELASTIC_RCLIENT_ERRORS")),
    class = 'es_conn')
}

#' @export
print.es_conn <- function(x, ...){
  fun <- function(x) ifelse(is.null(x), 'NULL', x)
  cat(paste('transport: ', fun(x$transport)), "\n")
  cat(paste('host:      ', fun(x$host)), "\n")
  cat(paste('port:     ', fun(x$port)), "\n")
  cat(paste('headers (names): ', ph(x)), "\n")
  cat(paste('username: ', fun(x$user)), "\n")
  cat(paste('password: ', fun(x$pwd)), "\n")
  cat(paste('errors:   ', fun(x$errors)), "\n")
  cat(paste('Elasticsearch (ES) details:  '), "\n")
  cat(paste('   name:                   ', fun(x$es_deets$name)), "\n")
  cat(paste('   ES version:             ', fun(x$es_deets$version$number)), "\n")
  cat(paste('   ES version timestamp:   ', fun(x$es_deets$version$build_timestamp)), "\n")
  cat(paste('   ES build hash:          ', fun(x$es_deets$version$build_hash)), "\n")
  cat(paste('   lucene version:         ', fun(x$es_deets$version$lucene_version)))
}


#' Set authentication details
#' @keywords internal
#' @param es_host (character) Base url
#' @param es_port (character) Port
#' @param es_transport_schema (character) http or https. Default: \code{http}
#' @param es_user (character) User name
#' @param es_pwd (character) Password
#' @param force (logical) Force update
#' @param es_base (character) deprecated, use es_host
es_auth <- function(es_host = NULL, es_port = NULL, es_transport_schema = NULL,
                    es_user = NULL, es_pwd = NULL, force = FALSE, es_base = NULL) {

  calls <- names(sapply(match.call(), deparse))[-1]
  calls_vec <- "es_base" %in% calls
  if (any(calls_vec)) {
    stop("The parameter es_base has been deprecated, use es_host", call. = FALSE)
  }

  host <- ifnull(es_host, 'ES_HOST')
  port <- if (is.null(es_port)) "" else es_port
  transport <- ifnull(es_transport_schema, 'ES_TRANSPORT_SCHEMA')
  user <- ifnull(es_user, 'ES_USER')
  pwd <- ifnull(es_pwd, 'ES_PWD')

  if (identical(host, "") || force) {
    if (!interactive()) {
      stop("Please set env var ES_HOST for your host url for your Elasticsearch server",
           call. = FALSE)
    }
    message("Couldn't find env var ES_HOST See ?es_auth for more details.")
    message("Please enter your Elasticsearch host url and press enter:")
    host <- readline(": ")
    if (identical(host, "")) {
      stop("Elasticsearch host url entry failed", call. = FALSE)
    }
    message("Updating ES_HOST env var\n")
    Sys.setenv(ES_HOST = host)
  } else {
    host <- host
  }

  Sys.setenv(ES_HOST = host)
  Sys.setenv(ES_TRANSPORT = transport)
  Sys.setenv(ES_PORT = port)
  Sys.setenv(ES_USER = user)
  Sys.setenv(ES_PWD = pwd)
  list(host = host, port = port, transport = transport)
}

ifnull <- function(x, y){
  if (is.null(x)) Sys.getenv(y) else x
}

es_get_auth <- function(){
  transport <- Sys.getenv("ES_TRANSPORT")
  host <- Sys.getenv("ES_HOST")
  port <- Sys.getenv("ES_PORT")
  if (is.null(host)) stop("Please run connect()", call. = FALSE)
  list(transport = transport, host = host, port = port)
}

es_get_user_pwd <- function(){
  user <- Sys.getenv("ES_USER")
  pwd <- Sys.getenv("ES_PWD")
  list(user = user, pwd = pwd)
}

make_url <- function(x) {
  url <- sprintf("%s://%s", x$transport, x$host)
  if (is.null(x$port) || nchar(x$port) == 0) {
    url
  } else {
    paste(url, ":", x$port, sep = "")
  }
}

as_headers <- function(x) {
  UseMethod("as_headers")
}
as_headers.default <- function(x) NULL
as_headers.request <- function(x) x
as_headers.list <- function(x) {
  do.call(add_headers, x)
}

ph <- function(x) {
  if (is.null(x)) {
    'NULL'
  } else {
    str <- paste0(names(x$headers), collapse = ", ")
    if (nchar(str) > 30) paste0(substring(str, 1, 30), " ...") else str
  }
}

es_env <- new.env()
