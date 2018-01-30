#' Elasticsearch alias APIs
#'
#' @param index An index name
#' @param alias An alias name
#' @param ignore_unavailable (logical) What to do if an specified index name
#' doesn't exist. If set to `TRUE` then those indices are ignored.
#' @param routing Ignored for now
#' @param filter Ignored for now
#' @param ... Curl args passed on to [httr::POST()]
#' @examples \dontrun{
#' # Create/update an alias
#' alias_create(index = "plos", alias = "tables")
#'
#' # Retrieve a specified alias
#' alias_get(index="plos")
#' alias_get(alias="tables")
#' aliases_get()
#'
#' # Check for alias existence
#' alias_exists(index = "plos")
#' alias_exists(alias = "tables")
#' alias_exists(alias = "adsfasdf")
#'
#' # Delete an alias
#' alias_delete(index = "plos", alias = "tables")
#' alias_exists(alias = "tables")
#'
#' # Curl options
#' library("httr")
#' alias_create(index = "plos", alias = "tables")
#' aliases_get(alias = "tables", config=verbose())
#' }
#' @references
#' \url{https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-aliases.html}
#' @author Scott Chamberlain <myrmecocystus@@gmail.com>
#' @name alias
NULL

#' @export
#' @rdname alias
alias_get <- function(index=NULL, alias=NULL, ignore_unavailable=FALSE, ...) {
  alias_GET(index, alias, ignore_unavailable, ...)
}

#' @export
#' @rdname alias
aliases_get <- function(index=NULL, alias=NULL, ignore_unavailable=FALSE, ...) {
  alias_GET(index, alias, ignore_unavailable, ...)
}

#' @export
#' @rdname alias
alias_exists <- function(index=NULL, alias=NULL, ...) {
  #checkconn(...)
  res <- HEAD(alias_url(index, alias), es_env$headers, make_up(), ...)
  if (res$status_code == 200) TRUE else FALSE
}

#' @export
#' @rdname alias
alias_create <- function(index=NULL, alias, routing=NULL, filter=NULL, ...) {
  #checkconn(...)
  out <- PUT(alias_url(index, alias), es_env$headers, make_up(), ...)
  geterror(out)
  jsonlite::fromJSON(cont_utf8(out), FALSE)
}

#' @export
#' @rdname alias
alias_delete <- function(index=NULL, alias, ...) {
  #checkconn(...)
  out <- DELETE(alias_url(index, alias), es_env$headers, make_up(), ...)
  geterror(out)
  jsonlite::fromJSON(cont_utf8(out), FALSE)
}

alias_GET <- function(index, alias, ignore, ...) {
  #checkconn(...)
  tt <- GET(alias_url(index, alias),
             query = ec(list(ignore_unavailable = as_log(ignore))),
             make_up(), es_env$headers, ...)
  geterror(tt)
  jsonlite::fromJSON(cont_utf8(tt), FALSE)
}

alias_url <- function(index, alias) {
  url <- make_url(es_get_auth())
  if (!is.null(index)) {
    if (!is.null(alias))
      sprintf("%s/%s/_alias/%s", url, cl(index), alias)
    else
      sprintf("%s/%s/_alias", url, cl(index))
  } else {
    if (!is.null(alias))
      sprintf("%s/_alias/%s", url, alias)
    else
      sprintf("%s/_alias", url)
  }
}
