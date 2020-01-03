#' @examples \dontrun{
#' # connection setup
#' (x <- connect())
#' 
#' # URI string queries
#' Search_uri(x, index="shakespeare")
#' ## if you're using an older ES version, you may have types
#' if (gsub("\\.", "", x$ping()$version$number) < 700) {
#' Search_uri(x, index="shakespeare", type="act")
#' Search_uri(x, index="shakespeare", type="scene")
#' Search_uri(x, index="shakespeare", type="line")
#' }
#'
#' ## Return certain fields
#' if (gsub("\\.", "", ping()$version$number) < 500) {
#'   ### ES < v5
#'   Search_uri(x, index="shakespeare", fields=c('play_name','speaker'))
#' } else {
#'   ### ES > v5
#'   Search_uri(x, index="shakespeare", source=c('play_name','speaker'))
#' }
#' 
#' ## Search many indices
#' Search_uri(x, index = "gbif")$hits$total$value
#' Search_uri(x, index = "shakespeare")$hits$total$value
#' Search_uri(x, index = c("gbif", "shakespeare"))$hits$total$value
#' 
#' ## search_type
#' ## NOTE: If you're in ES V5 or greater, see \code{?fielddata}
#' Search_uri(x, index="shakespeare", search_type = "query_then_fetch")
#' Search_uri(x, index="shakespeare", search_type = "dfs_query_then_fetch")
#' # Search_uri(x, index="shakespeare", search_type = "scan") # only when scrolling
#'
#' ## sorting
#' Search_uri(x, index="shakespeare", sort="text_entry")
#' if (gsub("\\.", "", x$ping()$version$number) < 500) {
#'   Search_uri(x, index="shakespeare", sort="speaker:desc", fields='speaker')
#'   Search_uri(x, index="shakespeare", sort=c("speaker:desc","play_name:asc"),
#'     fields=c('speaker','play_name'))
#' }
#'
#' ## pagination
#' Search_uri(x, index="shakespeare", size=1)$hits$hits
#' Search_uri(x, index="shakespeare", size=1, from=1)$hits$hits
#'
#' ## queries
#' ### Search in all fields
#' Search_uri(x, index="shakespeare", q="york")
#'
#' ### Searchin specific fields
#' Search_uri(x, index="shakespeare", q="speaker:KING HENRY IV")$hits$total$value
#'
#' ### Exact phrase search by wrapping in quotes
#' Search_uri(x, index="shakespeare", q='speaker:"KING HENRY IV"')$hits$total$value
#'
#' ### can specify operators between multiple words parenthetically
#' Search_uri(x, index="shakespeare", q="speaker:(HENRY OR ARCHBISHOP)")$hits$total$value
#'
#' ### where the field line_number has no value (or is missing)
#' Search_uri(x, index="shakespeare", q="_missing_:line_number")$hits$total$value
#'
#' ### where the field line_number has any non-null value
#' Search_uri(x, index="shakespeare", q="_exists_:line_number")$hits$total$value
#'
#' ### wildcards, either * or ?
#' Search_uri(x, index="shakespeare", q="*ay")$hits$total$value
#' Search_uri(x, index="shakespeare", q="m?y")$hits$total$value
#'
#' ### regular expressions, wrapped in forward slashes
#' Search_uri(x, index="shakespeare", q="text_entry:/[a-z]/")$hits$total$value
#'
#' ### fuzziness
#' Search_uri(x, index="shakespeare", q="text_entry:ma~")$hits$total$value
#' Search_uri(x, index="shakespeare", q="text_entry:the~2")$hits$total$value
#' Search_uri(x, index="shakespeare", q="text_entry:the~1")$hits$total$value
#'
#' ### Proximity searches
#' Search_uri(x, index="shakespeare", q='text_entry:"as hath"~5')$hits$total$value
#' Search_uri(x, index="shakespeare", q='text_entry:"as hath"~10')$hits$total$value
#'
#' ### Ranges, here where line_id value is between 10 and 20
#' Search_uri(x, index="shakespeare", q="line_id:[10 TO 20]")$hits$total$value
#'
#' ### Grouping
#' Search_uri(x, index="shakespeare", q="(hath OR as) AND the")$hits$total$value
#'
#' # Limit number of hits returned with the size parameter
#' Search_uri(x, index="shakespeare", size=1)
#'
#' # Give explanation of search in result
#' Search_uri(x, index="shakespeare", size=1, explain=TRUE)
#'
#' ## terminate query after x documents found
#' ## setting to 1 gives back one document for each shard
#' Search_uri(x, index="shakespeare", terminate_after=1)
#' ## or set to other number
#' Search_uri(x, index="shakespeare", terminate_after=2)
#'
#' ## Get version number for each document
#' Search_uri(x, index="shakespeare", version=TRUE, size=2)
#'
#' ## Get raw data
#' Search_uri(x, index="shakespeare", raw=TRUE)
#'
#' ## Curl options
#' ### verbose
#' out <- Search_uri(x, index="shakespeare", verbose = TRUE)
#' }
