#' @title Index templates
#'
#' @description Index templates allow you to define templates that 
#' will automatically be applied when new indices are created
#'
#' @export
#' @name index_template
#' @param conn an Elasticsearch connection object, see [connect()]
#' @param name (character) The name of the template
#' @param body (character/list) The template definition
#' @param create (logical) Whether the index template should only be added 
#' if new or can also replace an existing one. Default: `FALSE`
#' @param flat_settings (logical) Return settings in flat format. 
#' Default: `FALSE`
#' @param master_timeout (integer) Specify timeout for connection to master
#' @param order (integer) The order for this template when merging 
#' multiple matching ones (higher numbers are merged later, overriding the 
#' lower numbers)
#' @param filter_path (character) a regex for filtering output path, 
#' see example
#' @param timeout (integer) Explicit operation timeout
#' @param ... Curl options. Or in `percolate_list` function, further 
#' args passed on to [Search()]
#'
#' @references
#' <https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-templates.html>
#'
#' @examples \dontrun{
#' (x <- connect())
#' 
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
#' index_template_put(x, "template_1", body = body)
#' 
#' # get templates
#' index_template_get(x)
#' index_template_get(x, "template_1")
#' index_template_get(x, c("template_1", "template_2"))
#' index_template_get(x, "template_*")
#' ## filter path
#' index_template_get(x, "template_1", filter_path = "*.template")
#' 
#' # template exists
#' index_template_exists(x, "template_1")
#' index_template_exists(x, "foobar")
#' 
#' # delete a template
#' index_template_delete(x, "template_1")
#' index_template_exists(x, "template_1")
#' }
index_template_put <- function(
  conn, name, body = NULL, create = NULL, flat_settings = NULL, 
  master_timeout = NULL, order = NULL, timeout = NULL, ...) {
  
  is_conn(conn)
  url <- conn$make_url()
  url <- file.path(url, "_template", esc(name))
  args <- ec(list(create = create, flat_settings = flat_settings,
                  master_timeout = master_timeout,
                  order = order, timeout = timeout))
  indtemp_PUT(conn, url, args, body, ...)
}

#' @export
#' @rdname index_template
index_template_get <- function(conn, name = NULL, filter_path = NULL, ...) {
  is_conn(conn)
  url <- file.path(conn$make_url(), "_template")
  if (!is.null(name)) {
    if (length(name) > 1) name <- paste0(esc(name), collapse = ",")
    url <- file.path(url, name)
  }
  args <- ec(list(filter_path = filter_path))
  indtemp_GET(conn, url, args, ...)
}

#' @export
#' @rdname index_template
index_template_exists <- function(conn, name, ...) {
  is_conn(conn)
  url <- file.path(conn$make_url(), "_template", name)
  indtemp_HEAD(conn, url, ...)
}

#' @export
#' @rdname index_template
index_template_delete <- function(conn, name, ...) {
  is_conn(conn)
  url <- file.path(conn$make_url(), "_template", name)
  indtemp_DELETE(conn, url, ...)
}


# helpers ------------
indtemp_PUT <- function(conn, url, args, body = list(), ...) {
  body <- check_inputs(body)
  cli <- conn$make_conn(url, json_type(), ...)
  tt <- cli$put(body = body, query = args, encode = 'json')
  geterror(conn, tt)
  tt$status_code == 200
}

indtemp_GET <- function(conn, url, args, ...) {
  tt <- conn$make_conn(url, json_type(), ...)$get(query = args)
  geterror(conn, tt)
  jsonlite::fromJSON(tt$parse("UTF-8"), FALSE)
}

indtemp_HEAD <- function(conn, url, ...) {
  tt <- conn$make_conn(url, json_type(), ...)$head()
  tt$status_code == 200
}

indtemp_DELETE <- function(conn, url, ...) {
  tt <- conn$make_conn(url, json_type(), ...)$delete()
  geterror(conn, tt)
  tt$status_code == 200
}
