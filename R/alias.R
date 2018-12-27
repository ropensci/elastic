#' Elasticsearch alias APIs
#'
#' @param conn an Elasticsearch connection object, see [connect()]
#' @param index (character) An index name
#' @param alias (character) An alias name
#' @param alias_new (character) A new alias name, used in rename only
#' @param ignore_unavailable (logical) What to do if an specified index name
#' doesn't exist. If set to `TRUE` then those indices are ignored.
#' @param filter (named list) provides an easy way to create different "views" of 
#' the same index. Defined using Query DSL and is applied to all Search, Count, 
#' Delete By Query and More Like This operations with this alias. See 
#' examples
#' @param routing,search_routing,index_routing (character) Associate a routing
#' value with an alias
#' @param ... Curl args passed on to [crul::verb-POST], [crul::verb-GET], 
#' [crul::verb-HEAD], or [crul::verb-DELETE]
#' 
#' @details Note that you can also create aliases when you create indices
#' by putting the directive in the request body. See the Elasticsearch 
#' docs link
#' 
#' @examples \dontrun{
#' # connection setup
#' (x <- connect())
#' 
#' # Create/update an alias
#' alias_create(x, index = "plos", alias = "candles")
#' ## more than one alias
#' alias_create(x, index = "plos", alias = c("tables", "chairs"))
#' 
#' # associate an alias with two multiple different indices
#' alias_create(x, index = c("plos", "shakespeare"), alias = "stools")
#'
#' # Retrieve a specified alias
#' alias_get(x, index="plos")
#' alias_get(x, alias="tables")
#' alias_get(x, alias="stools")
#' aliases_get(x)
#' 
#' # rename an alias
#' aliases_get(x, "plos")
#' alias_rename(x, index = 'plos', alias = "stools", alias_new = "plates")
#' aliases_get(x, "plos")
#' 
#' # filtered aliases
#' alias_create(x, index = "plos", alias = "candles", 
#'   filter = list(wildcard = list(title = "cell")))
#' ## a search with the alias should give titles with cell in them
#' (titles <- Search(x, "candles", asdf = TRUE)$hits$hits$`_source.title`)
#' grepl("cell", titles, ignore.case = TRUE)
#' 
#' # routing
#' alias_create(x, index = "plos", alias = "candles", 
#'   routing = "1")
#'
#' # Check for alias existence
#' alias_exists(x, index = "plos")
#' alias_exists(x, alias = "tables")
#' alias_exists(x, alias = "adsfasdf")
#'
#' # Delete an alias
#' alias_delete(x, index = "plos", alias = "tables")
#' alias_exists(x, alias = "tables")
#'
#' # Curl options
#' alias_create(x, index = "plos", alias = "tables")
#' aliases_get(x, alias = "tables", verbose = TRUE)
#' }
#' @references
#' \url{https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-aliases.html}
#' @author Scott Chamberlain <myrmecocystus@@gmail.com>
#' @name alias
NULL

#' @export
#' @rdname alias
alias_get <- function(conn, index=NULL, alias=NULL, ignore_unavailable=FALSE, ...) {
  alias_GET(conn, index, alias, ignore_unavailable, ...)
}

#' @export
#' @rdname alias
aliases_get <- function(conn, index=NULL, alias=NULL, ignore_unavailable=FALSE, ...) {
  alias_GET(conn, index, alias, ignore_unavailable, ...)
}

#' @export
#' @rdname alias
alias_exists <- function(conn, index=NULL, alias=NULL, ...) {
  res <- conn$make_conn(alias_url(conn, index, alias), ...)$head()
  if (res$status_code == 200) TRUE else FALSE
}

#' @export
#' @rdname alias
alias_create <- function(conn, index, alias, filter=NULL, routing=NULL, 
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
  out <- conn$make_conn(aliases_url(conn), json_type(), ...)$post(body = body)
  geterror(out)
  jsonlite::fromJSON(out$parse('UTF-8'), FALSE)
}

#' @export
#' @rdname alias
alias_rename <- function(conn, index, alias, alias_new, ...) {
  body <- list(actions = list(
    list(remove = list(index = index, alias = alias)),
    list(add = list(index = index, alias = alias_new))
  ))
  body <- jsonlite::toJSON(body, auto_unbox = TRUE)
  out <- conn$make_conn(aliases_url(conn), json_type(), ...)$post(body = body)
  geterror(out)
  jsonlite::fromJSON(out$parse('UTF-8'), FALSE)
}

#' @export
#' @rdname alias
alias_delete <- function(conn, index=NULL, alias, ...) {
  out <- conn$make_conn(alias_url(conn, index, alias), ...)$delete()
  # out <- DELETE(alias_url(index, alias), es_env$headers, make_up(), ...)
  geterror(out)
  jsonlite::fromJSON(out$parse('UTF-8'), FALSE)
}



# helpers ---------
alias_GET <- function(conn, index, alias, ignore, ...) {
  cli <- conn$make_conn(alias_url(conn, index, alias), ...)
  tt <- cli$get(query = ec(list(ignore_unavailable = as_log(ignore))))
  geterror(tt)
  jsonlite::fromJSON(tt$parse("UTF-8"), FALSE)
}

alias_url <- function(conn, index, alias) {
  url <- conn$make_url()
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

aliases_url <- function(conn) file.path(conn$make_url(), "_aliases")
