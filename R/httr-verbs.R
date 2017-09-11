# GET wrapper
es_GET <- function(path, index=NULL, type=NULL, metric=NULL, node=NULL,
                        clazz=NULL, raw, callopts=list(), ...){
  url <- make_url(es_get_auth())
  index <- esc(index)
  type <- esc(type)
  if (is.null(index) && is.null(type)) {
    url <- paste(url, path, sep = "/")
  } else {
    if (is.null(type) && !is.null(index)) {
      url <- paste(url, index, path, sep = "/")
    } else {
      url <- paste(url, index, type, path, sep = "/")
    }
  }

  if (!is.null(node)) {
    url <- paste(url, paste(node, collapse = ","), sep = "/")
  }
  if (!is.null(metric)) {
    url <- paste(url, paste(metric, collapse = ","), sep = "/")
  }

  args <- ec(list(...))
  if (length(args) == 0) args <- NULL
  tt <- GET(url, query = args, c(es_env$headers, mc(make_up(), callopts)))
  geterror(tt)
  res <- cont_utf8(tt)
  if (!is.null(clazz)) {
    class(res) <- clazz
    if (raw) res else es_parse(res)
  } else {
    res
  }
}

mc <- function(...) {
  tmp <- ec(list(...))
  tmp <- tmp[sapply(tmp, length) != 0]
  if (length(tmp) == 1 && inherits(tmp, "list")) {
    tmp[[1]]
  } else if (all(vapply(tmp, class, "") == "config")) {
    do.call("c", tmp)
  }
}

index_GET <- function(index, features, raw, ...) {
  url <- make_url(es_get_auth())
  url <- paste0(url, "/", paste0(esc(index), collapse = ","))
  if (!is.null(features)) features <- paste0(paste0("_", features), collapse = ",")
  if (!is.null(features)) url <- paste0(url, "/", features)
  tt <- GET(url, make_up(), es_env$headers, ...)
  if (tt$status_code > 202) geterror(tt)
  jsonlite::fromJSON(cont_utf8(tt), FALSE)
}

es_POST <- function(path, index=NULL, type=NULL, clazz=NULL, raw, callopts, query, ...) {
  url <- make_url(es_get_auth())
  index <- esc(index)
  type <- esc(type)
  if (is.null(index) && is.null(type)) {
    url <- paste(url, path, sep = "/")
  } else {
    if (is.null(type) && !is.null(index)) {
      url <- paste(url, index, path, sep = "/")
    } else {
      url <- paste(url, index, type, path, sep = "/")
    }
  }

  args <- check_inputs(query)
  if (length(args) == 0) args <- NULL

  tt <- POST(url, body = args, content_type_json(),
             c(es_env$headers, mc(make_up(), callopts)), 
             encode = "json")
  geterror(tt)
  res <- cont_utf8(tt)
  if (!is.null(clazz)) {
    class(res) <- clazz
    if (raw) res else es_parse(input = res)
  } else {
    res
  }
}

es_DELETE <- function(url, query = NULL, ...) {
  tt <- DELETE(url, query = query, c(make_up(), es_env$headers, ...))
  geterror(tt)
  jsonlite::fromJSON(cont_utf8(tt), FALSE)
}

es_PUT <- function(url, body = list(), args = list(), ...) {
  body <- check_inputs(body)
  tt <- PUT(url, body = body, query = args, 
            encode = 'json', content_type_json(),
            make_up(), es_env$headers, ...)
  geterror(tt)
  jsonlite::fromJSON(cont_utf8(tt), FALSE)
}

es_GET_ <- function(url, query = NULL, ...) {
  tt <- GET(url, query = query, make_up(), es_env$headers, ...)
  geterror(tt)
  jsonlite::fromJSON(cont_utf8(tt), FALSE)
}

check_inputs <- function(x) {
  if (length(x) == 0) {
    NULL
  } else {
    if (is.character(x)) {
      # replace newlines
      x <- gsub("\n|\r", "", x)
      # validate
      tmp <- jsonlite::validate(x)
      if (!tmp) stop(attr(tmp, "err"))
      x
    } else {
      jsonlite::toJSON(x, auto_unbox = TRUE)
    }
  }
}

geterror <- function(z) {
  if (!inherits(z, "response")) stop("Input to error parser must be a httr response object")
  if (z$status_code > 202) {
    if (is.null(z$headers$statusmessage)) {
      err <- tryCatch(cont_utf8(z), error = function(e) e)
      err <- if (inherits(err, "simpleError")) jsonlite::fromJSON(cont_utf8(z), FALSE) else err
      if (!inherits(err, "simpleError")) {
        if (nchar(cont_utf8(z)) == 0) {
          stop(http_status(z)$message, call. = FALSE)
        }
        err <- tryCatch(
          jsonlite::fromJSON(err, 
                             simplifyVector = FALSE, 
                             simplifyDataFrame = FALSE), error = function(e) e)
        if (inherits(err, "error")) {
          msg <- httr::http_status(z)$message
          stop(msg, call. = FALSE)
        }
        
        erropt <- Sys.getenv("ELASTIC_RCLIENT_ERRORS")
        if (erropt == "complete") {
          stop(z$status_code, " - ", pluck_reason(err),
               "\nES stack trace:\n",
               pluck_trace(err), call. = FALSE)
        } else {
          msg <- tryCatch(err$error$reason, error = function(e) e)
          if (inherits(msg, "simpleError") || is.null(msg)) {
            msg <- tryCatch(err$error, error = function(e) e)
            if (inherits(msg, "simpleError") || is.null(msg)) {
              msg <- httr::http_status(z)$message
            }
          }
          stop(z$status_code, " - ", msg, call. = FALSE)
        }
      } else {
        stop("error", call. = FALSE)
      }
    } else {
      z$headers$statusmessage
    }
  }
}

pluck_trace <- function(x) {
  if (is.null(x)) {
    " - no stack trace"
  } else {
    te <- tryCatch(x$error$root_cause, error = function(e) e)
    if (!inherits(te, "error") || !"error" %in% names(x)) {
      if (!"error" %in% names(x)) {
        te <- x
      }
      x <- as.list(unlist(te))
      paste0("\n  ", paste(names(x), unname(x), sep = ": ", collapse = "\n  "))
    } else {
      sprintf("\n  error: %s", x$error)
    }
  }
}

pluck_reason <- function(x) {
  tryerr <- tryCatch(x$error$reason, error = function(e) e)
  if (inherits(tryerr, "error") || is.null(tryerr)) {
    tryerr <- tryCatch(x$error, error = function(e) e)
    if (inherits(tryerr, "error") || is.null(tryerr)) {
      "error"
    } else {
      x
    }
  } else {
    tryerr
  }
}
