#' Get documents via the get API.
#'
#' @export
#' @template all
#' @template get
#' @param exists (logical) Only return a logical as to whether the document exists or not.
#' @references 
#' \url{http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/docs-get.html}
#' @examples \dontrun{
#' docs_get(index='shakespeare', type='line', id=10)
#' docs_get(index='shakespeare', type='line', id=3)
#' docs_get(index='shakespeare', type='line', id=3, source=TRUE)
#'
#' # Get certain fields
#' docs_get(index='shakespeare', type='line', id=10, fields='play_name')
#'
#' # Just test for existence of the document
#' docs_get(index='plos', type='article', id=1, exists=TRUE)
#' docs_get(index='plos', type='article', id=123456, exists=TRUE)
#' }

docs_get <- function(index=NULL, type=NULL, id=NULL, source=FALSE,
  fields=NULL, exists=FALSE, raw=FALSE, callopts=list(), verbose=TRUE, ...)
{
  conn <- es_get_auth()
  if(!is.null(fields)) fields <- paste(fields, collapse=",")

  url <- paste(conn$base, ":", conn$port, sep="")
  args <- ec(list(fields = cl(fields), ...))
  url <- sprintf("%s/%s/%s/%s", url, index, type, id)
  if(source) url <- paste(url, '_source', sep="/")

#   if(length(id) > 1){ # pass in request in body
#     body <- toJSON(list(ids = as.character(id)))
#   } else{ url <- sprintf("%s/%s/%s/%s", url, index, type, id) }

  if(exists){
    out <- HEAD(url, query=args, callopts)
    if(out$status_code == 200) TRUE else FALSE
  } else
  {
    out <- GET(url, query=args, callopts)
    stop_for_status(out)
    if(verbose) message(URLdecode(out$url))
    if(raw){ content(out, as="text") } else { jsonlite::fromJSON(content(out, as="text"), FALSE) }
  }
}
