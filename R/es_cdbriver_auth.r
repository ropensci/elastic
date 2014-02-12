#' Authentication for CouchDB database using Elasticsearch river plugin.
#'
#' @import httr
#' @param user Username
#' @param pwd Password
#' @param dbname Database name. (charcter)
#' @param endpoint the endpoint, defaults to localhost (http://127.0.0.1)
#' @param port port to connect to, defaults to 9200
#' @examples \dontrun{
#' es_cdbriver_auth(user="foo", pwd="bar")
#' }
#' @export
es_cdbriver_auth <- function(user=NULL, pwd=NULL, dbname, endpoint="http://localhost", port=9200)
{
  call_ <- sprintf("%s:%s/_river/%s/_meta", endpoint, port, dbname)
  args <- paste0('{ "type" : "couchdb", "couchdb" : {"user" : "', user, '", "pasword" :  "', pwd, '" } }')
  tt <- PUT(url = "http://localhost:9200", body=args)
  stop_for_status(tt)
  content(tt)[1] 
}

# Not really sure what to do with this function - may remove it