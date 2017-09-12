#' Search or validate templates
#'
#' @export
#' @name Search_template
#' @param template (character) a template name
#' @param body Query, either a list or json.
#' @param raw (logical) If \code{FALSE} (default), data is parsed to list.
#' If \code{TRUE}, then raw JSON returned
#' @param ... Curl args passed on to \code{\link[httr]{POST}}
#'
#' @seealso \code{\link{Search}}, \code{\link{Search_uri}}
#'
#' @section Template search:
#' With \code{Search_template} you can search with a template, using
#' mustache templating. Added in Elasticsearch v1.1
#'
#' @section Template render:
#' With \code{Search_template_render} you validate a template without
#' conducting the search. Added in Elasticsearch v2.0
#'
#' @section Pre-registered templates:
#' Register a template with \code{Search_template_register}. You can get 
#' the template with \code{Search_template_get} and delete the template 
#' with \code{Search_template_delete}
#' 
#' You can also pre-register search templates by storing them in the 
#' \code{config/scripts} directory, in a file using the .mustache 
#' extension. In order to execute the stored template, reference it 
#' by it's name under the template key, like 
#' \code{"file": "templateName", ...}
#' 
#' @references \url{https://www.elastic.co/guide/en/elasticsearch/reference/current/search-template.html}
#'
#' @examples \dontrun{
#' if (!index_exists("iris")) {
#'   invisible(docs_bulk(iris, "iris"))
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
#' Search_template(body = body1)
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
#' Search_template(body = body2)
#'
#' # pass in a list
#' mylist <- list(
#'   inline = list(query = list(match = list(`{{my_field}}` = "{{my_value}}"))),
#'   params = list(my_field = "Species", my_value = "setosa", my_size = 3L)
#' )
#' Search_template(body = mylist)
#'
#' ## Validating templates w/ Search_template_render()
#' Search_template_render(body = body1)
#' Search_template_render(body = body2)
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
#' Search_template_register('foobar', body = body3)
#'
#' ### get template
#' Search_template_get('foobar')
#'
#' ### use the template
#' body4 <- '{
#'  "id": "foobar",
#'   	"params": {
#'       "query_string": "setosa"
#'   }
#' }'
#' Search_template(body = body4)
#'
#' ### delete the template
#' Search_template_delete('foobar')
#' }
Search_template <- function(body = list(), raw = FALSE, ...) {
  # search template render added in Elasticsearch v1.1, stop if version pre that
  if (es_ver() < 110) {
    stop("search template not available in this ES version", call. = FALSE)
  }
  search_POST("_search/template", args = list(), body = body, raw = raw, 
              asdf = FALSE, stream_opts = list(), ...)
}

#' @export
#' @rdname Search_template
Search_template_register <- function(template, body = list(), raw = FALSE, 
                                     ...) {
  # search template render added in Elasticsearch v1.1, stop if version pre that
  if (es_ver() < 110) {
    stop("search template not available in this ES version", call. = FALSE)
  }
  search_POST(
    paste0("_search/template/", template),
    args = list(), body = body, raw = raw, asdf = FALSE, 
    stream_opts = list(), ...
  )
}

#' @export
#' @rdname Search_template
Search_template_get <- function(template, ...) {
  # search template render added in Elasticsearch v1.1, stop if version pre that
  if (es_ver() < 110) {
    stop("search template not available in this ES version", call. = FALSE)
  }
  url <- make_url(es_get_auth())
  url <- paste0(url, "/_search/template/", template)
  es_GET_(url, ...)
}

#' @export
#' @rdname Search_template
Search_template_delete <- function(template, ...) {
  # search template render added in Elasticsearch v1.1, stop if version pre that
  if (es_ver() < 110) {
    stop("search template not available in this ES version", call. = FALSE)
  }
  url <- make_url(es_get_auth())
  url <- paste0(url, "/_search/template/", template)
  es_DELETE(url, ...)
}

#' @export
#' @rdname Search_template
Search_template_render <- function(body = list(), raw = FALSE, ...) {
  # search template render added in Elasticsearch v2.0, stop if version pre that
  if (es_ver() < 200) {
    stop("render template not available in this ES version", call. = FALSE)
  }
  search_POST("_render/template", args = list(), body = body, raw = raw, 
              asdf = FALSE, stream_opts = list(), ...)
}
