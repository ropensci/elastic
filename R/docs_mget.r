#' Get multiple documents via the multiple get API.
#'
#' @export
#' @template all
#' @param ids More than one document id, see examples.
#' @param type_id List of vectors of length 2, each with an element for type and id.
#' @param index_type_id List of vectors of length 3, each with an element for index,
#' type, and id.
#' @param source (logical) If \code{TRUE}, return source.
#' @param fields Fields to return from the response object.
#'
#' @references 
#' \url{https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-multi-get.html}
#' @details 
#'
#' You can pass in one of three combinations of parameters:
#' \itemize{
#'  \item Pass in something for \code{index}, \code{type}, and \code{id}. This is the simplest,
#'  allowing retrieval from the same index, same type, and many ids.
#'  \item Pass in only \code{index} and \code{type_id} - this allows you to get multiple
#'  documents from the same index, but from different types.
#'  \item Pass in only \code{index_type_id} - this is so that you can get multiple documents
#'  from different indexes and different types.
#' }
#' @examples \dontrun{
#' # Same index and type
#' docs_mget(index="shakespeare", type="line", ids=c(9,10))
#' tmp <- docs_mget(index="mran", type="metadata", ids=c('plyr','ggplot2'), raw=TRUE)
#' es_parse(tmp)
#' docs_mget(index="mran", type="metadata", ids=c('plyr','ggplot2'), fields='description')
#' docs_mget(index="mran", type="metadata", ids=c('plyr','ggplot2'), source=TRUE)
#'
#' library("httr")
#' docs_mget(index="twitter", type="tweet", ids=1:2, callopts=verbose())
#'
#' # Same index, but different types
#' docs_mget(index="shakespeare", type_id=list(c("scene",1), c("line",20)))
#' docs_mget(index="shakespeare", type_id=list(c("scene",1), c("line",20)), fields='play_name')
#'
#' # Different indices and different types
#' # pass in separately
#' docs_mget(index_type_id=list(c("shakespeare","line",1), c("plos","article",1)))
#' }

docs_mget <- function(index=NULL, type=NULL, ids=NULL, type_id=NULL, index_type_id=NULL,
  source=NULL, fields=NULL, raw=FALSE, callopts=list(), verbose=TRUE, ...) {

  checkconn()
  check_params(index, type, ids, type_id, index_type_id)
  base <- make_url(es_get_auth())

  if (!is.null(ids)) {
    if (length(ids) < 2) stop("If ids parameter is used, more than 1 id must be passed", call. = FALSE)
  }

  fields <- if (is.null(fields)) {
    fields
  } else {
    paste(fields, collapse = ",")
  }
  args <- ec(list(...))
  if (length(args) == 0) args <- NULL

  # One index, one type, one to many ids
  if (length(index) == 1 && length(unique(type)) == 1 && length(ids) > 1) {

    body <- jsonlite::toJSON(list("ids" = ids))
    url <- paste(base, esc(index), esc(type), '_mget', sep = "/")
    out <- POST(url, mc(make_up(), callopts), body = body, encode = 'json', query = args)

  }
  # One index, many types, one to many ids
  else if (length(index) == 1 & length(type) > 1 | !is.null(type_id)) {

    # check for 2 elements in each element
    stopifnot(all(sapply(type_id, function(x) length(x) == 2)))
    docs <- lapply(type_id, function(x){
      list(`_type` = esc(x[[1]]), `_id` = x[[2]])
    })
    docs <- lapply(docs, function(y) modifyList(y, list(`_source` = source, fields = fields)))
    tt <- jsonlite::toJSON(list("docs" = docs))
    url <- paste(base, esc(index), '_mget', sep = "/")
    out <- POST(url, mc(make_up(), callopts), body = tt, encode = 'json', query = args)

  }
  # Many indeces, many types, one to many ids
  else if (length(index) > 1 | !is.null(index_type_id)) {
    # check for 3 elements in each element
    stopifnot(all(sapply(index_type_id, function(x) length(x) == 3)))
    docs <- lapply(index_type_id, function(x){
      modifyList(list(`_index` = esc(x[[1]]), `_type` = esc(x[[2]]), `_id` = x[[3]]), list(fields = fields))
    })
    tt <- jsonlite::toJSON(list("docs" = docs))
    url <- paste(base, '_mget', sep = "/")
    out <- POST(url, mc(make_up(), callopts), body = tt, encode = 'json', query = args)
  }

  stop_for_status(out)
  if (verbose) message(URLdecode(out$url))
  tt <- content(out, as = "text")
  class(tt) <- "elastic_mget"

  if (raw) {
    tt
  } else {
    es_parse(tt)
  }
}

check_params <- function(index, type, ids, type_id, index_type_id){
  if (is.null(type_id) && is.null(index_type_id)) {
    if (any(sapply(list(index, type, ids), is.null)))
      stop("If type_id and index_type_id are NULL, you must pass in index, type, and ids", call. = FALSE)
  } else if (!is.null(type_id) || !is.null(index_type_id)) {
    if (!is.null(type_id)) {
      if (is.null(index))
        stop("If you pass in type_id, you must pass in index", call. = FALSE)
    }
  }
}
