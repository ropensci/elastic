#' Start indexing a CouchDB database using Elasticsearch.
#'
#' @import httr
#' @param dbname Database name. (charcter)
#' @param endpoint the endpoint, defaults to localhost (http://127.0.0.1)
#' @param port port to connect to, defaults to 9200
#' @details The function returns TRUE. Though note that this can result even 
#'    if the database does not exist in CouchDB. 
#' @references See docs for the Elasticsearch River plugin \url{#} that lets you 
#'     easily index CouchDB databases.
#' @examples \dontrun{
#' elastic_river_auth(user="foo", pwd="bar")
#' }
#' @export
elastic_river_auth <- function(user=NULL, pwd=NULL)
{
  call_ <- sprintf("%s:%s/_river/%s/_meta", endpoint, port, dbname)
  args <- paste0('{ "type" : "couchdb", "couchdb" : {"user" : "', user, '", "pasword" :  "', pwd, '" } }')
  tt <- PUT(url = "http://localhost:9200", body=args)
  stop_for_status(tt)
  content(tt)[1] 
}