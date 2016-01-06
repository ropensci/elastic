#' Search shards.
#'
#' @export
#' @param index One or more indeces
#' @param routing A character vector of routing values to take into account when determining
#' which shards a request would be executed against.
#' @param preference Controls a preference of which shard replicas to execute the search
#' request on. By default, the operation is randomized between the shard replicas. See
#' \code{\link{preference}} for a list of all acceptable values.
#' @param local (logical) Whether to read the cluster state locally in order to determine
#' where shards are allocated instead of using the Master node's cluster state.
#' @param raw If TRUE (default), data is parsed to list. If FALSE, then raw JSON.
#' @param ... Curl args passed on to \code{\link[httr]{GET}}
#' @references
#' \url{https://www.elastic.co/guide/en/elasticsearch/reference/current/search-shards.html}
#' @examples \dontrun{
#' search_shards(index = "plos")
#' search_shards(index = c("plos","gbif"))
#' search_shards(index = "plos", preference='_primary')
#' search_shards(index = "plos", preference='_shards:2')
#'
#' library('httr')
#' search_shards(index = "plos", config=verbose())
#' }

search_shards <- function(index=NULL, raw=FALSE, routing=NULL, preference=NULL, local=NULL, ...) {
  url <- make_url(es_get_auth())
  es_GET_(file.path(url, esc(cl(index)), "_search_shards"),
          ec(list(routing = routing, preference = preference, local = local)), ...)
}
