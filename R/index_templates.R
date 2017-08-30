#' @title Index templates
#'
#' @description Index templates allow you to define templates that 
#' will automatically be applied when new indices are created
#'
#' @export
#' @name index_template
#' @param name (character) The name of the template
#' @param body (character/list) The template definition
#' @param create (logical) Whether the index template should only be added 
#' if new or can also replace an existing one. Default: \code{FALSE}
#' @param flat_settings (logical) Return settings in flat format. 
#' Default: \code{FALSE}
#' @param master_timeout (integer) Specify timeout for connection to master
#' @param order (integer) The order for this template when merging 
#' multiple matching ones (higher numbers are merged later, overriding the 
#' lower numbers)
#' @param filter_path (character) a regex for filtering output path, 
#' see example
#' @param timeout (integer) Explicit operation timeout
#' @param ... Curl options. Or in \code{percolate_list} function, further 
#' args passed on to \code{\link{Search}}
#'
#' @references
#' \url{https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-templates.html}
#'
#' @examples \dontrun{
#' body <- '{
#'   "template": "te*",
#'   "settings": {
#'     "number_of_shards": 1
#'   },
#'   "mappings": {
#'     "type1": {
#'       "_source": {
#'         "enabled": false
#'       },
#'       "properties": {
#'         "host_name": {
#'           "type": "keyword"
#'         },
#'         "created_at": {
#'           "type": "date",
#'           "format": "EEE MMM dd HH:mm:ss Z YYYY"
#'         }
#'       }
#'     }
#'   }
#' }'
#' index_template_put("template_1", body = body)
#' 
#' # get templates
#' index_template_get()
#' index_template_get("template_1")
#' index_template_get(c("template_1", "template_2"))
#' index_template_get("template_*")
#' ## filter path
#' index_template_get("template_1", filter_path = "*.template")
#' 
#' # template exists
#' index_template_exists("template_1")
#' index_template_exists("foobar")
#' 
#' # delete a template
#' index_template_delete("template_1")
#' index_template_exists("template_1")
#' }
index_template_put <- function(
  name, body = NULL, create = NULL, flat_settings = NULL, master_timeout = NULL,
  order = NULL, timeout = NULL, ...) {
  
  url <- make_url(es_get_auth())
  url <- file.path(url, "_template", esc(name))
  args <- ec(list(create = create, flat_settings = flat_settings,
                  master_timeout = master_timeout,
                  order = order, timeout = timeout))
  indtemp_PUT(url, args, body, ...)
}

#' @export
#' @rdname index_template
index_template_get <- function(name = NULL, filter_path = NULL, ...) {
  url <- file.path(make_url(es_get_auth()), "_template")
  if (!is.null(name)) {
    if (length(name) > 1) name <- paste0(esc(name), collapse = ",")
    url <- file.path(url, name)
  }
  args <- ec(list(filter_path = filter_path))
  indtemp_GET(url, args, ...)
}

#' @export
#' @rdname index_template
index_template_exists <- function(name, ...) {
  url <- file.path(make_url(es_get_auth()), "_template", name)
  indtemp_HEAD(url, ...)
}

#' @export
#' @rdname index_template
index_template_delete <- function(name, ...) {
  url <- file.path(make_url(es_get_auth()), "_template", name)
  indtemp_DELETE(url, ...)
}


# helpers ------------
indtemp_PUT <- function(url, args, body = list(), ...) {
  body <- check_inputs(body)
  tt <- PUT(url, body = body, query = args, encode = 'json', 
            make_up(), content_type_json(), es_env$headers, ...)
  geterror(tt)
  if (tt$status_code == 200) TRUE else FALSE
}

indtemp_GET <- function(url, args, ...) {
  tt <- GET(url, query = args, make_up(), 
            content_type_json(), es_env$headers, ...)
  geterror(tt)
  jsonlite::fromJSON(cont_utf8(tt), FALSE)
}

indtemp_HEAD <- function(url, ...) {
  tt <- HEAD(url, make_up(), content_type_json(), es_env$headers, ...)
  if (tt$status_code == 200) TRUE else FALSE
}

indtemp_DELETE <- function(url, ...) {
  tt <- DELETE(url, make_up(), es_env$headers, ...)
  geterror(tt)
  if (tt$status_code == 200) TRUE else FALSE
}
