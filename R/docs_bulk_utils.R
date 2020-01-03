make_bulk <- function(df, index, counter, es_ids, type = NULL, path = NULL) {
  if (!is.character(counter)) {
    if (max(counter) >= 10000000000) {
      scipen <- getOption("scipen")
      options(scipen = 100)
      on.exit(options(scipen = scipen))
    }
  }
  metadata_fmt <- make_metadata(es_ids, counter, type)
  if (!"es_action" %in% names(df)) {
    action <- "index"
    metadata <- if (!is.null(type)) {
      sprintf(metadata_fmt, action, index, type, counter)
    } else {
      sprintf(metadata_fmt, action, index, counter)
    }
    data <- jsonlite::toJSON(df, collapse = FALSE, na = "null", auto_unbox = TRUE)
    towrite <- paste(metadata, data, sep = "\n")
  } else {
    towrite <- unlist(unname(Map(function(a, b) {
      tmp <- if (!is.null(type)) {
        sprintf(metadata_fmt, a$es_action, index, type, b)
      } else {
        sprintf(metadata_fmt, a$es_action, index, b)
      }
      if (a$es_action == "delete") return(tmp)
      is_update <- a$es_action == "update"
      a$es_action <- NULL
      dat <- jsonlite::toJSON(a, collapse = FALSE, na = "null", auto_unbox = TRUE)
      if (is_update) dat <- sprintf('{"doc": %s, "doc_as_upsert": true}', dat)
      c(tmp, dat)
    }, split(df, seq_along(df)), counter)))
  }
  tmpf <- if (is.null(path)) tempfile("elastic__") else path
  write_utf8(towrite, tmpf)
  invisible(tmpf)
}

make_metadata <- function(es_ids, counter, type) {
  if (!is.null(type)) {
    if (es_ids) {
      '{"%s":{"_index":"%s","_type":"%s"}}'
    } else {
      if (is.character(counter)) {
        '{"%s":{"_index":"%s","_type":"%s","_id":"%s"}}'
      } else {
        '{"%s":{"_index":"%s","_type":"%s","_id":%s}}'
      }
    }    
  } else {
    if (es_ids) {
      '{"%s":{"_index":"%s"}}'
    } else {
      if (is.character(counter)) {
        '{"%s":{"_index":"%s","_id":"%s"}}'
      } else {
        '{"%s":{"_index":"%s","_id":%s}}'
      }
    }
  }
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

cleanup_file <- function(x) {
  # don't unlink file if it is not a tempfile
  if (grepl("elastic__", x)) unlink(x, force = TRUE)
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
