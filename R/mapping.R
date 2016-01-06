#' Mapping management
#'
#' @name mapping
#' @param index (character) An index
#' @param type (character) A document type
#' @param body (list) Either a list or json, representing the query.
#' @param field (character) One or more field names
#' @param include_defaults (logical) Whether to return default values
#' @param ... Curl options passed on to \code{\link[httr]{HEAD}} or other http verbs
#' @details
#' Find documentation for each function at:
#' \itemize{
#'  \item mapping_create - 
#'  \url{https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-put-mapping.html}
#'  \item type_exists - 
#'  \url{https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-types-exists.html}
#'  \item mapping_delete - FUNCTION DEFUNCT - instead of deleting mapping, delete 
#'  index and recreate index with new mapping
#'  \item mapping_get - 
#'  \url{https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-get-mapping.html}
#'  \item field_mapping_get - 
#'\url{https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-get-field-mapping.html}
#' }
#'
#' @examples \dontrun{
#' # Used to check if a type/types exists in an index/indices
#' type_exists(index = "plos", type = "article")
#' type_exists(index = "plos", type = "articles")
#' type_exists(index = "shakespeare", type = "line")
#'
#' # The put mapping API allows to register specific mapping definition for a specific type.
#' ## a good mapping body
#' body <- list(citation = list(properties = list(
#'  journal = list(type="string"),
#'  year = list(type="long")
#' )))
#' if (!index_exists("plos")) index_create("plos")
#' mapping_create(index = "plos", type = "citation", body=body)
#'
#' ### or as json
#' body <- '{
#'   "citation": {
#'     "properties": {
#'       "journal": { "type": "string" },
#'       "year": { "type": "long" }
#' }}}'
#' mapping_create(index = "plos", type = "citation", body=body)
#' mapping_get("plos", "citation")
#'
#' ## A bad mapping body
#' body <- list(things = list(properties = list(
#'   journal = list("string")
#' )))
#' # mapping_create(index = "plos", type = "things", body=body)
#'
#' # Get mappings
#' mapping_get('_all')
#' mapping_get(index = "plos")
#' mapping_get(index = c("shakespeare","plos"))
#' mapping_get(index = "shakespeare", type = "act")
#' mapping_get(index = "shakespeare", type = c("act","line"))
#'
#' # Get field mappings
#' plosdat <- system.file("examples", "plos_data.json", package = "elastic")
#' docs_bulk(plosdat)
#' field_mapping_get(index = "_all", type=c('article', 'line'), field = "text")
#' field_mapping_get(index = "plos", type = "article", field = "title")
#' field_mapping_get(index = "plos", type = "article", field = "*")
#' field_mapping_get(index = "plos", type = "article", field = "title", include_defaults = TRUE)
#' field_mapping_get(type = c("article","record"), field = c("title","class"))
#' field_mapping_get(type = "a*", field = "t*")
#'
#' # Create geospatial mapping
#' file <- system.file("examples", "gbif_geopoint.json", package = "elastic")
#' docs_bulk(file)
#' body <- '{
#'  "properties" : {
#'    "location" : { "type" : "geo_point" }
#'  }
#' }'
#' mapping_create("gbifgeopoint", "record", body = body)
#' }

#' @export
#' @rdname mapping
mapping_create <- function(index, type, body, ...){
  url <- make_url(es_get_auth())
  url <- file.path(url, esc(index), "_mapping", esc(type))
  es_PUT(url, body, ...)
}

#' @export
#' @rdname mapping
mapping_get <- function(index = NULL, type = NULL, ...){
  url <- make_url(es_get_auth())
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
  es_GET_(url, ...)
}

#' @export
#' @rdname mapping
field_mapping_get <- function(index = NULL, type = NULL, field, include_defaults=FALSE, ...){
  stopifnot(!is.null(field))
  url <- make_url(es_get_auth())
  if (any(index == "_all")){
    stop_es_version(110, "field_mapping_get")
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
  es_GET_(url, query=list(include_defaults=as_log(include_defaults)), ...)
}

#' @export
#' @rdname mapping
type_exists <- function(index, type, ...){
  checkconn()
  url <- make_url(es_get_auth())
  res <- HEAD(file.path(url, esc(index), esc(type)), make_up(), ...)
  if (res$status_code == 200) TRUE else FALSE
}
