#' @title Percolater
#'
#' @description Store queries into an index then, via the percolate API, define
#' documents to retrieve these queries.
#'
#' @export
#' @name percolate
#' @param conn an Elasticsearch connection object, see [connect()]
#' @param index Index name. Required
#' @param type Document type. Required
#' @param body Body json, or R list.
#' @param id A precolator id. Required
#' @param routing (character) In case the percolate queries are partitioned by a custom
#' routing value, that routing option makes sure that the percolate request only gets
#' executed on the shard where the routing value is partitioned to. This means that the
#' percolate request only gets executed on one shard instead of all shards. Multiple values
#' can be specified as a comma separated string, in that case the request can be be executed
#' on more than one shard.
#' @param preference (character) Controls which shard replicas are preferred to execute
#' the request on. Works the same as in the search API.
#' @param ignore_unavailable (logical) Controls if missing concrete indices should
#' silently be ignored. Same as is in the search API.
#' @param percolate_format (character) If ids is specified then the matches array in the
#' percolate response will contain a string array of the matching ids instead of an
#' array of objects. This can be useful to reduce the amount of data being send back to
#' the client. Obviously if there are two percolator queries with same id from different
#' indices there is no way to find out which percolator query belongs to what index. Any
#' other value to percolate_format will be ignored.
#' @param refresh If `TRUE` then refresh the affected shards to make this 
#' operation visible to search, if "wait_for" then wait for a refresh to 
#' make this operation visible to search, if `FALSE` (default) then do 
#' nothing with refreshes. Valid choices: `TRUE`, `FALSE`, "wait_for"
#' @param ... Curl options. Or in `percolate_list` function, further args
#' passed on to [Search()]
#'
#' @references
#' <https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-percolate-query.html>
#'
#' @details Additional body options, pass those in the body. These aren't query string
#' parameters:
#'
#' - filter - Reduces the number queries to execute during percolating. Only the
#'  percolator queries that match with the filter will be included in the percolate
#'  execution. The filter option works in near realtime, so a refresh needs to have
#'  occurred for the filter to included the latest percolate queries.
#' - query - Same as the filter option, but also the score is computed. The
#'  computed scores can then be used by the track_scores and sort option.
#' - size - Defines to maximum number of matches (percolate queries) to be returned.
#'  Defaults to unlimited.
#' - track_scores - Whether the _score is included for each match. The _score is
#'  based on the query and represents how the query matched the percolate query's
#'  metadata, not how the document (that is being percolated) matched the query. The query
#'  option is required for this option. Defaults to false.
#' - sort - Define a sort specification like in the search API. Currently only
#'  sorting _score reverse (default relevancy) is supported. Other sort fields will
#'  throw an exception. The size and query option are required for this setting. Like
#'  track_score the score is based on the query and represents how the query matched
#'  to the percolate query's metadata and not how the document being percolated matched
#'  to the query.
#' - aggs - Allows aggregation definitions to be included. The aggregations are
#'  based on the matching percolator queries, look at the aggregation documentation on
#'  how to define aggregations.
#' - highlight - Allows highlight definitions to be included. The document being
#'  percolated is being highlight for each matching query. This allows you to see how
#'  each match is highlighting the document being percolated. See highlight documentation
#'  on how to define highlights. The size option is required for highlighting, the
#'  performance of highlighting in the percolate API depends of how many matches are
#'  being highlighted.
#' 
#' @section The Elasticsearch v5 split:
#' In Elasticsearch < v5, there's a certain set of percolate APIs available, 
#' while in Elasticsearch >= v5, there's a different set of APIs available.
#' 
#' Internally within these percolate functions we detect your Elasticsearch
#' version, then use the appropriate APIs
#'
#' @examples \dontrun{
#' x <- connect(errors = "complete")
#' 
#' ##### Elasticsearch < v5
#' if (x$es_ver() < 500) {
#' # typical usage
#' ## create an index first
#' if (index_exists(x, "myindex")) index_delete(x, "myindex")
#' mapping <- '{
#'   "mappings": {
#'     "mytype": {
#'       "properties": {
#'         "message": {
#'            "type": "text"
#'         },
#'         "query": {
#'            "type": "percolator"
#'         }
#'       }
#'     }
#'   }
#' }'
#' index_create(x, "myindex", body = mapping)
#'
#' ## register a percolator
#' perc_body = '{
#'  "query" : {
#'     "match" : {
#'       "message" : "bonsai tree"
#'     }
#'  }
#' }'
#' percolate_register(x, index = "myindex", type = "mytype", 
#'   id = 1, body = perc_body)
#'
#' ## register another
#' perc_body2 <- '{
#'   "query" : {
#'     "match" : {
#'       "message" : "jane doe"
#'     }
#'   }
#' }'
#' percolate_register(x, index = "myindex", type = "mytype", 
#'   id = 2, body = perc_body2)
#'
#' ## match a document to a percolator
#' doc <- '{
#'  "query": {
#'    "percolate": {
#'      "field": "query",
#'      "document": {
#'        "message" : "A new bonsai tree in the office"
#'      }
#'    }
#'  }
#' }'
#' percolate_match(x, index = "myindex", type = "mytype", body = doc)
#'
#' ## List percolators - for an index, no type, can't do across indices
#' percolate_list(x, index = "myindex")$hits$hits
#' 
#' ## Percolate counter
#' percolate_count(x, index = "myindex", type = "mytype", body = doc)$total
#' 
#' ## delete a percolator
#' percolate_delete(x, index = "myindex", id = 2)
#' } # end ES < 5
#' 
#' 
#' ##### Elasticsearch >= v5
#' if (x$es_ver() >= 500) {
#' if (index_exists(x, "myindex")) index_delete(x, "myindex")
#' 
#' body <- '{
#'   "mappings": {
#'     "mytype": {
#'       "properties": {
#'         "message": {
#'            "type": "text"
#'         },
#'         "query": {
#'            "type": "percolator"
#'         }
#'       }
#'     }
#'   }
#' }'
#' 
#' # create the index with mapping
#' index_create(x, "myindex", body = body)
#'
#' ## register a percolator
#' z <- '{
#'   "query" : {
#'      "match" : {
#'        "message" : "bonsai tree"
#'      }
#'   }
#' }'
#' percolate_register(x, index = "myindex", type = "mytype", id = 1, body = z)
#'
#' ## register another
#' x2 <- '{
#'   "query" : {
#'     "match" : {
#'       "message" : "the office"
#'     }
#'   }
#' }'
#' percolate_register(x, index = "myindex", type = "mytype", id = 2, body = x2)
#'
#' ## match a document to a percolator
#' query <- '{
#'   "query" : {
#'     "percolate" : {
#'       "field": "query",
#'       "document": {
#'         "message": "A new bonsai tree in the office"
#'       }
#'     }
#'   }
#' }'
#' percolate_match(x, index = "myindex", body = query)
#' } # end ES >= 5
#' 
#' 
#' }
percolate_register <- function(conn, index, type, id, body=list(),
  routing = NULL, preference = NULL, ignore_unavailable = NULL,
  percolate_format = NULL, refresh = NULL, ...) {

  is_conn(conn)
  #percolate_check_ver(conn)
  url <- conn$make_url()
  if (conn$es_ver() >= 500) {
    url <- file.path(url, esc(index), esc(type), id)
  } else {
    url <- sprintf("%s/%s/.percolator/%s", url, esc(index), id)
  }
  args <- ec(list(routing = routing, preference = preference,
                  ignore_unavailable = as_log(ignore_unavailable),
                  percolate_format = percolate_format, 
                  refresh = as_log(refresh)))
  percolate_PUT(conn, url, args, body, ...)
}

