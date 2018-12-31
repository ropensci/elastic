#' Cat class 
#' 
#' holds all cat API methods
#'
#' @name Cat-class
#' @export
#' @param verbose (logical) If `TRUE` (default) the url call used printed 
#' to console
#' @param index (character) Index name
#' @param fields (character) Fields to return, only used with `fielddata`
#' @param h (character) Fields to return
#' @param help (logical) Output available columns, and their meanings
#' @param bytes (logical) Give numbers back machine friendly. Default: `FALSE`
#' @param parse (logical) Parse to a data.frame or not. Default: `FALSE`
#' @param ... Curl args passed on to [crul::verb-GET]
#' @format NULL
#' @usage NULL
#' @details xxxx
#' @examples \dontrun{
#' (x <- connect())
#' x$ping()
#' z <- Cat$new(x)
#' z
#' z$conn
#' z$help()
#' z$aliases()
#' z$allocation()
#' z$count()
#' z$segments()
#' z$health()
#' z$indices()
#' z$master()
#' z$nodes()
#' z$nodeattrs()
#' z$pending_tasks()
#' z$plugins()
#' z$recovery()
#' z$thread_pool()
#' z$shards()
#' z$fielddata()
#' }
Cat <- R6::R6Class(
  "Cat",
  public = list(
    conn = NULL,
    initialize = function(conn) {
      is_conn(conn)
      self$conn <- conn
    },
    help = function(parse = FALSE, ...) cat_(self$conn, parse = parse, ...),
    aliases = function(verbose=FALSE, index=NULL, h=NULL, help=FALSE, 
      bytes=FALSE, parse=FALSE, ...) {
      cat_aliases(self$conn, verbose=verbose, index=index, h=h, help=help, 
        bytes=bytes, parse=parse, ...)
    },
    allocation = function(verbose=FALSE, h=NULL, help=FALSE, 
      bytes=FALSE, parse=FALSE, ...) {
      cat_allocation(self$conn, verbose=verbose, h=h, help=help, 
        bytes=bytes, parse=parse, ...)
    },
    count = function(verbose=FALSE, index=NULL, h=NULL, help=FALSE, 
      bytes=FALSE, parse=FALSE, ...){
      cat_count(self$conn, verbose=verbose, index=index, h=h, help=help, 
        bytes=bytes, parse=parse, ...)
    },
    segments = function(verbose=FALSE, index=NULL, h=NULL, help=FALSE, 
      bytes=FALSE, parse=FALSE, ...) {
      cat_segments(self$conn, verbose=verbose, index=index, h=h, help=help, 
        bytes=bytes, parse=parse, ...)
    },
    health = function(verbose=FALSE, h=NULL, help=FALSE, bytes=FALSE, 
      parse=FALSE, ...) {
      cat_health(self$conn, verbose=verbose, h=h, help=help, 
        bytes=bytes, parse=parse, ...)
    },
    indices = function(verbose=FALSE, index=NULL, h=NULL, help=FALSE, 
      bytes=FALSE, parse=FALSE, ...) {
      cat_indices(self$conn, verbose=verbose, index=index, h=h, help=help, 
        bytes=bytes, parse=parse, ...)
    },
    master = function(verbose=FALSE, index=NULL, h=NULL, help=FALSE, 
      bytes=FALSE, parse=FALSE, ...) {
      cat_master(self$conn, verbose=verbose, index=index, h=h, help=help, 
        bytes=bytes, parse=parse, ...)
    },
    nodes = function(verbose=FALSE, h=NULL, help=FALSE, bytes=FALSE, 
      parse=FALSE, ...) {
      cat_nodes(self$conn, verbose=verbose, h=h, help=help, 
        bytes=bytes, parse=parse, ...)
    },
    nodeattrs = function(verbose=FALSE, h=NULL, help=FALSE, bytes=FALSE,
      parse=FALSE, ...) {
      cat_nodeattrs(self$conn, verbose=verbose, h=h, help=help, 
        bytes=bytes, parse=parse, ...)
    },
    pending_tasks = function(verbose=FALSE, h=NULL, help=FALSE, 
      bytes=FALSE, parse=FALSE, ...) {
      cat_pending_tasks(self$conn, verbose=verbose, h=h, help=help, 
        bytes=bytes, parse=parse, ...)
    },
    plugins = function(verbose=FALSE, h=NULL, help=FALSE, bytes=FALSE, 
      parse=FALSE, ...) {
      cat_plugins(self$conn, verbose=verbose, h=h, help=help, 
        bytes=bytes, parse=parse, ...)
    },
    recovery = function(verbose=FALSE, index=NULL, h=NULL, help=FALSE, 
      bytes=FALSE, parse=FALSE, ...) {
      cat_recovery(self$conn, verbose=verbose, index=index, h=h, help=help, 
        bytes=bytes, parse=parse, ...)
    },
    thread_pool = function(verbose=FALSE, index=NULL, h=NULL, help=FALSE, 
      bytes=FALSE, parse=FALSE, ...) {
      cat_thread_pool(self$conn, verbose=verbose, index=index, h=h, help=help, 
        bytes=bytes, parse=parse, ...)
    },
    shards = function(verbose=FALSE, index=NULL, h=NULL, help=FALSE, 
      bytes=FALSE, parse=FALSE, ...) {
      cat_shards(self$conn, verbose=verbose, index=index, h=h, help=help, 
        bytes=bytes, parse=parse, ...)
    },
    fielddata = function(verbose=FALSE, index=NULL, fields=NULL, h=NULL, 
      help=FALSE, bytes=FALSE, parse=FALSE, ...) {
      cat_fielddata(self$conn, verbose=verbose, index=index, fields=fields, 
        h=h, help=help, bytes=bytes, parse=parse, ...)
    }
  )
)
