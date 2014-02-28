#' Start or stop indexing a document or many documents.
#'
#' @import httr
#' @param dbname Database name. (charcter)
#' @param endpoint the endpoint, defaults to localhost (http://127.0.0.1)
#' @param port port to connect to, defaults to 9200
#' @param what One of start (default) of stop.
#' @details The function returns TRUE. Though note that this can result even 
#'    if the database does not exist in CouchDB. 
#' @references See docs for the Elasticsearch River plugin \url{#} that lets you 
#'     easily index CouchDB databases.
#' @examples \dontrun{
#' library(devtools)
#' install_github("sckott/sofa")
#' library(sofa)
#' sofa_createdb(dbname='mydb')
#' es_cdbriver_index(dbname='mydb')
#' es_cdbriver_index(dbname='mydb', what='stop')
#' }
#' @export

es_index <- function(conn, what='start')
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