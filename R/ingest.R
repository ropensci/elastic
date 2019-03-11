#' Ingest API operations
#'
#' @references
#' <https://www.elastic.co/guide/en/elasticsearch/reference/current/ingest-apis.html>
#' @name ingest
#'
#' @param conn an Elasticsearch connection object, see [connect()]
#' @param id (character) one or more pipeline id's. with delete, you can use 
#' a wildcard match
#' @param body body describing pipeline, see examples and Elasticsearch docs
#' @param filter_path (character) fields to return. deafults to all if not given
#' @param ... Curl args passed on to [crul::verb-POST], [crul::verb-GET],
#' [crul::verb-PUT], or [crul::verb-DELETE]
#' 
#' @return a named list
#' 
#' @details ingest/pipeline functions available in Elasticsearch v5 and greater
#'
#' @examples \dontrun{
#' # connection setup
#' (x <- connect())
#' 
#' # create
#' body1 <- '{
#'   "description" : "do a thing",
#'   "version" : 123,
#'   "processors" : [
#'     {
#'       "set" : {
#'         "field": "foo",
#'         "value": "bar"
#'       }
#'     }
#'   ]
#' }'
#' body2 <- '{
#'   "description" : "do another thing",
#'   "processors" : [
#'     {
#'       "set" : {
#'         "field": "stuff",
#'         "value": "things"
#'       }
#'     }
#'   ]
#' }'
#' pipeline_create(x, id = 'foo', body = body1)
#' pipeline_create(x, id = 'bar', body = body2)
#' 
#' # get
#' pipeline_get(x, id = 'foo')
#' pipeline_get(x, id = 'bar')
#' pipeline_get(x, id = 'foo', filter_path = "*.version")
#' pipeline_get(x, id = c('foo', 'bar')) # get >1
#' 
#' # delete
#' pipeline_delete(x, id = 'foo')
#' 
#' # simulate
#' ## with pipeline included
#' body <- '{
#'   "pipeline" : {
#'     "description" : "do another thing",
#'     "processors" : [
#'       {
#'         "set" : {
#'           "field": "stuff",
#'           "value": "things"
#'         }
#'       }
#'     ]
#'   },
#'   "docs" : [
#'     { "_source": {"foo": "bar"} },
#'     { "_source": {"foo": "world"} }
#'   ]
#' }'
#' pipeline_simulate(x, body)
#' 
#' ## referencing existing pipeline
#' body <- '{
#'   "docs" : [
#'     { "_source": {"foo": "bar"} },
#'     { "_source": {"foo": "world"} }
#'   ]
#' }'
#' pipeline_simulate(x, body, id = "foo")
#' }
NULL

#' @export
#' @rdname ingest
pipeline_create <- function(conn, id, body, ...) {
  is_conn(conn)
  pipeline_ver(conn)
  url <- conn$make_url()
  es_PUT(conn, file.path(url, "_ingest/pipeline", esc(id)), body = body, ...)
}

#' @export
#' @rdname ingest
pipeline_get <- function(conn, id, filter_path = NULL, ...) {
  is_conn(conn)
  pipeline_ver(conn)
  url <- file.path(conn$make_url(), "_ingest/pipeline", 
    paste0(esc(id), collapse = ","))
  es_GET_(conn, url, ec(list(filter_path = filter_path)), ...)
}

#' @export
#' @rdname ingest
pipeline_delete <- function(conn, id, body, ...) {
  is_conn(conn)
  pipeline_ver(conn)
  url <- file.path(conn$make_url(), "_ingest/pipeline", esc(id))
  out <- conn$make_conn(url, list(), ...)$delete()
  geterror(conn, out)
  jsonlite::fromJSON(out$parse("UTF-8"))
}

#' @export
#' @rdname ingest
pipeline_simulate <- function(conn, body, id = NULL, ...) {
  is_conn(conn)
  pipeline_ver(conn)
  url <- conn$make_url()
  base <- "_ingest/pipeline"
  part <- if (is.null(id)) {
    file.path(base, "_simulate") 
  } else {
    file.path(base, esc(id), "_simulate")
  }
  url <- file.path(url, part)
  tt<-conn$make_conn(url, json_type(), ...)$post(body = body, encode = "json")
  geterror(conn, tt)
  jsonlite::fromJSON(tt$parse("UTF-8"))
}

pipeline_ver <- function(conn) {
  if (conn$es_ver() < 500) {
    stop("ingest/pipeline fxns available in ES v5 and greater", call. = FALSE)
  }
}
