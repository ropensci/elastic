# make_bulk_plos(index_name='plosmore', fields=c('id','journal','title','abstract','author'), filename="inst/examples/plos_more_data.json")
make_bulk_plos <- function(n = 1000, index='plos', type='article', fields=c('id','title'), filename = "~/plos_data.json"){
  unlink(filename)
  args <- ec(list(q = "*:*", rows=n, fl=paste0(fields, collapse = ","), fq='doc_type:full', wt='json'))
  res <- GET("http://api.plos.org/search", query=args)
  stop_for_status(res)
  tt <- jsonlite::fromJSON(cont_utf8(res), FALSE)
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
# make_bulk_gbif(600, "gbifgeo", filename="inst/examples/gbif_geo.json", add_coordinates = TRUE)
make_bulk_gbif <- function(n = 600, index='gbif', type='record', filename = "~/gbif_data.json", add_coordinates=FALSE){
  unlink(filename)
  res <- lapply(seq(1, n, 300), getgbif)
  res <- do.call(c, res)
  res <- lapply(res, function(x){
    x[sapply(x, length)==0] <- "null"
    lapply(x, function(y) if(length(y) > 1) paste0(y, collapse = ",") else y)
  })
  if(add_coordinates) res <- lapply(res, function(x) c(x, coordinates = sprintf("[%s,%s]", x$decimalLongitude, x$decimalLatitude)))
  for(i in seq_along(res)){
    dat <- list(index = list(`_index` = index, `_type` = type, `_id` = i-1))
    cat(proc_doc(dat), sep = "\n", file = filename, append = TRUE)
    cat(proc_doc(res[[i]]), sep = "\n", file = filename, append = TRUE)
  }
  message(sprintf("File written to %s", filename))
}

getgbif <- function(x){
  res <- GET("http://api.gbif.org/v1/occurrence/search", query=list(limit=300, offset=x))
  jsonlite::fromJSON(cont_utf8(res), FALSE)$results
}
