#' Mapping management
#' 
#' @name mapping
#' @param index (character) An index
#' @param type (character) A document type
#' @param body (list) Either a list or json, representing the query.
#' @param field (character) One or more field names
#' @param include_defaults (logical) Whether to return default values
#' @param ... Options passed on to \code{\link[httr]{HEAD}}
#' @details 
#' Find documentation for each function at:
#' \itemize{
#'  \item mapping_create - \url{http://bit.ly/1xbWqFo}
#'  \item type_exists - \url{http://bit.ly/10HkZvH}
#'  \item mapping_delete - \url{http://bit.ly/10Mmvgi}
#'  \item mapping_get - \url{http://bit.ly/1AN2oiw}
#'  \item field_mapping_get - \url{http://bit.ly/1wHKgCA }
#' }
#' 
#' \strong{NOTE:} For the delete method, Elasticsearch documentation notes that: "... most times, 
#' it make more sense to reindex the data into a fresh index compared to delete large chunks of it."
#' @examples \donttest{
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
#' mapping_create(index = "plos", type = "citation", body=body)
#' 
#' ### or as json
#' body <- '{
#'   "citation": {
#'     "properties": {
#'       "journal": { "type": "string" },
#'       "year": { "type": "long" }
#' }}}'
#' mapping_delete("plos", "citation")
#' mapping_create(index = "plos", type = "citation", body=body)
#' mapping_get("plos", "citation")
#' 
#' ## A bad mapping body
#' body <- list(things = list(properties = list(
#'   journal = list("string")
#' )))
#' mapping_create(index = "plos", type = "things", body=body)
#' 
#' # Delete a mapping
#' mapping_delete("plos", "citation")
#' 
#' # Get mappings
#' mapping_get('_all')
#' mapping_get(index = "plos")
#' mapping_get(index = c("shakespeare","plos"))
#' mapping_get(index = "shakespeare", type = "act")
#' mapping_get(index = "shakespeare", type = c("act","line"))
#' 
#' # Get field mappings
#' field_mapping_get(index = "_all", type=c('article','line'), field = "text")
#' field_mapping_get(index = "plos", type = "article", field = "title")
#' field_mapping_get(index = "plos", type = "article", field = "*")
#' field_mapping_get(index = "plos", type = "article", field = "title", include_defaults = TRUE)
#' field_mapping_get(type = c("article","record"), field = c("title","class"))
#' field_mapping_get(type = "a*", field = "t*")
#' }

#' @export
#' @rdname mapping
mapping_create <- function(index, type, body, ...){
  conn <- es_connect()
  url <- file.path(paste0(conn$base, ":", conn$port), index, "_mapping", type)
  es_PUT(url, body, ...)
}

#' @export
#' @rdname mapping
mapping_delete <- function(index, type, ...){
  conn <- es_connect()
  es_DELETE(file.path(paste0(conn$base, ":", conn$port), index, "_mapping", type), ...)
}

#' @export
#' @rdname mapping
mapping_get <- function(index = NULL, type = NULL, ...){
  conn <- es_connect()
  if(any(index == "_all")){
    url <- file.path(paste0(conn$base, ":", conn$port), "_mapping")
  } else {
    if(is.null(type)){
      url <- file.path(paste0(conn$base, ":", conn$port), cl(index), "_mapping")
    } else if(is.null(index) && !is.null(type)) {
      url <- file.path(paste0(conn$base, ":", conn$port), "_mapping", cl(type))
    } else if(!is.null(index) && !is.null(type)) {
      if(length(index) > 1) stop("You can only pass one index if you also pass a type", call. = FALSE)
      url <- file.path(paste0(conn$base, ":", conn$port), index, "_mapping", cl(type))
    }
  }
  es_GET_(url, ...)
}

#' @export
#' @rdname mapping
field_mapping_get <- function(index = NULL, type = NULL, field, include_defaults=FALSE, ...){
  stopifnot(!is.null(field))
  conn <- es_connect()
  if(any(index == "_all")){
    stopifnot(!is.null(type))
    url <- file.path(paste0(conn$base, ":", conn$port), "_all/_mapping", cl(type), "field", cl(field))
  } else {
    if(is.null(type)){
      url <- file.path(paste0(conn$base, ":", conn$port), cl(index), "_mapping/field", cl(field))
    } else if(is.null(index) && !is.null(type)) {
      url <- file.path(paste0(conn$base, ":", conn$port), "_all/_mapping", cl(type), "field", cl(field))
    } else if(!is.null(index) && !is.null(type)) {
      if(length(index) > 1) stop("You can only pass one index if you also pass a type", call. = FALSE)
      url <- file.path(paste0(conn$base, ":", conn$port), index, "_mapping", cl(type), "field", cl(field))
    }
  }
  es_GET_(url, query=list(include_defaults=as_log(include_defaults)), ...)
}

#' @export
#' @rdname mapping
type_exists <- function(index, type, ...){
  conn <- es_connect()
  res <- HEAD(file.path(paste0(conn$base, ":", conn$port), index, type), ...)
  if(res$status_code == 200) TRUE else FALSE
}
