#' Ingest API operations
#'
#' @references
#' <https://www.elastic.co/guide/en/elasticsearch/reference/current/ingest-apis.html>
#' @name ingest
#'
#' @param id (character) one or more pipeline id's. with delete, you can use 
#' a wildcard match
#' @param body body describing pipeline, see examples and Elasticsearch docs
#' @param filter_path (character) fields to return. deafults to all if not given
#' @param ... Curl args passed on to [httr::POST()], [httr::GET()],
#' [httr::PUT()], or [httr::DELETE()]
#' 
#' @return a named list
#' 
#' @details ingest/pipeline functions available in Elasticsearch v5 and greater
#'
#' @examples \dontrun{
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
#' pipeline_create(id = 'foo', body = body1)
#' pipeline_create(id = 'bar', body = body2)
#' 
#' # get
#' pipeline_get(id = 'foo')
#' pipeline_get(id = 'bar')
#' pipeline_get(id = 'foo', filter_path = "*.version")
#' pipeline_get(id = c('foo', 'bar')) # get >1
#' 
#' # delete
#' pipeline_delete(id = 'foo')
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
#' pipeline_simulate(body)
#' 
#' ## referencing existing pipeline
#' body <- '{
#'   "docs" : [
#'     { "_source": {"foo": "bar"} },
#'     { "_source": {"foo": "world"} }
#'   ]
#' }'
#' pipeline_simulate(body, id = "foo")
#' }
NULL

#' @export
#' @rdname ingest
pipeline_create <- function(id, body, ...) {
  pipeline_ver()
  url <- make_url(es_get_auth())
  es_PUT(file.path(url, "_ingest/pipeline", esc(id)), body = body, ...)
}

#' @export
#' @rdname ingest
pipeline_get <- function(id, filter_path = NULL, ...) {
  pipeline_ver()
  url <- make_url(es_get_auth())
  es_GET_(file.path(url, "_ingest/pipeline", paste0(esc(id), collapse = ",")),
    ec(list(filter_path = filter_path)), ...)
}

#' @export
#' @rdname ingest
pipeline_delete <- function(id, body, ...) {
  pipeline_ver()
  url <- file.path(make_url(es_get_auth()), "_ingest/pipeline", esc(id))
  out <- DELETE(url, make_up(), ...)
  geterror(out)
  jsonlite::fromJSON(cont_utf8(out))
}

#' @export
#' @rdname ingest
pipeline_simulate <- function(body, id = NULL, ...) {
  pipeline_ver()
  url <- make_url(es_get_auth())
  base <- "_ingest/pipeline"
  part <- if (is.null(id)) {
    file.path(base, "_simulate") 
  } else {
    file.path(base, esc(id), "_simulate")
  }
  url <- file.path(url, part)
  tt <- POST(url, body = body, content_type_json(),
             es_env$headers, make_up(), encode = "json", ...)
  geterror(tt)
  jsonlite::fromJSON(cont_utf8(tt))
}

pipeline_ver <- function() {
  if (es_ver() < 500) {
    stop("ingest/pipeline fxns available in ES v5 and greater", call. = FALSE)
  }
}
