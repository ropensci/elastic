#' Stop indexing a CouchDB database using Elasticsearch.
#'
#' @import httr
#' @param dbname Database name. (charcter)
#' @param endpoint the endpoint, defaults to localhost (http://127.0.0.1)
#' @param port port to connect to, defaults to 5984
#' @details The function returns a message 'elastic river stopped'. This function stops
#'    elasticsearch from indexing the database in the dbname parameter. You may want 
#'    stop indexing e.g., if you started indexing a database that you didn't mean to 
#'    start indexing.
#' @examples \dontrun{
#' elastic_stop(dbname = "ggggg")
#' }
#' @export
elastic_stop <- function(dbname, endpoint="http://localhost", port=9200)
{
  call_ <- paste(paste(endpoint, port, sep=":"), "/_river/", dbname, sep="")
  DELETE(url = call_)
  message("elastic river stopped")
}