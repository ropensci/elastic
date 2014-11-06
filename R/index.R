#' Elasticsearch indices APIs
#'
#' @param index A comma-separated list of index names
#' @param features A comma-separated list of features. One or more of settings, mappings, 
#' warmers or aliases
#' @param raw If TRUE (default), data is parsed to list. If FALSE, then raw JSON.
#' @param callopts Curl args passed on to httr::POST.
#' @param verbose If TRUE (default) the url call used printed to console.
#' @param ... Further args passed on to elastic search HTTP API as parameters.
#' @param type Document type
#' @param id Document id
#' @param fields Fields to add.
#' 
#' @examples \donttest{
#' # get information on an index
#' es_index_get(index='shakespeare')
#' es_index_get(index='shakespeare', features=c('settings','mappings'))
#' es_index_get(index='shakespeare', features='aliases')
#' es_index_get(index='shakespeare', features='warmers')
#' 
#' # check for index existence
#' es_index_exists(index='shakespeare')
#' es_index_exists(index='plos')
#' 
#' # delete an index
#' es_index_delete(index='plos')
#' 
#' # create an index
#' es_index_create(index='twitter', type='tweet', id=10)
#' es_index_create(index='things', type='tweet', id=10)
#' 
#' # close an index
#' es_index_close('plos')
#' 
#' # open an index
#' es_index_open('plos')
#' }
#' 
#' @references
#' \url{http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices.html}
#' @author Scott Chamberlain <myrmecocystus@@gmail.com>
#' @name index
NULL

#' @export
#' @rdname index
es_index_get <- function(index=NULL, features=NULL, raw=FALSE, callopts=list(), verbose=TRUE, ...)
{
  conn <- es_connect()
  url <- paste0(conn$base, ":", conn$port)
  index_GET(url, index, features, raw, callopts)
}

#' @export
#' @rdname index
es_index_exists <- function(index, callopts=list())
{
  conn <- es_connect()
  url <- paste0(conn$base, ":", conn$port, "/", index)
  res <- HEAD(url, callopts)
  if(res$status_code == 200) TRUE else FALSE
}

#' @export
#' @rdname index
es_index_delete <- function(index, raw=FALSE, callopts=list(), verbose=TRUE)
{
  conn <- es_connect()
  url <- paste0(conn$base, ":", conn$port, "/", index)
  out <- DELETE(url, callopts)
  stop_for_status(out)
  if(verbose) message(URLdecode(out$url))
  tt <- structure(content(out, as="text"), class="index_delete")
  if(raw){ tt } else { es_parse(tt) }
}

#' @export
#' @rdname index
es_index_create <- function(index=NULL, type=NULL, id=NULL, fields=NULL, raw=FALSE, 
  callopts=list(), verbose=TRUE, ...)
{
  conn <- es_connect()
  
  if(length(id) > 1){ # pass in request in body
    body <- toJSON(list(ids = as.character(id)))
  }
  
  if(!is.null(fields)) fields <- paste(fields, collapse=",")
  url <- paste(conn$url, ":", conn$port, sep="")
  
  out <- PUT(url, query=list(), callopts)
  stop_for_status(out)
  if(verbose) message(URLdecode(out$url))
  tt <- structure(content(out, as="text"), class="elastic_create")
  if(raw){ tt } else { es_parse(tt) }
}

#' @export
#' @rdname index
es_index_close <- function(index, callopts=list())
{
  close_open(index, "_close", callopts)
}

#' @export
#' @rdname index
es_index_open <- function(index, callopts=list())
{
  close_open(index, "_open", callopts)
}

close_open <- function(index, which, callopts){
  conn <- es_connect()
  url <- sprintf("%s:%s/%s/%s", conn$base, conn$port, index, which)
  out <- POST(url, callopts)
  stop_for_status(out)
  content(out)
}
