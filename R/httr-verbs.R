# GET wrapper
es_GET <- function(path, index=NULL, type=NULL, metric=NULL, node=NULL, 
                        clazz=NULL, raw, callopts=list(), ...){
  checkconn()
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
  tt <- GET(url, query = args, mc(make_up(), callopts))
  geterror(tt)
  res <- content(tt, as = "text")
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
  if (length(tmp) == 1 && is(tmp, "list")) {
    tmp[[1]]
  } else if (all(vapply(tmp, class, "") == "config")) {
    do.call("c", tmp)
  }
}

index_GET <- function(index, features, raw, ...) {
  checkconn()
  url <- make_url(es_get_auth())
  url <- paste0(url, "/", paste0(esc(index), collapse = ","))
  if (!is.null(features)) features <- paste0(paste0("_", features), collapse = ",")
  if (!is.null(features)) url <- paste0(url, "/", features)
  tt <- GET(url, make_up(), ...)
  if (tt$status_code > 202) geterror(tt)
  jsonlite::fromJSON(content(tt, as = "text"), FALSE)
}

es_POST <- function(path, index=NULL, type=NULL, clazz=NULL, raw, callopts, query, ...) {
  checkconn()
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
  
  tt <- POST(url, body = args, mc(make_up(), callopts), encode = "json")
  geterror(tt)
  # if(tt$status_code > 202) geterror(tt)
  res <- content(tt, as = "text")
  if (!is.null(clazz)) { 
    class(res) <- clazz
    if (raw) res else es_parse(input = res)
  } else { 
    res 
  }
}

es_DELETE <- function(url, query = NULL, ...) {
  checkconn()
  tt <- DELETE(url, query = query, c(make_up(), ...))
  geterror(tt)
  # if(tt$status_code > 202) stop(content(tt)$error)
  jsonlite::fromJSON(content(tt, "text"), FALSE)
}

es_PUT <- function(url, body = list(), ...) {
  checkconn()
  body <- check_inputs(body)
  tt <- PUT(url, body = body, encode = 'json', c(make_up(), ...))
  geterror(tt)
  # if (tt$status_code > 202) stop(content(tt)$error)
  jsonlite::fromJSON(content(tt, "text"), FALSE)
}

es_GET_ <- function(url, query = NULL, ...) {
  checkconn()
  tt <- GET(url, query = query, make_up(), ...)
  geterror(tt)
  # if(tt$status_code > 202) stop(content(tt)$error)
  jsonlite::fromJSON(content(tt, "text"), FALSE)
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
  if (!is(z, "response")) stop("Input to error parser must be a httr response object")
  if (z$status_code > 202) {
    if (is.null(z$headers$statusmessage)) {
      err <- tryCatch(content(z, "text"), error = function(e) e)
      err <- if (is(err, "simpleError")) content(z) else err
      if (!is(err, "simpleError")) {
        err <- jsonlite::fromJSON(err, simplifyVector = FALSE, simplifyDataFrame = FALSE)
        erropt <- Sys.getenv("ELASTIC_RCLIENT_ERRORS")
        if (erropt == "complete") {
          stop(z$status_code, " - ", pluck_reason(err),
               "\nES stack trace:\n",
               pluck_trace(err), call. = FALSE)
        } else {
          msg <- tryCatch(err$error$reason, error = function(e) e)
          if (is(msg, "simpleError") || is.null(msg)) {
            msg <- tryCatch(err$error, error = function(e) e)
            if (is(msg, "simpleError") || is.null(msg)) {
              msg <- httr::http_status(z)$message
              # if (!err$found) {
              #   msg <- "not found"
              # } else {
              #   msg <- "error"
              # }
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
    if (!is(te, "error") || !"error" %in% names(x)) {
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
  if (is(tryerr, "error") || is.null(tryerr)) {
    tryerr <- tryCatch(x$error, error = function(e) e)
    if (is(tryerr, "error") || is.null(tryerr)) {
      "error"
    } else {
      x
    }
  } else {
    tryerr
  }
}
