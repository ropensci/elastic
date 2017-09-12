make_bulk <- function(df, index, type, counter, es_ids, path = NULL) {
  if (!is.character(counter)) {
    if (max(counter) >= 10000000000) {
      scipen <- getOption("scipen")
      options(scipen = 100)
      on.exit(options(scipen = scipen))
    }
  }
  metadata_fmt <- if (es_ids) {
    '{"index":{"_index":"%s","_type":"%s"}}'
  } else {
    if (is.character(counter)) {
      '{"index":{"_index":"%s","_type":"%s","_id":"%s"}}'
    } else {
      '{"index":{"_index":"%s","_type":"%s","_id":%s}}'
    }
  }
  metadata <- sprintf(
    metadata_fmt,
    index,
    type,
    counter
  )
  data <- jsonlite::toJSON(df, collapse = FALSE, na = "null", auto_unbox = TRUE)
  tmpf <- if (is.null(path)) tempfile("elastic__") else path
  writeLines(paste(metadata, data, sep = "\n"), tmpf)
  invisible(tmpf)
}

shift_start <- function(vals, index, type = NULL) {
  num <- tryCatch(count(index, type), error = function(e) e)
  if (inherits(num, "error")) {
    vals
  } else {
    vals + num
  }
}

check_doc_ids <- function(x, ids) {
  if (!is.null(ids)) {
    # check class type
    if (!class(ids) %in% c('character', 'factor', 'numeric', 'integer')) {
      stop("doc_ids must be of class character, numeric or integer", 
           call. = FALSE)
    }
    
    # check appropriate length
    if (!all(1:NROW(x) == 1:length(ids))) {
      stop("doc_ids length must equal number of documents", call. = FALSE)
    }
  }
}

has_ids <- function(x) {
  if (inherits(x, "data.frame")) {
    "id" %in% names(x)
  } else if (inherits(x, "list")) {
    ids <- ec(sapply(x, "[[", "id"))
    if (length(ids) > 0) {
      tmp <- length(ids) == length(x)
      if (tmp) TRUE else stop("id field not in every document", call. = FALSE)
    } else {
      FALSE
    }
  } else {
    stop("input must be list or data.frame", call. = FALSE)
  }
}

close_conns <- function() {
  cons <- showConnections()
  ours <- as.integer(rownames(cons)[grepl("/elastic__", cons[, "description"], 
                                          fixed = TRUE)])
  for (i in ours) {
    close(getConnection(i))
  }
}

check_named_vectors <- function(x) {
  lapply(x, function(z) {
    if (!inherits(z, "list")) {
      as.list(z)
    } else {
      z
    }
  })
}


adjust_path <- function(x, i) {
  x <- path.expand(x)
  tmp <- strsplit(basename(x), "\\.")[[1]]
  paste(dirname(x), paste0(tmp[1], i, ".", tmp[2]), sep = "/")
}
