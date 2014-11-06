# GET wrapper
elastic_GET <- function(path, index=NULL, type=NULL, metric=NULL, node=NULL, 
                        clazz=NULL, raw, callopts, ...) 
{
  #   conn <- es_connect()
  conn <- es_get_auth()
  url <- paste(conn$base, ":", conn$port, sep="")
  if(is.null(index) && is.null(type)){ url <- paste(url, path, sep="/") } else
    if(is.null(type) && !is.null(index)){ url <- paste(url, index, path, sep="/") } else {
      url <- paste(url, index, type, path, sep="/")    
    }
  
  if(!is.null(node)){
    url <- paste(url, paste(node, collapse = ","), sep = "/")
  }
  if(!is.null(metric)){
    url <- paste(url, paste(metric, collapse = ","), sep = "/")
  }  
  
  args <- es_compact(list(...))
  tt <- GET(url, query=args, callopts)
  if(tt$status_code > 202){
    if(tt$status_code > 202) stop(tt$headers$statusmessage)
    if(content(tt)$status == "ERROR") stop(content(tt)$error_message)
  }
  res <- content(tt, as = "text")
  if(!is.null(clazz)){ 
    class(res) <- clazz
    if(raw) res else es_parse(res)
  } else { res }
}

index_GET <- function(path, index, features, raw, callopts, ...) 
{
  conn <- es_get_auth()
  url <- paste0(conn$base, ":", conn$port, "/", paste0(index, collapse = ","))
  if(!is.null(features)) features <- paste0(paste0("_", features), collapse = ",")
  if(!is.null(features)) url <- paste0(url, "/", features)
  tt <- GET(url, callopts)
  if(tt$status_code > 202){
    if(tt$status_code > 202) stop(tt$headers$statusmessage)
    if(content(tt)$status == "ERROR") stop(content(tt)$error_message)
  }
  jsonlite::fromJSON(content(tt, as = "text"), FALSE)
}

#' POST wrapper
#' @keywords internal
#' @rdname httr-verbs
#' @param path Elasticsearch API endpoint path
#' @param index Elasticsearch index
#' @param type Elasticsearch type
#' @param clazz Class to outupt
#' @param raw Raw JSON results as string
#' @param callopts Curl options
#' @param query Query list or string to be passed on to body of the \code{POST} call.
#' @param ... Further args passed to Elasticsearch. If passed in as list, converted to JSON, if 
#' passed in as character, validate the json (using \code{jsonlite::validate}), then pass in 
#' to request. 
elastic_POST <- function(path, index=NULL, type=NULL, clazz=NULL, raw, callopts, query, ...) 
{
  conn <- es_get_auth()
  url <- paste(conn$base, ":", conn$port, sep="")
  if(is.null(index) && is.null(type)){ url <- paste(url, path, sep="/") } else
    if(is.null(type) && !is.null(index)){ url <- paste(url, index, path, sep="/") } else {
      url <- paste(url, index, type, path, sep="/")    
    }
  
  args <- check_inputs(query)
  tt <- POST(url, body=args, callopts, encode = "json")
  if(tt$status_code > 202){
    if(tt$status_code > 202) stop(tt$headers$statusmessage)
    if(content(tt)$status == "ERROR") stop(content(tt)$error_message)
  }
  res <- content(tt, as = "text")
  if(!is.null(clazz)){ 
    class(res) <- clazz
    if(raw) res else es_parse(input = res)
  } else { res }
}

check_inputs <- function(x){
  if(is.character(x)){
    # replace newlines
    x <- gsub("\n|\r", "", x)
    # validate
    tmp <- jsonlite::validate(x)
    if(!tmp) stop(attr(tmp, "err"))
    x
  } else {
    jsonlite::toJSON(x, auto_unbox = TRUE)
  }
}
