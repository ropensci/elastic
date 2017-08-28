#' Set connection details to an Elasticsearch engine.
#'
#' @name connect
#' @export
#'
#' @param es_host (character) The base host, defaults to \code{127.0.0.1}. 
#' Synonym of \code{es_base}
#' @param es_base (character) Synonym of \code{es_host}, and will be gone in a 
#' future version of \pkg{elastic}
#' @param es_port (character) port to connect to, defaults to \code{9200} 
#' (optional)
#' @param es_path (character) context path that is appended to the end of the 
#' url. Default: NULL, ignored
#' @param es_transport_schema (character) http or https. Default: \code{http}
#' @param es_user (character) User name, if required for the connection. You 
#' can specify,  but ignored for now.
#' @param es_pwd (character) Password, if required for the connection. You 
#' can specify, but ignored for now.
#' @param force (logical) Force re-load of connection details
#' @param errors (character) One of simple (Default) or complete. Simple gives 
#' http code and  error message on an error, while complete gives both http 
#' code and error message,  and stack trace, if available.
#' @param headers Either an object of class \code{request} or a list that can 
#' be coerced to an object of class \code{request} via 
#' \code{\link[httr]{add_headers}}. These headers are  used in all requests. 
#' To use headers in individual requests and not others, pass in headers 
#' using \code{\link[httr]{add_headers}} via \code{...} in a function call.
#' @param ... Further args passed on to print for the es_conn class.
#' 
#' @details The default configuration is set up for localhost access on port 
#' 9200, with no username or password.
#'
#' \code{\link{connect}} and \code{\link{connection}} no longer ping the 
#' Elasticsearch server, but only print your connection details.
#'
#' Internally, we store your connection settings with environment variables. 
#' That means you  can set your env vars permanently in .Renviron file, and 
#' use them on a server e.g., as private env vars
#' 
#' @seealso \code{\link{ping}} to check your connection
#'
#' @examples \dontrun{
#' # the default is set to 127.0.0.1 (i.e., localhost) and port 9200
#' connect()
#'
#' # set a different host
#' # connect(es_host = '162.243.152.53')
#' # => http://162.243.152.53:9200
#' 
#' # set a different port
#' # connect(es_port = 8000)
#' # => http://localhost:8000
#' 
#' # set a different context path
#' # connect(es_path = 'foo_bar')
#' # => http://localhost:9200/foo_bar
#' 
#' # set to https
#' # connect(es_transport_schema = 'https')
#' # => https://localhost:9200
#'
#' # See connection details
#' connection()
#' 
#' # set headers
#' connect(headers = list(a = 5))
#' ## or
#' connect(headers = add_headers(a = 5))
#' }
connect <- function(es_host = "127.0.0.1", es_port = 9200, es_path = NULL, 
                    es_transport_schema = "http", es_user = NULL,
                    es_pwd = NULL, force = FALSE, errors = "simple", 
                    es_base = NULL, headers = NULL, ...) {

  calls <- names(sapply(match.call(), deparse))[-1]
  calls_vec <- "es_base" %in% calls
  if (any(calls_vec)) {
    es_host <- es_base
    warning(
      paste("'es_base' will be removed in a future version of",
             "this pkg.\nuse 'es_host' going forward"), call. = FALSE)
  }
  
  # reset ping result in elastic_env
  elastic_env$ping_result <- NULL
  
  # strip off transport if found
  if (grepl("^http[s]?://", es_host)) {
    message("Found http or https on es_host, stripping off, see the docs")
    es_host <- sub("^http[s]?://", "", es_host)
  }
  
  # normalize es_path
  if (!is.null(es_path)) {
    if (grepl("/$", es_path)) {
      message("Normalizing path: stripping trailing slash")
      es_path <- sub("/$", "", es_path)
    }
  }
  
  auth <- es_auth(es_host = es_host, es_port = es_port, es_path = es_path,
                  es_transport_schema = es_transport_schema, es_user = es_user,
                  es_pwd = es_pwd, force = force)
  if (is.null(auth$port) || nchar(auth$port) == 0) {
    baseurl <- sprintf("%s://%s", auth$transport, auth$host)
  } else {
    baseurl <- sprintf("%s://%s:%s", auth$transport, auth$host, auth$port)
  }
  if (!is.null(auth$path)) {
    baseurl <- file.path(baseurl, auth$path)
  }
  userpwd <- if (!is.null(es_user) && !is.null(es_pwd)) {
    authenticate(es_user, es_pwd)
  } else {
    NULL
  }
  
  # errors
  errors <- match.arg(errors, c('simple', 'complete'))
  Sys.setenv("ELASTIC_RCLIENT_ERRORS" = errors)
  
  # cache headers in an environment
  rm(list = ls(envir = es_env), envir = es_env)
  es_env$headers <- as_headers(headers)
  
  structure(list(
    host = auth$host,
    port = auth$port,
    path = auth$path,
    transport = auth$transport,
    user = es_user,
    pwd = "<secret>",
    # es_deets = out,
    headers = es_env$headers,
    errors = Sys.getenv("ELASTIC_RCLIENT_ERRORS")),
    class = 'es_conn')
}

