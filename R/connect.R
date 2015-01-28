#' Set connection details to an Elasticsearch engine.
#'
#' @name connect
#'
#' @param es_base The base url, defaults to localhost (http://127.0.0.1)
#' @param es_port port to connect to, defaults to 5984
#' @param es_user User name, if required for the connection. You can specify, but
#' ignored for now.
#' @param es_pwd Password, if required for the connection. You can specify, but
#' ignored for now.
#' @param es_key An API key
#' @param force Force re-authorization.
#' @param ... Further args passed on to print for the es_conn class.
#' @details The default configuration is set up for localhost access on port 9200,
#' with no username or password.
#'
#' \code{\link{connection}} calls \code{\link{connect}} internally
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
connect <- function(es_base="http://127.0.0.1", es_port=9200, es_user = NULL, es_pwd = NULL,
                       es_key = NULL, force = FALSE, ...)
{
  auth <- es_get_auth(es_base=es_base, es_port=es_port, force = force)

#   if(grepl('localhost|127.0.0.1', auth$base))
#     base <- paste(auth$base, auth$port, sep = ":")
  if(is.null(auth$port)){
    baseurl <- auth$base
  } else {
    baseurl <- paste(auth$base, auth$port, sep = ":")
  }
  res <- tryCatch(GET(baseurl, ...), error=function(e) e)
  if("error" %in% class(res)){
    stop(sprintf("\n  Failed to connect to %s\n  Remember to start Elasticsearch before connecting", baseurl), call. = FALSE)
  }
  if(res$status_code > 200)
    stop(sprintf("Error:", res$headers$statusmessage), call. = FALSE)
  tt <- content(res, as = "text")
  out <- jsonlite::fromJSON(tt, FALSE)

  ll <- list(base = auth$base, port = auth$port, user = es_user, pwd = es_pwd, key = es_key, es_deets = out)

  class(ll) <- 'es_conn'
  return( ll )
}

#' @export
#' @rdname connect
connection <- function(){
  auth <- list(base=getOption("es_base"), port=getOption("es_port"))
  if(is.null(auth$port)){
    baseurl <- auth$base
  } else
  {  baseurl <- paste(auth$base, auth$port, sep = ":") }
  res <- tryCatch(GET(baseurl), error=function(e) e)
  if("error" %in% class(res)){
    stop(sprintf("\n  Failed to connect to %s\n  Remember to start Elasticsearch before connecting", baseurl), call. = FALSE)
  }
  if(res$status_code > 200)
    stop(sprintf("Error:", res$headers$statusmessage), call. = FALSE)
  tt <- content(res, as = "text")
  out <- jsonlite::fromJSON(tt, FALSE)
  ll <- list(base=auth$base, port=auth$port, user = NULL, pwd = NULL, key = NULL, es_deets = out)
  class(ll) <- 'es_conn'
  return( ll )
}

#' @export
print.es_conn <- function(x, ...){
  fun <- function(x) ifelse(is.null(x), 'NULL', x)
  cat(paste('uri:      ', fun(x$base)), "\n")
  cat(paste('port:     ', fun(x$port)), "\n")
  cat(paste('username: ', fun(x$user)), "\n")
  cat(paste('password: ', fun(x$pwd)), "\n")
  cat(paste('api key:  ', fun(x$key)), "\n")
  cat(paste('elasticsearch details:  '), "\n")
  cat(paste('      status:                 ', fun(x$es_deets$status)), "\n")
  cat(paste('      name:                   ', fun(x$es_deets$name)), "\n")
  cat(paste('      Elasticsearch version:  ', fun(x$es_deets$version$number)), "\n")
  cat(paste('      ES version timestamp:   ', fun(x$es_deets$version$build_timestamp)), "\n")
  cat(paste('      lucene version:         ', fun(x$es_deets$version$lucene_version)))
}


#' Set authentication details
#'
#' Only base url and port and used right now. Will add use or username, password, key, etc. later.
#' @keywords internal
#' @param es_base (character) Base url
#' @param es_port (character) Port
#' @param es_user (character) User name
#' @param es_pwd (character) Password
#' @param es_key (character) API key
#' @param force (logical) Force update
#'
#' @details
#' \itemize{
#'  \item You can enter your details using the client_id and api_key parameters directly.
#'  \item You can execute the function without any inputs. The function then first looks in your
#'  options for the option variables digocean_client_id and digocean_api_key. If they are not found
#'  the function asks you to enter them. You can set force=TRUE to force the function to ask
#'  you for new id and key.
#'  \item Set your options using the function \code{options}. See examples.
#'  \item Set your options in your .Rprofile file with entries
#'  \code{options(es_base = '<clientid>')}, \code{options(es_port = '<port>')},
#'  \code{options(es_user = '<port>')}, \code{options(es_pwd = '<port>')}, and
#'  \code{options(es_key = '<port>')}
#' }

es_auth <- function(es_base=NULL, es_port=NULL, es_user=NULL, es_pwd=NULL, es_key=NULL, force=FALSE)
{
#   list(es_base=es_base, es_port=es_port)
  base <- ifnull(es_base, 'es_base')
  port <- ifnull(es_port, 'es_port')
  user <- ifnull(es_user, 'es_user')
  pwd <- ifnull(es_pwd, 'es_pwd')
  key <- ifnull(es_key, 'es_key')

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

  if (identical(port, "") || force){
    if (!interactive()) {
      stop("Please set option var es_port to your Elasticsearch port",
           call. = FALSE)
    }
    message("Couldn't find option var es_port. See ?es_auth for more details.")
    message("Please enter your Elasticsearch port and press enter:")
    port <- readline(": ")
    if (identical(port, "")) {
      stop("Elasticsearch port entry failed", call. = FALSE)
    }
    message("Updating es_port option var")
    options(es_port = port)
  } else { port <- port }

  options(es_base = base)
  options(es_port = port)
  list(base = base, port = port)
}

ifnull <- function(x, y){
  if(is.null(x)) getOption(y, default = "") else x
}

es_get_auth <- function(es_base=NULL, es_port=NULL, force=FALSE){
  if(is.null(es_base)) es_base <- getOption("es_base")
  if(is.null(es_port)) es_port <- getOption("es_port")

#   if(is.null(base) | is.null(port))
  es_auth(es_base=es_base, es_port=es_port, force = force)

  base <- getOption("es_base")
  port <- getOption("es_port")

  list(base=base, port=port)
}
