es_search <- function(conn, url="http://127.0.0.1", port=9200, dbname=NULL, parse=TRUE, 
  verbose=TRUE, ...)
{
  if(is.null(dbname)){
    call_ <- url
  } else
  {
    call_ <- paste(paste(url, port, sep=":"), "/", dbname, "/_search", sep="")    
  }
  args <- ec(list(...))
  out <- GET(call_, query=args)
  stop_for_status(out)

  if(!parse){
    tt <- content(out, as="text")
    class(tt) <- "elastic"
    return( tt )
  } else {
    parsed <- content(out)
    if(verbose)
      max_score <- parsed$hits$max_score
      message(paste("\nmatches -> ", round(parsed$hits$total,1), "\nscore -> ", 
        ifelse(is.null(max_score), NA, round(max_score, 3)), sep="")
      )
    class(parsed) <- "elastic"
    return( parsed )
  }
}