# GET wrapper
es_GET <- function(conn, path, index=NULL, type=NULL, metric=NULL, node=NULL,
                        clazz=NULL, raw, callopts=list(), ...){
  url <- conn$make_url()
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
  cli <- crul::HttpClient$new(url = url,
    headers = conn$headers, 
    opts = c(conn$opts, callopts),
    auth = crul::auth(conn$user, conn$pwd)
  )
  tt <- cli$get(query = args)
  geterror(tt)
  if (conn$warn) catch_warnings(tt)
  res <- tt$parse("UTF-8")
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

index_GET <- function(conn, index, features, raw, ...) {
  url <- conn$make_url()
  url <- paste0(url, "/", paste0(esc(index), collapse = ","))
  if (!is.null(features)) features <- paste0(paste0("_", features), collapse = ",")
  if (!is.null(features)) url <- paste0(url, "/", features)
  tt <- crul::HttpClient$new(url = url, headers = conn$headers, 
    opts = c(conn$opts, ...), auth = crul::auth(conn$user, conn$pwd)
  )$get()
  if (tt$status_code > 202) geterror(tt)
  jsonlite::fromJSON(tt$parse('UTF-8'), FALSE)
}

es_POST <- function(conn, path, index=NULL, type=NULL, clazz=NULL, raw, 
  callopts, query, args, ...) {

  url <- construct_url(conn$make_url(), path, cl(index), cl(type))
  url <- prune_trailing_slash(url)
  body <- check_inputs(query)
  if (length(body) == 0) body <- NULL
  cli <- conn$make_conn(url, json_type(), ...)
  tt <- cli$post(body = body, query = args, encode = "json")
  geterror(tt)
  res <- tt$parse("UTF-8")
  if (!is.null(clazz)) {
    class(res) <- clazz
    if (raw) res else es_parse(input = res)
  } else {
    res
  }
}

es_DELETE <- function(conn, url, query = NULL, ...) {
  cli <- conn$make_conn(url, ...)
  tt <- cli$delete(query = query)
  geterror(tt)
  jsonlite::fromJSON(tt$parse("UTF-8"), FALSE)
}

es_PUT <- function(conn, url, body = list(), args = list(), ...) {
  body <- check_inputs(body)
  cli <- conn$make_conn(url, headers = json_type(), ...)
  tt <- cli$put(body = body, query = args, encode = "json")
  geterror(tt)
  jsonlite::fromJSON(tt$parse("UTF-8"), FALSE)
}

es_GET_ <- function(conn, url, query = NULL, ...) {
  cli <- conn$make_conn(url)
  tt <- cli$get(query = query)
  geterror(tt)
  jsonlite::fromJSON(tt$parse('UTF-8'), FALSE)
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
  if (!inherits(z, "HttpResponse")) stop("Input to error parser must be a HttpResponse object")
  if (z$status_code > 202) {
    err <- tryCatch(z$parse("UTF-8"), error = function(e) e)
    err <- if (inherits(err, "simpleError")) jsonlite::fromJSON(z$parse("UTF-8"), FALSE) else err
    if (!inherits(err, "simpleError")) {
      if (nchar(z$parse("UTF-8")) == 0) {
        stop(z$status_http()$message, call. = FALSE)
      }
      err <- tryCatch(
        jsonlite::fromJSON(err, 
                           simplifyVector = FALSE, 
                           simplifyDataFrame = FALSE), error = function(e) e)
      if (inherits(err, "error")) {
        msg <- z$status_http()$message
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
            msg <- z$status_http()$message
          }
        }
        stop(z$status_code, " - ", msg, call. = FALSE)
      }
    } else {
      stop("error", call. = FALSE)
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
