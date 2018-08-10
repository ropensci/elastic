#' Elasticsearch alias APIs
#'
#' @param index An index name
#' @param alias An alias name
#' @param ignore_unavailable (logical) What to do if an specified index name
#' doesn't exist. If set to `TRUE` then those indices are ignored.
#' @param filter (named list) provides an easy way to create different "views" of 
#' the same index. Defined using Query DSL and is applied to all Search, Count, 
#' Delete By Query and More Like This operations with this alias. See 
#' examples
#' @param routing,search_routing,index_routing (character) Associate a routing
#' value with an alias
#' @param ... Curl args passed on to [httr::POST()], [httr::GET()], [httr::HEAD()],
#' or [httr::DELETE()]
#' 
#' @details Note that you can also create aliases when you create indices
#' by putting the directive in the request body. See the Elasticsearch 
#' docs link
#' 
#' @examples \dontrun{
#' # Create/update an alias
#' alias_create(index = "plos", alias = "candles", config = httr::verbose())
#' ## more than one alias
#' alias_create(index = "plos", alias = c("tables", "chairs"), config = httr::verbose())
#' 
#' # associate an alias with two multiple different indices
#' alias_create(index = c("plos", "shakespeare"), alias = "stools", config = httr::verbose())
#'
#' # Retrieve a specified alias
#' alias_get(index="plos")
#' alias_get(alias="tables")
#' alias_get(alias="stools")
#' aliases_get()
#' 
#' # rename an alias
#' aliases_get("plos")
#' alias_rename(index = 'plos', alias = "stools", alias_new = "plates")
#' aliases_get("plos")
#' 
#' # filtered aliases
#' alias_create(index = "plos", alias = "candles", 
#'   filter = list(wildcard = list(title = "cell")))
#' ## a search with the alias should give titles with cell in them
#' (titles <- Search("candles", asdf = TRUE)$hits$hits$`_source.title`)
#' grepl("cell", titles, ignore.case = TRUE)
#' 
#' # routing
#' alias_create(index = "plos", alias = "candles", 
#'   routing = "1")
#'
#' # Check for alias existence
#' alias_exists(index = "plos")
#' alias_exists(alias = "tables")
#' alias_exists(alias = "adsfasdf")
#'
#' # Delete an alias
#' alias_delete(index = "plos", alias = "candles")
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
  res <- HEAD(alias_url(index, alias), es_env$headers, make_up(), ...)
  if (res$status_code == 200) TRUE else FALSE
}

#' @export
#' @rdname alias
alias_create <- function(index, alias, filter=NULL, routing=NULL, 
  search_routing=NULL, index_routing=NULL, ...) {

  assert(index, "character")
  assert(alias, "character")
  assert(routing, "character")
  assert(search_routing, "character")
  assert(index_routing, "character")
  body <- list(actions =
    unname(Map(function(a, b) {
      list(add = ec(list(index = esc(a), alias = esc(b), 
        filter = filter, routing = routing, search_routing = search_routing, 
        index_routing = index_routing)))
    }, index, alias))
  )
  body <- jsonlite::toJSON(body, auto_unbox = TRUE)
  out <- POST(aliases_url(), es_env$headers, make_up(), body = body, 
    httr::content_type_json(), ...)
  geterror(out)
  jsonlite::fromJSON(cont_utf8(out), FALSE)
}

#' @export
#' @rdname alias
alias_rename <- function(index, alias, alias_new, ...) {
  body <- list(actions = list(
    list(remove = list(index = index, alias = alias)),
    list(add = list(index = index, alias = alias_new))
  ))
  body <- jsonlite::toJSON(body, auto_unbox = TRUE)
  out <- POST(aliases_url(), es_env$headers, make_up(), body = body, 
    httr::content_type_json(), ...)
  geterror(out)
  jsonlite::fromJSON(cont_utf8(out), FALSE)
}

#' @export
#' @rdname alias
alias_delete <- function(index=NULL, alias, ...) {
  out <- DELETE(alias_url(index, alias), es_env$headers, make_up(), ...)
  geterror(out)
  jsonlite::fromJSON(cont_utf8(out), FALSE)
}



# helpers ---------
alias_GET <- function(index, alias, ignore, ...) {
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

aliases_url <- function() file.path(make_url(es_get_auth()), "_aliases")
