#' Set connection details to an Elasticsearch engine.
#' 
#' @param url the url, defaults to localhost (http://127.0.0.1)
#' @param port port to connect to, defaults to 5984
#' @param user User name, if required for the connection. You can specify, but 
#' ignored for now.
#' @param pwd Password, if required for the connection. You can specify, but 
#' ignored for now.
#' @param x Object to print.
#' @param ... Further args passed on to print for the es_conn class.
#' @details The default configuration is set up for localhost access on port 9200,
#' with no username or password.
#' 
#' Pass on the returned 'es_conn' object to other functions in this package.
#' @export
#' @examples \dontrun{
#' (conn <- es_connect())
#' }

es_connect <- function(base="http://127.0.0.1", port=9200, user = NULL, pwd = NULL, key = NULL, ...)
{  
  if(grepl('localhost|127.0.0.1', base))
    base <- paste(base, port, sep = ":")
  res <- tryCatch(GET(base, ...), error=function(e) e)
  if("error" %in% class(res)){
    stop(sprintf("\n  Failed to connect to %s\n  Remember to start Elasticsearch before connecting", url), call. = FALSE)
  }
  if(res$status_code > 200)
    stop(sprintf("Error:", res$headers$statusmessage), call. = FALSE)
  tt <- content(res, as = "text")
  out <- fromJSON(tt, simplifyWithNames = FALSE)
  
  ll <- list(base = base, port = port, user = user, pwd = pwd, key = key, es_deets = out)
  
  class(ll) <- 'es_conn'
  return( ll )
}

#' @method print es_conn
#' @export
#' @rdname es_connect
print.es_conn <- function(x, ...){
  fun <- function(x) ifelse(is.null(x), 'NULL', x)
  cat(paste('uri:      ', fun(x$url)), "\n")
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
#' 
#' @param es_base (character) Base url
#' @param es_port (character) Port
#' @param es_user (character) User name
#' @param es_pwd (character) Password
#' @param es_key (character) API key
#' @param force (logical) Force update
#'
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
  
  list(base = base, port = port)
}

ifnull <- function(x, y){
  if(is.null(x)) getOption(y, default = "") else x
}

es_get_auth <- function(){
  base <- getOption("es_base")
  port <- getOption("es_port")
  
  if(is.null(base) | is.null(port)) es_auth()
  
  base <- getOption("es_base")
  port <- getOption("es_port")
  
  list(base=base, port=port)
}