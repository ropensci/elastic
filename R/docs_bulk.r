#' Use the bulk API to create, index, update, or delete documents.
#'
#' @export
#' @param filename Path to a file to load in the bulk API
#' @param raw (logical) Get raw JSON back or not.
#' @param callopts Pass on options to POST call.
#' @details More on the Bulk API:
#'    \url{http://www.elasticsearch.org/guide/en/elasticsearch/guide/current/bulk.html}.
#' @examples \donttest{
#' plosdat <- system.file("examples", "plos_data.json", package = "elastic")
#' docs_bulk(file=plosdat)
#' aliases_get()
#' index_delete(index='plos')
#' aliases_get()
#' }

docs_bulk <- function(filename, raw=FALSE, callopts=list())
{
  conn <- es_get_auth()
  url <- paste0(conn$base, ":", conn$port, '/_bulk')
  tt <- POST(url, body=upload_file(filename), callopts, encode = "json")
  if(tt$status_code > 202){
    if(tt$status_code > 202) stop(tt$headers$statusmessage)
    if(content(tt)$status == "ERROR") stop(content(tt)$error_message)
  }
  res <- content(tt, as = "text")
  res <- structure(res, class="bulk_make")
  if(raw) res else es_parse(res)
}

# make_bulk_plos(index_name='plosmore', fields=c('id','journal','title','abstract','author'), filename="inst/examples/plos_more_data.json")
make_bulk_plos <- function(n = 1000, index='plos', type='article', fields=c('id','title'), filename = "~/plos_data.json"){
  unlink(filename)
  args <- ec(list(q = "*:*", rows=n, fl=paste0(fields, collapse = ","), fq='doc_type:full', wt='json'))
  res <- GET("http://api.plos.org/search", query=args)
  stop_for_status(res)
  tt <- jsonlite::fromJSON(content(res, as = "text"), FALSE)
  docs <- tt$response$docs
  docs <- lapply(docs, function(x){
    x[sapply(x, length)==0] <- "null"
    lapply(x, function(y) if(length(y) > 1) paste0(y, collapse = ",") else y)
  })
  for(i in seq_along(docs)){
    dat <- list(index = list(`_index` = index, `_type` = type, `_id` = i-1))
    cat(proc_doc(dat), sep = "\n", file = filename, append = TRUE)
    cat(proc_doc(docs[[i]]), sep = "\n", file = filename, append = TRUE)
  }
  message(sprintf("File written to %s", filename))
}

proc_doc <- function(x){
  b <- jsonlite::toJSON(x, auto_unbox = TRUE)
  gsub("\\[|\\]", "", as.character(b))
}

# make_bulk_gbif(900, filename="inst/examples/gbif_data.json")
make_bulk_gbif <- function(n = 600, index='gbif', type='record', filename = "~/gbif_data.json"){  
  unlink(filename)
  res <- lapply(seq(1, n, 300), getgbif)
  res <- do.call(c, res)
  res <- lapply(res, function(x){
    x[sapply(x, length)==0] <- "null"
    lapply(x, function(y) if(length(y) > 1) paste0(y, collapse = ",") else y)
  })
  for(i in seq_along(res)){
    dat <- list(index = list(`_index` = index, `_type` = type, `_id` = i-1))
    cat(proc_doc(dat), sep = "\n", file = filename, append = TRUE)
    cat(proc_doc(res[[i]]), sep = "\n", file = filename, append = TRUE)
  }  
  message(sprintf("File written to %s", filename))
}

getgbif <- function(x){
  res <- GET("http://api.gbif.org/v1/occurrence/search", query=list(limit=300, offset=x))
  jsonlite::fromJSON(content(res, "text"), FALSE)$results
}
