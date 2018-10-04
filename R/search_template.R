#' Search or validate templates
#'
#' @export
#' @name Search_template
#' @param conn an Elasticsearch connection object, see [Elasticsearch]
#' @param template (character) a template name
#' @param body Query, either a list or json.
#' @param raw (logical) If `FALSE` (default), data is parsed to list.
#' If `TRUE`, then raw JSON returned
#' @param ... Curl args passed on to [httr::POST()]
#'
#' @seealso [Search()], [Search_uri()]
#'
#' @section Template search:
#' With `Search_template` you can search with a template, using
#' mustache templating. Added in Elasticsearch v1.1
#'
#' @section Template render:
#' With `Search_template_render` you validate a template without
#' conducting the search. Added in Elasticsearch v2.0
#'
#' @section Pre-registered templates:
#' Register a template with `Search_template_register`. You can get 
#' the template with `Search_template_get` and delete the template 
#' with `Search_template_delete`
#' 
#' You can also pre-register search templates by storing them in the 
#' `config/scripts` directory, in a file using the .mustache 
#' extension. In order to execute the stored template, reference it 
#' by it's name under the template key, like 
#' `"file": "templateName", ...`
#' 
#' @references 
#' <https://www.elastic.co/guide/en/elasticsearch/reference/current/search-template.html>
#'
#' @examples \dontrun{
#' # connection setup
#' (x <- connect())
#' 
#' if (!index_exists(x, "iris")) {
#'   invisible(docs_bulk(x, iris, "iris"))
#' }
#'
#' body1 <- '{
#'   "inline" : {
#'     "query": { "match" : { "{{my_field}}" : "{{my_value}}" } },
#'     "size" : "{{my_size}}"
#'   },
#'   "params" : {
#'     "my_field" : "Species",
#'     "my_value" : "setosa",
#'     "my_size" : 3
#'   }
#' }'
#' Search_template(x, body = body1)
#'
#' body2 <- '{
#'  "inline": {
#'    "query": {
#'       "match": {
#'           "Species": "{{query_string}}"
#'       }
#'    }
#'  },
#'  "params": {
#'    "query_string": "versicolor"
#'  }
#' }'
#' Search_template(x, body = body2)
#'
#' # pass in a list
#' mylist <- list(
#'   inline = list(query = list(match = list(`{{my_field}}` = "{{my_value}}"))),
#'   params = list(my_field = "Species", my_value = "setosa", my_size = 3L)
#' )
#' Search_template(x, body = mylist)
#'
#' ## Validating templates w/ Search_template_render()
#' Search_template_render(x, body = body1)
#' Search_template_render(x, body = body2)
#'
#' ## pre-registered templates
#' ### register a template
#' body3 <- '{
#'   "template": {
#'      "query": {
#'          "match": {
#'              "Species": "{{query_string}}"
#'          }
#'      }
#'    }
#' }'
#' Search_template_register(x, 'foobar', body = body3)
#'
#' ### get template
#' Search_template_get(x, 'foobar')
#'
#' ### use the template
#' body4 <- '{
#'  "id": "foobar",
#'   	"params": {
#'       "query_string": "setosa"
#'   }
#' }'
#' Search_template(x, body = body4)
#'
#' ### delete the template
#' Search_template_delete(x, 'foobar')
#' }
Search_template <- function(conn, body = list(), raw = FALSE, ...) {
  # search template render added in Elasticsearch v1.1, stop if version pre that
  if (conn$es_ver() < 110) {
    stop("search template not available in this ES version", call. = FALSE)
  }
  search_POST(conn, "_search/template", args = list(), body = body, raw = raw, 
              asdf = FALSE, stream_opts = list(), ...)
}

#' @export
#' @rdname Search_template
Search_template_register <- function(conn, template, body = list(), raw = FALSE, 
                                     ...) {
  # search template render added in Elasticsearch v1.1, stop if version pre that
  if (conn$es_ver() < 110) {
    stop("search template not available in this ES version", call. = FALSE)
  }
  search_POST(conn, 
    paste0("_search/template/", template),
    args = list(), body = body, raw = raw, asdf = FALSE, 
    stream_opts = list(), ...
  )
}

#' @export
#' @rdname Search_template
Search_template_get <- function(conn, template, ...) {
  # search template render added in Elasticsearch v1.1, stop if version pre that
  if (conn$es_ver() < 110) {
    stop("search template not available in this ES version", call. = FALSE)
  }
  url <- conn$make_url()
  url <- paste0(url, "/_search/template/", template)
  es_GET_(conn, url, ...)
}

#' @export
#' @rdname Search_template
Search_template_delete <- function(conn, template, ...) {
  # search template render added in Elasticsearch v1.1, stop if version pre that
  if (conn$es_ver() < 110) {
    stop("search template not available in this ES version", call. = FALSE)
  }
  url <- conn$make_url()
  url <- paste0(url, "/_search/template/", template)
  es_DELETE(conn, url, ...)
}

#' @export
#' @rdname Search_template
Search_template_render <- function(conn, body = list(), raw = FALSE, ...) {
  # search template render added in Elasticsearch v2.0, stop if version pre that
  if (conn$es_ver() < 200) {
    stop("render template not available in this ES version", call. = FALSE)
  }
  search_POST(conn, "_render/template", args = list(), body = body, raw = raw, 
              asdf = FALSE, stream_opts = list(), ...)
}
