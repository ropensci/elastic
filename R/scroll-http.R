scroll_POST <- function(conn, path, args = list(), body, raw, asdf, stream_opts, ...) {
  url <- conn$make_url()
  cli <- crul::HttpClient$new(url = file.path(url, path),
    headers = c(conn$headers, json_type()),
    opts = c(conn$opts, ...),
    auth = crul::auth(conn$user, conn$pwd)
  )
  tt <- cli$post(query = args, body = body, encode = "json")
  geterror(conn, tt)
  if (conn$warn) catch_warnings(tt)
  res <- tt$parse("UTF-8")
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

scroll_DELETE <- function(conn, path, body, ...) {
  url <- conn$make_url()
  cli <- crul::HttpClient$new(url = file.path(url, path),
    headers = conn$headers,
    opts = c(conn$opts, ...),
    auth = crul::auth(conn$user, conn$pwd)
  )
  tt <- cli$delete(body = body, encode = "json")
  geterror(conn, tt)
  if (conn$warn) catch_warnings(tt)
  tt$status_code == 200
}
