#' Update documents by query
#'
#' update documents by query via a POST request
#'
#' @export
#' @inheritParams docs_delete_by_query
#' @param pipeline (character) a pipeline name
#' @references
#' <https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-update-by-query.html>
#' <https://www.elastic.co/guide/en/elasticsearch/painless/current/painless-api-reference.html>
#' @seealso [docs_delete_by_query()]
#' @examples \dontrun{
#' (x <- connect())
#' x$ping()
#'
#' omdb <- system.file("examples", "omdb_notypes.json", package = "elastic")
#' if (!index_exists(x, "omdb")) invisible(docs_bulk(x, omdb))
#'
#' # can be sent without a body
#' docs_update_by_query(x, index='omdb')
#'
#' # update
#' ## note this works with imdbRating, a float, but didn't seem to work
#' ## with Metascore, a long
#' ## See link above for Painless API reference
#' body <- '{
#'   "script": {
#'     "source": "ctx._source.imdbRating++",
#'     "lang": "painless"
#'   },
#'   "query": {
#'     "match": {
#'       "Rated": "R"
#'     }
#'   }
#' }'
#' Search(x, "omdb", q = "Rated:\"R\"", asdf=TRUE,
#'   source = c("Title", "Rated", "imdbRating"))$hits$hits
#' docs_update_by_query(x, index='omdb', body = body)
#' Search(x, "omdb", q = "Rated:\"R\"", asdf=TRUE,
#'   source = c("Title", "Rated", "imdbRating"))$hits$hits
#' }
docs_update_by_query <- function(conn, index, body = NULL, type = NULL,
  conflicts=NULL, routing=NULL, scroll_size=NULL, refresh=NULL,
  wait_for_completion=NULL, wait_for_active_shards=NULL, timeout=NULL,
  scroll=NULL, requests_per_second=NULL, pipeline=NULL, ...) {

  is_conn(conn)
  args <- ec(list(conflicts=conflicts, routing=routing,
    scroll_size=scroll_size, refresh=refresh,
    wait_for_completion=wait_for_completion,
    wait_for_active_shards=wait_for_active_shards, timeout=timeout,
    scroll=scroll, requests_per_second=requests_per_second,
    pipeline=pipeline))
  if (length(args) == 0) args <- NULL
  jsonlite::fromJSON(es_POST(conn, "_update_by_query",
    index, type, NULL, FALSE, NULL, body, args, ...),
  FALSE)
}
