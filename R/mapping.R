#' Mapping management
#'
#' @name mapping
#' @param conn an Elasticsearch connection object, see [Elasticsearch]
#' @param index (character) An index
#' @param type (character) A document type
#' @param body (list) Either a list or json, representing the query.
#' @param field (character) One or more field names
#' @param include_defaults (logical) Whether to return default values
#' @param update_all_types (logical) update all types. default: `FALSE`. 
#' This parameter is deprecated in ES v6.3.0 and higher, see 
#' https://github.com/elastic/elasticsearch/pull/28284
#' @param ... Curl options passed on to [crul::verb-PUT], [crul::verb-GET], 
#' or [crul::verb-HEAD]
#' @details
#' Find documentation for each function at:
#' 
#' - `mapping_create` -
#'  <https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-put-mapping.html>
#' - `type_exists` -
#'  <https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-types-exists.html>
#' - `mapping_delete` - FUNCTION DEFUNCT - instead of deleting mapping, delete
#'  index and recreate index with new mapping
#' - `mapping_get` -
#'  <https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-get-mapping.html>
#' - `field_mapping_get` -
#' <https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-get-field-mapping.html>
#'
#' @examples \dontrun{
#' # connection setup
#' (x <- connect())
#' 
#' # Used to check if a type/types exists in an index/indices
#' type_exists(x, index = "plos", type = "article")
#' type_exists(x, index = "plos", type = "articles")
#' type_exists(x, index = "shakespeare", type = "line")
#'
#' # The put mapping API allows to register specific mapping definition for a specific type.
#' ## a good mapping body
#' body <- list(citation = list(properties = list(
#'  journal = list(type="text"),
#'  year = list(type="long")
#' )))
#' if (!index_exists(x, "plos")) index_create(x, "plos")
#' mapping_create(x, index = "plos", type = "citation", body=body)
#'
#' ### or as json
#' body <- '{
#'   "citation": {
#'     "properties": {
#'       "journal": { "type": "text" },
#'       "year": { "type": "long" }
#' }}}'
#' mapping_create(x, index = "plos", type = "citation", body=body)
#' mapping_get(x, "plos", "citation")
#'
#' ## A bad mapping body
#' body <- list(things = list(properties = list(
#'   journal = list("text")
#' )))
#' # mapping_create(x, index = "plos", type = "things", body=body)
#'
#' # Get mappings
#' mapping_get(x, '_all')
#' mapping_get(x, index = "plos")
#' mapping_get(x, index = c("shakespeare","plos"))
#' # mapping_get(x, index = "shakespeare", type = "act")
#' # mapping_get(x, index = "shakespeare", type = c("act","line"))
#'
#' # Get field mappings
#' plosdat <- system.file("examples", "plos_data.json", package = "elastic")
#' invisible(docs_bulk(x, plosdat))
#' field_mapping_get(x, index = "_all", type=c('article', 'line'), field = "text")
#' field_mapping_get(x, index = "plos", type = "article", field = "title")
#' field_mapping_get(x, index = "plos", type = "article", field = "*")
#' field_mapping_get(x, index = "plos", type = "article", field = "title", include_defaults = TRUE)
#' field_mapping_get(x, type = c("article","record"), field = c("title","class"))
#' field_mapping_get(x, type = "a*", field = "t*")
#'
#' # Create geospatial mapping
#' if (index_exists(x, "gbifgeopoint")) index_delete(x, "gbifgeopoint")
#' file <- system.file("examples", "gbif_geopoint.json", package = "elastic")
#' index_create(x, "gbifgeopoint")
#' body <- '{
#'  "properties" : {
#'    "location" : { "type" : "geo_point" }
#'  }
#' }'
#' mapping_create(x, "gbifgeopoint", "record", body = body)
#' invisible(docs_bulk(x, file))
#' 
#' # update_all_fields, see also ?fielddata
#' if (x$es_ver() < 603) {
#'  mapping_create(x, "shakespeare", "record", update_all_types=TRUE, body = '{
#'    "properties": {
#'      "speaker": { 
#'        "type":     "text",
#'        "fielddata": true
#'      }
#'    }
#'  }')
#' } else {
#'  index_create(x, 'brownchair')
#'  mapping_create(x, 'brownchair', 'brown', body = '{
#'    "properties": {
#'      "foo": { 
#'        "type":     "text",
#'        "fielddata": true
#'      }
#'    }
#'  }')
#' }
#' 
#' }

#' @export
#' @rdname mapping
mapping_create <- function(conn, index, type, body, update_all_types = FALSE, ...) {
  is_conn(conn)
  url <- conn$make_url()
  url <- file.path(url, esc(index), "_mapping", esc(type))
  args <- list()
  if (conn$es_ver() < 603) { 
    args <- ec(list(update_all_types = as_log(update_all_types)))
  }
  es_PUT(conn, url, body, args, ...)
}

#' @export
#' @rdname mapping
mapping_get <- function(conn, index = NULL, type = NULL, ...) {
  is_conn(conn)
  url <- conn$make_url()
  if (any(index == "_all")) {
    url <- file.path(url, "_mapping")
  } else {
    if (is.null(type)) {
      url <- file.path(url, esc(cl(index)), "_mapping")
    } else if (is.null(index) && !is.null(type)) {
      url <- file.path(url, "_mapping", esc(cl(type)))
    } else if (!is.null(index) && !is.null(type)) {
      if (length(index) > 1) stop("You can only pass one index if you also pass a type", call. = FALSE)
      url <- file.path(url, esc(index), "_mapping", esc(cl(type)))
    }
  }
  es_GET_(conn, url, ...)
}

#' @export
#' @rdname mapping
field_mapping_get <- function(conn, index = NULL, type = NULL, field, include_defaults=FALSE, ...) {
  is_conn(conn)
  stopifnot(!is.null(field))
  url <- conn$make_url()
  if (any(index == "_all")){
    conn$stop_es_version(110, "field_mapping_get")
    stopifnot(!is.null(type))
    url <- file.path(url, "_all/_mapping", esc(cl(type)), "field", cl(field))
  } else {
    if(is.null(type)){
      url <- file.path(url, esc(cl(index)), "_mapping/field", cl(field))
    } else if(is.null(index) && !is.null(type)) {
      url <- file.path(url, "_all/_mapping", esc(cl(type)), "field", cl(field))
    } else if(!is.null(index) && !is.null(type)) {
      if(length(index) > 1) stop("You can only pass one index if you also pass a type", call. = FALSE)
      url <- file.path(url, esc(index), "_mapping", esc(cl(type)), "field", cl(field))
    }
  }
  es_GET_(conn, url, query=list(include_defaults=as_log(include_defaults)), ...)
}

#' @export
#' @rdname mapping
type_exists <- function(conn, index, type, ...) {
  is_conn(conn)
  # seems to not work in v1, so don't try cause would give false result
  if (conn$es_ver() <= 100) {
    stop("type exists not available in this ES version", call. = FALSE)
  }
  url <- conn$make_url()
  
  if (conn$es_ver() >= 500) {
    # in ES >= v5, new URL format
    url <- file.path(url, esc(index), "_mapping", esc(type))
  } else {
    # in ES < v5, old URL format
    url <- file.path(url, esc(index), esc(type))
  }
  
  res <- conn$make_conn(url, ...)$head()
  if (res$status_code == 200) TRUE else FALSE
}
