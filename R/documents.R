#' Elasticsearch documents functions.
#'
#' @name documents
#' @details There are five functions to work directly with documents.
#' \itemize{
#'  \item \code{\link{docs_get}}
#'  \item \code{\link{docs_mget}}
#'  \item \code{\link{docs_create}}
#'  \item \code{\link{docs_delete}}
#'  \item \code{\link{docs_bulk}}
#' }
#' @examples \donttest{
#' # Get a document
#' docs_get(index='plos', type='article', id=1)
#' 
#' # Get multiple documents
#' docs_mget(index="shakespeare", type="line", id=c(9,10))
#' 
#' # Delete a document
#' docs_delete(index='plos', type='article', id=35)
#' 
#' # Create a document
#' docs_create(index='plos', type='article', id=1002, body=list(id="12345", title="New title"))
#' 
#' # Bulk load documents
#' plosdat <- system.file("examples", "plos_data.json", package = "elastic")
#' es_bulk(file=plosdat)
#' }
NULL