#' @export
#' @rdname percolate
percolate_match <- function(conn, index, type=NULL, body,
  routing = NULL, preference = NULL, ignore_unavailable = NULL,
  percolate_format = NULL, ...) {

  is_conn(conn)
  #percolate_check_ver(conn)
  url <- conn$make_url()
  if (conn$es_ver() >= 500) {
    url <- file.path(
      url, 
      if (is.null(type)) esc(index) else file.path(esc(index), esc(type)), 
      "_search")
  } else {
    url <- sprintf("%s/%s/%s/_percolate", url, esc(index), esc(type))
  }
  args <- ec(list(routing = routing, preference = preference,
                  ignore_unavailable = ignore_unavailable,
                  percolate_format = percolate_format))
  if (length(args) == 0) args <- NULL
  percolate_POST(conn, url, args, body = body, ...)
}

#' @export
#' @rdname percolate
percolate_list <- function(conn, index, ...) {
  is_conn(conn)
  percolate_check_ver(conn)
  Search(conn, index, search_path = ".percolator/_search", ...)
}

#' @export
#' @rdname percolate
percolate_count <- function(conn, index, type, body, ...) {
  is_conn(conn)
  percolate_check_ver(conn)
  url <- conn$make_url()
  url <- sprintf("%s/%s/%s/_percolate/count", url, esc(index), esc(type))
  percolate_POST(conn, url, body = body, ...)
}

#' @export
#' @rdname percolate
percolate_delete <- function(conn, index, id, ...) {
  is_conn(conn)
  percolate_check_ver(conn)
  url <- conn$make_url()
  url <- sprintf("%s/%s/.percolator/%s", url, esc(index), id)
  es_DELETE(conn, url, list(), ...)
}

# helpers ------------
percolate_PUT <- function(conn, url, args, body = list(), ...) {
  body <- check_inputs(body)
  cli <- conn$make_conn(url, json_type(), ...)
  tt <- cli$put(body = body, query = args, encode = 'json')
  geterror(tt)
  jsonlite::fromJSON(tt$parse("UTF-8"), FALSE)
}

percolate_POST <- function(conn, url, args = NULL, body = list(), ...) {
  body <- check_inputs(body)
  cli <- conn$make_conn(url, json_type(), ...)
  tt <- cli$post(body = body, query = args, encode = 'json')
  geterror(tt)
  jsonlite::fromJSON(tt$parse("UTF-8"), FALSE)
}

percolate_check_ver <- function(conn) {
  if (conn$es_ver() >= 500) {
    stop("this percolate functionality defunct in ES >= v5
  For ES >= v5 see percolate examples in ?Search")
  }  
}