#' @export
#' @rdname connect
connection <- function() {
  auth <- list(host = Sys.getenv("ES_HOST"), 
               port = Sys.getenv("ES_PORT"), 
               path = Sys.getenv("ES_PATH"), 
               transport = Sys.getenv("ES_TRANSPORT"),
               user = Sys.getenv("ES_USER"))
  if (is.null(auth$port) || nchar(auth$port) == 0) {
    baseurl <- sprintf("%s://%s", auth$transport, auth$host)
  } else {
    baseurl <- sprintf("%s://%s:%s", auth$transport, auth$host, auth$port)
  }
  if (!is.null(auth$path)) {
    baseurl <- file.path(baseurl, auth$path)
  }

  structure(list(
    transport = auth$transport,
    host = auth$host, 
    port = auth$port,
    path = auth$path,
    user = auth$user, 
    pwd = "<secret>", 
    # es_deets = out,
    headers = es_env$headers,
    errors = Sys.getenv("ELASTIC_RCLIENT_ERRORS")), 
    class = 'es_conn')
}

#' @export
print.es_conn <- function(x, ...){
  fun <- function(x) ifelse(is.null(x) || nchar(x) == 0, 'NULL', x)
  cat(paste('transport: ', fun(x$transport)), "\n")
  cat(paste('host:      ', fun(x$host)), "\n")
  cat(paste('port:      ', fun(x$port)), "\n")
  cat(paste('path:      ', fun(x$path)), "\n")
  cat(paste('username:  ', fun(x$user)), "\n")
  cat(paste('password:  ', fun(x$pwd)), "\n")
  cat(paste('errors:    ', fun(x$errors)), "\n")
  cat(paste('headers (names): ', ph(x$headers)), "\n")
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
es_auth <- function(es_host = NULL, es_port = NULL, es_path = NULL, 
                    es_transport_schema = NULL, es_user = NULL, es_pwd = NULL, 
                    force = FALSE, es_base = NULL) {
  
  calls <- names(sapply(match.call(), deparse))[-1]
  calls_vec <- "es_base" %in% calls
  if (any(calls_vec)) {
    stop("The parameter es_base has been deprecated, use es_host", call. = FALSE)
  }
  
  host <- ifnull(es_host, 'ES_HOST')
  port <- if (is.null(es_port)) "" else es_port
  path <- ifnull(es_path, 'ES_PATH')
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
  Sys.setenv(ES_PATH = path)
  Sys.setenv(ES_USER = user)
  Sys.setenv(ES_PWD = pwd)
  list(host = host, port = port, path = path, transport = transport)
}

ifnull <- function(x, y){
  if (is.null(x)) Sys.getenv(y) else x
}

es_get_auth <- function(){
  transport <- Sys.getenv("ES_TRANSPORT")
  host <- Sys.getenv("ES_HOST")
  port <- Sys.getenv("ES_PORT")
  path <- Sys.getenv("ES_PATH")
  if (is.null(host)) stop("Please run connect()", call. = FALSE)
  list(transport = transport, host = host, port = port, path = path)
}

es_get_user_pwd <- function(){
  user <- Sys.getenv("ES_USER")
  pwd <- Sys.getenv("ES_PWD")
  list(user = user, pwd = pwd)
}

make_url <- function(x) {
  url <- sprintf("%s://%s", x$transport, x$host)
  url <- if (is.null(x$port) || nchar(x$port) == 0) {
    url
  } else {
    paste(url, ":", x$port, sep = "")
  }
  if (!is.null(x$path) && nchar(x$path) > 0) {
    url <- file.path(url, x$path)
  }
  url
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
