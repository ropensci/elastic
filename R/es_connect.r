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
#' @examples
#' (conn <- es_connect())

es_connect <- function(url="http://127.0.0.1", port=9200, user = NULL, pwd = NULL, key = NULL, ...)
{  
  if(grepl('localhost|127.0.0.1', url))
    url <- paste(url, port, sep = ":")
  res <- tryCatch(GET(url, ...), error=function(e) e)
  if("error" %in% class(res)){
    stop(sprintf("\n  Failed to connect to %s\n  Remember to start Elasticsearch before connecting", url), call. = FALSE)
  }
  if(res$status_code > 200)
    stop(sprintf("Error:", res$headers$statusmessage), call. = FALSE)
  tt <- content(res, as = "text")
  out <- fromJSON(tt, simplifyWithNames = FALSE)
  
  ll <- list(url = url, port = port, user = user, pwd = pwd, key = key, es_deets = out)
  
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