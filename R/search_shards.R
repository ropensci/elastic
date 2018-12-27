#' Search shards
#'
#' @export
#' @param conn an Elasticsearch connection object, see [connect()]
#' @param index One or more indeces
#' @param routing A character vector of routing values to take into account 
#' when determining which shards a request would be executed against.
#' @param preference Controls a preference of which shard replicas to execute 
#' the search request on. By default, the operation is randomized between the 
#' shard replicas. See [preference] for a list of all acceptable 
#' values.
#' @param local (logical) Whether to read the cluster state locally in order 
#' to determine where shards are allocated instead of using the Master node's 
#' cluster state.
#' @param raw If `TRUE` (default), data is parsed to list. If `FALSE`, then 
#' raw JSON
#' @param ... Curl args passed on to [crul::verb-GET]
#' @references
#' <https://www.elastic.co/guide/en/elasticsearch/reference/current/search-shards.html>
#' @examples \dontrun{
#' # connection setup
#' (x <- connect())
#' 
#' search_shards(x, index = "plos")
#' search_shards(x, index = c("plos","gbif"))
#' search_shards(x, index = "plos", preference='_primary')
#' search_shards(x, index = "plos", preference='_shards:2')
#' 
#' # curl options
#' search_shards(x, index = "plos", verbose = TRUE)
#' }

search_shards <- function(conn, index=NULL, raw=FALSE, routing=NULL, preference=NULL, 
                          local=NULL, ...) {
  is_conn(conn)
  es_GET_(conn, file.path(conn$make_url(), esc(cl(index)), "_search_shards"),
    ec(list(routing = routing, preference = preference, local = local)), 
    ...)
}
