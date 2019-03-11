make_bulk_ <- function(df, index, type, counter, es_ids, 
  path = NULL, action = "index") {

  if (!is.character(counter)) {
    if (max(counter) >= 10000000000) {
      scipen <- getOption("scipen")
      options(scipen = 100)
      on.exit(options(scipen = scipen))
    }
  }
  metadata_fmt <- if (es_ids) {
    '{"%s":{"_index":"%s","_type":"%s"}}'
  } else {
    if (is.character(counter)) {
      '{"%s":{"_index":"%s","_type":"%s","_id":"%s"}}'
    } else {
      '{"%s":{"_index":"%s","_type":"%s","_id":%s}}'
    }
  }
  metadata <- sprintf(
    metadata_fmt,
    action,
    index,
    type,
    counter
  )
  data <- jsonlite::toJSON(df, collapse = FALSE, na = "null", auto_unbox = TRUE)
  tmpf <- if (is.null(path)) tempfile("elastic__") else path
  write_utf8(paste(metadata, data, sep = "\n"), tmpf)
  invisible(tmpf)
}

bulk_ci_generator <- function(action = "index", es_ids = TRUE) {
  tt <- function(conn, x, index = NULL, type = NULL, chunk_size = 1000,
           doc_ids = NULL, es_ids = TRUE, raw = FALSE, quiet = FALSE, ...) {
    
    is_conn(conn)
    assert(quiet, "logical")
    if (is.null(index)) {
      stop("index can't be NULL when passing a data.frame",
           call. = FALSE)
    }
    if (is.null(type)) type <- index
    check_doc_ids(x, doc_ids)
    if (is.factor(doc_ids)) doc_ids <- as.character(doc_ids)
    row.names(x) <- NULL
    rws <- seq_len(NROW(x))
    data_chks <- split(rws, ceiling(seq_along(rws) / chunk_size))
    if (!is.null(doc_ids)) {
      id_chks <- split(doc_ids, ceiling(seq_along(doc_ids) / chunk_size))
    } else if (has_ids(x)) {
      rws <- if (inherits(x$id, "factor")) as.character(x$id) else x$id
      id_chks <- split(rws, ceiling(seq_along(rws) / chunk_size))
    } else {
      rws <- shift_start(rws, index, type)
      id_chks <- split(rws, ceiling(seq_along(rws) / chunk_size))
    }
    
    if (!quiet) {
      pb <- txtProgressBar(min = 0, max = length(data_chks), initial = 0, style = 3)
      on.exit(close(pb))
    }
    resl <- vector(mode = "list", length = length(data_chks))
    for (i in seq_along(data_chks)) {
      if (!quiet) setTxtProgressBar(pb, i)
      resl[[i]] <- docs_bulk(conn, make_bulk_(x[data_chks[[i]], , drop = FALSE], 
                                       index, type, id_chks[[i]], es_ids, 
                                       action = action), ...)
    }
    return(resl)
  }
  formals(tt) <- modifyList(formals(tt), list(es_ids = es_ids))
  return(tt)
}
