#' Interact with CouchDB via Elasticsearch river plugin.
#' 
#' @name cdbriver
#' @keywords internal
#' @param user Username
#' @param pwd Password
#' @param dbname Database name. (character)
#' @param endpoint the endpoint, defaults to localhost (http://127.0.0.1)
#' @param port port to connect to, defaults to 9200
#' @param what One of start (default) of stop.
#' @references See docs for the Elasticsearch River plugin 
#' \url{https://github.com/elasticsearch/elasticsearch-river-couchdb/blob/master/README.md} 
#' that lets you easily index CouchDB databases.
#' @examples \donttest{
#' # Authenticate
#' cdbriver_auth(user="foo", pwd="bar")
#' 
#' # Start or stop indexing a CouchDB database using Elasticsearch.
#' devtools::install_github("sckott/sofa")
#' library('sofa')
#' db_create(dbname = 'stuff')
#' cdbriver_index(dbname='stuff')
#' cdbriver_index(dbname='mydb', what='stop')
#' }
NULL

#' @rdname cdbriver
cdbriver_auth <- function(user=NULL, pwd=NULL, dbname, endpoint="http://localhost", port=9200)
{
  call_ <- sprintf("%s:%s/_river/%s/_meta", endpoint, port, dbname)
  args <- paste0('{ "type" : "couchdb", "couchdb" : {"user" : "', user, '", "pasword" :  "', pwd, '" } }')
  tt <- PUT(url = "http://localhost:9200", body=args)
  stop_for_status(tt)
  content(tt)[1] 
}

#' @rdname cdbriver
cdbriver_index <- function(dbname, endpoint="http://localhost", port=9200, what='start')
{
  if(what=='start'){
    call_ <- sprintf("%s:%s/_river/%s/_meta", endpoint, port, dbname)
    args <- paste0('{ "type" : "couchdb", "couchdb" : { "host" : "localhost", "port" : 5984, "db" : "', dbname, '", "filter" : null } }')
    tt <- PUT(url = call_, body=args)
    stop_for_status(tt)
    content(tt)[1] 
  } else
  {
    call_ <- sprintf("%s:%s/_river/%s", endpoint, port, dbname)
    DELETE(url = call_)
    message("elastic river stopped")
  }
}
