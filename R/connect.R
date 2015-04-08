#' Set connection details to an Elasticsearch engine.
#'
#' @name connect
#'
#' @param es_base The base url, defaults to localhost (http://127.0.0.1)
#' @param es_port port to connect to, defaults to 9200 (optional)
#' @param es_user User name, if required for the connection. You can specify, but
#' ignored for now.
#' @param es_pwd Password, if required for the connection. You can specify, but
#' ignored for now.
#' @param force Force re-load of connection details
#' @param ... Further args passed on to print for the es_conn class.
#' @details The default configuration is set up for localhost access on port 9200,
#' with no username or password.
#'
#' \code{\link{connection}} does not ping the Elasticsearch server, but only
#' prints connection details.
#'
#' On package load, \code{\link{connect}} is run to set the default base url and port.
#'
#' @examples \dontrun{
#' # the default is set to localhost and port 9200
#' connect()
#'
#' # or set to a different base url
#' connect('http://162.243.152.56')
#'
#' # See connection details
#' connection()
#' }

#' @export
#' @rdname connect
connect <- function(es_base="http://127.0.0.1", es_port=9200, es_user = NULL, 
                    es_pwd = NULL, force = FALSE, ...) {

  es_base <- has_http(es_base)
  auth <- es_auth(es_base=es_base, es_port=es_port, es_user=es_user, 
                  es_pwd=es_pwd, force = force)
  if(is.null(auth$port) || nchar(auth$port) == 0){
    baseurl <- auth$base
  } else {
    baseurl <- paste(auth$base, auth$port, sep = ":")
  }
  userpwd <- if(!is.null(es_user) && !is.null(es_pwd)) {
    authenticate(es_user, es_pwd)
  } else {
    NULL
  }
  res <- tryCatch(GET(baseurl, c(userpwd, ...)), error=function(e) e)
  if("error" %in% class(res)){
    stop(sprintf("\n  Failed to connect to %s\n  Remember to start Elasticsearch before connecting", baseurl), call. = FALSE)
  }
  if(res$status_code > 200)
    stop(sprintf("Error:", res$headers$statusmessage), call. = FALSE)
  tt <- content(res, as = "text")
  out <- jsonlite::fromJSON(tt, FALSE)
  structure(list(base = auth$base, port = auth$port, user = es_user, 
                 pwd = es_pwd, es_deets = out), class='es_conn')
}

has_http <- function(x) {
  if(!grepl("^http[s]?://", x)) {
    x <- paste0("http://", x)
    message("es_base not prefixed with http, using ", x, "\nIf you need https, pass in the complete URL")
  } else {
    x
  }
}

#' @export
#' @rdname connect
connection <- function() {
  auth <- list(base=getOption("es_base"), port=getOption("es_port"), user=getOption("es_user"))
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
  structure(list(base = auth$base, port = auth$port, 
                 user = auth$user, pwd = "<secret>", es_deets = out), class = 'es_conn')
}

#' @export
print.es_conn <- function(x, ...){
  fun <- function(x) ifelse(is.null(x), 'NULL', x)
  cat(paste('uri:      ', fun(x$base)), "\n")
  cat(paste('port:     ', fun(x$port)), "\n")
  cat(paste('username: ', fun(x$user)), "\n")
  cat(paste('password: ', fun(x$pwd)), "\n")
  cat(paste('elasticsearch details:  '), "\n")
  cat(paste('   status:                 ', fun(x$es_deets$status)), "\n")
  cat(paste('   name:                   ', fun(x$es_deets$name)), "\n")
  cat(paste('   Elasticsearch version:  ', fun(x$es_deets$version$number)), "\n")
  cat(paste('   ES version timestamp:   ', fun(x$es_deets$version$build_timestamp)), "\n")
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
  base <- ifnull(es_base, 'es_base')
  port <- if(is.null(es_port)) "" else es_port
  user <- ifnull(es_user, 'es_user')
  pwd <- ifnull(es_pwd, 'es_pwd')

  if (identical(base, "") || force){
    if (!interactive()) {
      stop("Please set option variable es_base to your base url for your Elasticsearch server",
           call. = FALSE)
    }
    message("Couldn't find option var es_base. See ?es_auth for more details.")
    message("Please enter your Elasticsearch base url and press enter:")
    base <- readline(": ")
    if (identical(base, "")) {
      stop("Elasticsearch base url entry failed", call. = FALSE)
    }
    message("Updating es_base option var\n")
    options(es_base = base)
  } else { base <- base }

  options(es_base = base)
  options(es_port = port)
  options(es_user = user)
  options(es_pwd = pwd)
  list(base = base, port = port)
}

ifnull <- function(x, y){
  if(is.null(x)) getOption(y, default = "") else x
}

es_get_auth <- function(){
  base <- getOption("es_base")
  port <- getOption("es_port")
  if(is.null(base)) stop("Please run connect()", call. = FALSE)
  list(base=base, port=port)
}

es_get_user_pwd <- function(){
  user <- getOption("es_user")
  pwd <- getOption("es_pwd")
  list(user=user, pwd=pwd)
}
