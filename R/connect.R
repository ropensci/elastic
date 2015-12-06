#' Set connection details to an Elasticsearch engine.
#'
#' @name connect
#'
#' @param es_base (character) The base url, defaults to localhost (http://127.0.0.1)
#' @param es_port (character) port to connect to, defaults to 9200 (optional)
#' @param es_user (character) User name, if required for the connection. You can specify, 
#' but ignored for now.
#' @param es_pwd (character) Password, if required for the connection. You can specify, but
#' ignored for now.
#' @param force (logical) Force re-load of connection details
#' @param errors (character) One of simple (Default) or complete. Simple gives http code and 
#' error message on an error, while complete gives both http code and error message, 
#' and stack trace, if available.
#' @param ... Further args passed on to print for the es_conn class.
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
#' # connect('http://162.243.152.56')
#'
#' # See connection details
#' connection()
#' }

#' @export
#' @rdname connect
connect <- function(es_base="http://127.0.0.1", es_port=9200, es_user = NULL,
                    es_pwd = NULL, force = FALSE, errors = "simple", ...) {

  es_base <- has_http(es_base)
  auth <- es_auth(es_base = es_base, es_port = es_port, es_user = es_user,
                  es_pwd = es_pwd, force = force)
  if (is.null(auth$port) || nchar(auth$port) == 0) {
    baseurl <- auth$base
  } else {
    baseurl <- paste(auth$base, auth$port, sep = ":")
  }
  userpwd <- if (!is.null(es_user) && !is.null(es_pwd)) {
    authenticate(es_user, es_pwd)
  } else {
    NULL
  }
  res <- tryCatch(GET(baseurl, c(userpwd, ...)), error = function(e) e)
  if ("error" %in% class(res)) {
    stop(sprintf("\n  Failed to connect to %s\n  Remember to start Elasticsearch before connecting", baseurl), call. = FALSE)
  }
  if (res$status_code > 200) {
    stop(sprintf("Error:", res$headers$statusmessage), call. = FALSE)
  }
  tt <- content(res, as = "text")
  out <- jsonlite::fromJSON(tt, FALSE)
  
  # errors
  errors <- match.arg(errors, c('simple', 'complete'))
  Sys.setenv("ELASTIC_RCLIENT_ERRORS" = errors)
  
  structure(list(base = auth$base, 
                 port = auth$port, 
                 user = es_user,
                 pwd = es_pwd,
                 es_deets = out,
                 errors = Sys.getenv("ELASTIC_RCLIENT_ERRORS")), 
            class = 'es_conn')
}

has_http <- function(x) {
  if (!grepl("^http[s]?://", x)) {
    x <- paste0("http://", x)
    message("es_base not prefixed with http, using ", x, "\nIf you need https, pass in the complete URL")
    x
  } else {
    x
  }
}

#' @export
#' @rdname connect
connection <- function() {
  auth <- list(base = Sys.getenv("ES_BASE"), 
               port = Sys.getenv("ES_PORT"), 
               user = Sys.getenv("ES_USER"))
  if (is.null(auth$port) || nchar(auth$port) == 0) {
    baseurl <- auth$base
  } else {
    baseurl <- paste(auth$base, auth$port, sep = ":")
  }
  res <- tryCatch(GET(baseurl, make_up()), error = function(e) e)
  if ("error" %in% class(res)) {
    stop(sprintf("\n  Failed to connect to %s\n  Remember to start Elasticsearch before connecting", baseurl), call. = FALSE)
  }
  if (res$status_code > 200)
    stop(sprintf("Error:", res$headers$statusmessage), call. = FALSE)
  tt <- content(res, as = "text")
  out <- jsonlite::fromJSON(tt, FALSE)
  structure(list(base = auth$base, 
                 port = auth$port,
                 user = auth$user, 
                 pwd = "<secret>", 
                 es_deets = out,
                 errors = Sys.getenv("ELASTIC_RCLIENT_ERRORS")), 
            class = 'es_conn')
}

#' @export
print.es_conn <- function(x, ...){
  fun <- function(x) ifelse(is.null(x), 'NULL', x)
  cat(paste('url:      ', fun(x$base)), "\n")
  cat(paste('port:     ', fun(x$port)), "\n")
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
#' @param es_base (character) Base url
#' @param es_port (character) Port
#' @param es_user (character) User name
#' @param es_pwd (character) Password
#' @param force (logical) Force update
es_auth <- function(es_base=NULL, es_port=NULL, es_user=NULL, es_pwd=NULL, force=FALSE){
  base <- ifnull(es_base, 'ES_BASE')
  port <- if (is.null(es_port)) "" else es_port
  user <- ifnull(es_user, 'ES_USER')
  pwd <- ifnull(es_pwd, 'ES_PWD')

  if (identical(base, "") || force) {
    if (!interactive()) {
      stop("Please set env var ES_BASE for your base url for your Elasticsearch server",
           call. = FALSE)
    }
    message("Couldn't find env var ES_BASE See ?es_auth for more details.")
    message("Please enter your Elasticsearch base url and press enter:")
    base <- readline(": ")
    if (identical(base, "")) {
      stop("Elasticsearch base url entry failed", call. = FALSE)
    }
    message("Updating ES_BASE env var\n")
    Sys.setenv(ES_BASE = base)
  } else { 
    base <- base 
  }

  Sys.setenv(ES_BASE = base)
  Sys.setenv(ES_PORT = port)
  Sys.setenv(ES_USER = user)
  Sys.setenv(ES_PWD = pwd)
  list(base = base, port = port)
}

ifnull <- function(x, y){
  if (is.null(x)) Sys.getenv(y) else x
}

es_get_auth <- function(){
  base <- Sys.getenv("ES_BASE")
  port <- Sys.getenv("ES_PORT")
  if (is.null(base)) stop("Please run connect()", call. = FALSE)
  list(base = base, port = port)
}

es_get_user_pwd <- function(){
  user <- Sys.getenv("ES_USER")
  pwd <- Sys.getenv("ES_PWD")
  list(user = user, pwd = pwd)
}
