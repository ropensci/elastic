#' Elasticsearch alias APIs
#'
#' @param index An index name
#' @param alias An alias name
#' @param ignore_unavailable (logical) What to do if an specified index name doesn't exist. If set 
#' to TRUE then those indices are ignored.
#' @param routing Ignored for now
#' @param filter Ignored for now
#' @param callopts Curl args passed on to \code{\link[httr]{POST}}
#' @examples \donttest{
#' # Retrieve a specified alias
#' alias_get(index="plos")
#' alias_get(alias="*")
#' aliases_get()
#'
#' # Check for alias existence
#' alias_exists(index = "plos")
#'
#' # Create/update an alias
#' alias_create(index = "plos", alias = "tables")
#'
#' # Delete an alias
#' alias_delete(index = "plos", alias = "tables")
#' }
#' @references
#' \url{http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-aliases.html}
#' @author Scott Chamberlain <myrmecocystus@@gmail.com>
#' @name alias
NULL

#' @export
#' @rdname alias
alias_get <- function(index=NULL, alias=NULL, ignore_unavailable=FALSE, callopts=list())
{
  alias_GET(index, alias, ignore_unavailable, callopts)
}

#' @export
#' @rdname alias
aliases_get <- function(index=NULL, alias=NULL, ignore_unavailable=FALSE, callopts=list())
{
  alias_GET(index, alias, ignore_unavailable, callopts)
}

#' @export
#' @rdname alias
alias_exists <- function(index=NULL, alias=NULL, callopts=list())
{
  res <- alias_HEAD(index, alias, callopts)
  if(res$status_code == 200) TRUE else FALSE
}

#' @export
#' @rdname alias
alias_create <- function(index=NULL, alias, routing=NULL, filter=NULL, callopts=list())
{
  out <- PUT(alias_url(index, alias), callopts)
  stop_for_status(out)
  jsonlite::fromJSON(content(out, "text"), FALSE)
}

#' @export
#' @rdname alias
alias_delete <- function(index=NULL, alias, callopts=list())
{
  out <- DELETE(alias_url(index, alias), callopts)
  stop_for_status(out)
  jsonlite::fromJSON(content(out, "text"), FALSE)
}

alias_GET <- function(index, alias, ignore, callopts, ...) 
{
  tt <- GET(alias_url(index, alias), query=ec(list(ignore_unavailable=as_log(ignore))), callopts)
  if(tt$status_code > 202){
    if(tt$status_code > 202) stop(tt$headers$statusmessage)
    if(content(tt)$status == "ERROR") stop(content(tt)$error_message)
  }
  jsonlite::fromJSON(content(tt, as = "text"), FALSE)
}

alias_HEAD <- function(index, alias, callopts) 
{
  tt <- HEAD(alias_url(index, alias), callopts)
  if(tt$status_code > 202){
    if(tt$status_code > 202) stop(tt$headers$statusmessage)
    if(content(tt)$status == "ERROR") stop(content(tt)$error_message)
  }
  tt
}

alias_url <- function(index, alias) 
{
  conn <- es_connect()
  if(!is.null(index)){
    if(!is.null(alias))
      sprintf("%s:%s/%s/_alias/%s", conn$base, conn$port, cl(index), alias)
    else
      sprintf("%s:%s/%s/_alias", conn$base, conn$port, cl(index)) 
  } else {
    if(!is.null(alias))
      sprintf("%s:%s/_alias/%s", conn$base, conn$port, cl(index), alias)
    else
      sprintf("%s:%s/_alias", conn$base, conn$port)
  }
}
