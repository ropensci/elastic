make_bulk_df_generator <- function(fun) {
  function(x, index = NULL, type = NULL, chunk_size = 1000, 
    doc_ids = NULL, raw = FALSE, quiet = FALSE, ...) {
  
    assert(quiet, "logical")
    if (is.null(index)) {
      stop("index can't be NULL when passing a data.frame",
           call. = FALSE)
    }
    if (is.null(type)) type <- index
    check_doc_ids(x, doc_ids)
    # make sure document ids passed 
    if (!'id' %in% names(x) && is.null(doc_ids)) {
      stop('data.frame must have a column "id" or pass param "doc_ids"')
    }
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
      pb <- txtProgressBar(min = 0, max = length(data_chks), 
        initial = 0, style = 3)
      on.exit(close(pb))
    }
    resl <- vector(mode = "list", length = length(data_chks))
    for (i in seq_along(data_chks)) {
      if (!quiet) setTxtProgressBar(pb, i)
      resl[[i]] <- docs_bulk(fun(x[data_chks[[i]], , drop = FALSE], 
        index, type, id_chks[[i]]), ...)
    }
    return(resl)
  }
}
