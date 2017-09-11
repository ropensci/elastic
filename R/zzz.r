ec <- function(l) Filter(Negate(is.null), l)

cont_utf8 <- function(x) content(x, as = "text", encoding = "UTF-8")

as_log <- function(x){
  if (is.null(x)) {
    x
  } else {
    if (x) 'true' else 'false'
  }
}

`%|||%` <- function(x, y) if (x == "false") y else x

cl <- function(x) if (is.null(x)) NULL else paste0(x, collapse = ",")

cw <- function(x) if (is.null(x)) x else paste(x, collapse = ",")

scroll_POST <- function(path, args = list(), body, raw, asdf, stream_opts, ...) {
  url <- make_url(es_get_auth())
  tt <- POST(file.path(url, path), make_up(), 
             es_env$headers, content_type_json(), ..., encode = "json",
             query = args, body = body)
  geterror(tt)
  res <- cont_utf8(tt)
  if (raw) {
    res 
  } else {
    if (length(stream_opts) != 0) {
      dat <- jsonlite::fromJSON(res, flatten = TRUE)
      stream_opts$x <- dat$hits$hits
      if (length(stream_opts$x) != 0) {
        stream_opts$con <- file(stream_opts$file, open = "ab")
        stream_opts$file <- NULL
        do.call(jsonlite::stream_out, stream_opts)
        close(stream_opts$con)
      } else {
        warning("no scroll results remain", call. = FALSE)
      }
      return(list(`_scroll_id` = dat$`_scroll_id`))
    } else {
      jsonlite::fromJSON(res, asdf, flatten = TRUE)
    }
  }
}

scroll_DELETE <- function(path, body, ...) {
  url <- make_url(es_get_auth())
  tt <- DELETE(file.path(url, path), make_up(), es_env$headers, ..., 
               body = body, encode = "json")
  geterror(tt)
  tt$status_code == 200
}

esc <- function(x) {
  if (is.null(x)) {
    NULL
  } else {
    curl::curl_escape(x)
  }
}

pluck <- function(x, name, type) {
  if (missing(type)) {
    lapply(x, "[[", name)
  } else {
    vapply(x, "[[", name, FUN.VALUE = type)
  }
}

make_up <- function() {
  up <- es_get_user_pwd()
  if (nchar(up$user) != 0 && nchar(up$pwd) != 0) {
    authenticate(up$user, up$pwd)
  } else {
    list()
  }
}

# Make sure variable is a numeric or integer --------------
cn <- function(x) {
  name <- substitute(x)
  if (!is.null(x)) {
    tryx <- tryCatch(as.numeric(as.character(x)), warning = function(e) e)
    if ("warning" %in% class(tryx)) {
      stop(name, " should be a numeric or integer class value", call. = FALSE)
    }
    if (!inherits(tryx, "numeric") | is.na(tryx))
      stop(name, " should be a numeric or integer class value", call. = FALSE)
    return( format(x, digits = 22, scientific = FALSE) )
  } else {
    NULL
  }
}

strmatch <- function(x, y) regmatches(x, regexpr(y, x))

strloc2match <- function(x, first, y) substring(x, first, regexpr(y, x) - 1)

prune_trailing_slash <- function(x) {
  gsub("\\/$", "", x)
}

construct_url <- function(url, path, index, type = NULL, id = NULL) {
  index <- esc(index)
  type <- esc(type)
  if (is.null(index) && is.null(type)) {
    paste(url, path, sep = "/")
  } else {
    if (is.null(type) && !is.null(index)) {
      paste(url, index, path, sep = "/")
    } else if (!is.null(type) && !is.null(index) && is.null(id)) {
      paste(url, index, type, path, sep = "/")
    } else if (!is.null(type) && !is.null(index) && !is.null(id)) {
      paste(url, index, type, id, path, sep = "/")
    } else if (!is.null(type) && is.null(index) && !is.null(id)) {
      stop("If a document ID is given, an index type must be given", 
           call. = FALSE)
    }
  }
}

extractr <- function(x, y) regmatches(x, gregexpr(y, x))

elastic_env <- new.env()

es_ver <- function() {
  pinged <- elastic_env$ping_result
  if (is.null(pinged)) {
    elastic_env$ping_result <- pinged <- ping()
  }
  ver <- pinged$version$number
  
  # get only 1st 3 digits, so major:minor:patch
  as.numeric(
    paste(
      stats::na.omit(
        extractr(ver, "[[:digit:]]+")[[1]][1:3]
      ), 
      collapse = ""
    )
  )
}

stop_es_version <- function(ver_check, fxn) {
  if (es_ver() < ver_check) {
    stop(fxn, " is not available for this Elasticsearch version", 
         call. = FALSE)
  }
}
