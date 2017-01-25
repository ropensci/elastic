#' @examples \dontrun{
#' # URI string queries
#' Search_uri(index="shakespeare")
#' Search_uri(index="shakespeare", type="act")
#' Search_uri(index="shakespeare", type="scene")
#' Search_uri(index="shakespeare", type="line")
#'
#' ## Return certain fields
#' if (gsub("\\.", "", ping()$version$number) < 500) {
#'   ### ES < v5
#'   Search_uri(index="shakespeare", fields=c('play_name','speaker'))
#' } else {
#'   ### ES > v5
#'   Search_uri(index="shakespeare", source=c('play_name','speaker'))
#' }
#' 
#' ## Search many indices
#' Search_uri(index = "gbif")$hits$total
#' Search_uri(index = "shakespeare")$hits$total
#' Search_uri(index = c("gbif", "shakespeare"))$hits$total
#' 
#' ## search_type
#' ## NOTE: If you're in ES V5 or greater, see \code{?fielddata}
#' Search_uri(index="shakespeare", search_type = "query_then_fetch")
#' Search_uri(index="shakespeare", search_type = "dfs_query_then_fetch")
#' # Search_uri(index="shakespeare", search_type = "scan") # only when scrolling
#'
#' ## sorting
#' Search_uri(index="shakespeare", type="act", sort="text_entry")
#' Search_uri(index="shakespeare", type="act", sort="speaker:desc", fields='speaker')
#' Search_uri(index="shakespeare", type="act",
#'  sort=c("speaker:desc","play_name:asc"), fields=c('speaker','play_name'))
#'
#' ## paging
#' Search_uri(index="shakespeare", size=1, fields='text_entry')$hits$hits
#' Search_uri(index="shakespeare", size=1, from=1, fields='text_entry')$hits$hits
#'
#' ## queries
#' ### Search in all fields
#' Search_uri(index="shakespeare", type="act", q="york")
#'
#' ### Searchin specific fields
#' Search_uri(index="shakespeare", type="act", q="speaker:KING HENRY IV")$hits$total
#'
#' ### Exact phrase search by wrapping in quotes
#' Search_uri(index="shakespeare", type="act", q='speaker:"KING HENRY IV"')$hits$total
#'
#' ### can specify operators between multiple words parenthetically
#' Search_uri(index="shakespeare", type="act", q="speaker:(HENRY OR ARCHBISHOP)")$hits$total
#'
#' ### where the field line_number has no value (or is missing)
#' Search_uri(index="shakespeare", q="_missing_:line_number")$hits$total
#'
#' ### where the field line_number has any non-null value
#' Search_uri(index="shakespeare", q="_exists_:line_number")$hits$total
#'
#' ### wildcards, either * or ?
#' Search_uri(index="shakespeare", q="*ay")$hits$total
#' Search_uri(index="shakespeare", q="m?y")$hits$total
#'
#' ### regular expressions, wrapped in forward slashes
#' Search_uri(index="shakespeare", q="text_entry:/[a-z]/")$hits$total
#'
#' ### fuzziness
#' Search_uri(index="shakespeare", q="text_entry:ma~")$hits$total
#' Search_uri(index="shakespeare", q="text_entry:the~2")$hits$total
#' Search_uri(index="shakespeare", q="text_entry:the~1")$hits$total
#'
#' ### Proximity searches
#' Search_uri(index="shakespeare", q='text_entry:"as hath"~5')$hits$total
#' Search_uri(index="shakespeare", q='text_entry:"as hath"~10')$hits$total
#'
#' ### Ranges, here where line_id value is between 10 and 20
#' Search_uri(index="shakespeare", q="line_id:[10 TO 20]")$hits$total
#'
#' ### Grouping
#' Search_uri(index="shakespeare", q="(hath OR as) AND the")$hits$total
#'
#' # Limit number of hits returned with the size parameter
#' Search_uri(index="shakespeare", size=1)
#'
#' # Give explanation of search in result
#' Search_uri(index="shakespeare", size=1, explain=TRUE)
#'
#' ## terminate query after x documents found
#' ## setting to 1 gives back one document for each shard
#' Search_uri(index="shakespeare", terminate_after=1)
#' ## or set to other number
#' Search_uri(index="shakespeare", terminate_after=2)
#'
#' ## Get version number for each document
#' Search_uri(index="shakespeare", version=TRUE, size=2)
#'
#' ## Get raw data
#' Search_uri(index="shakespeare", type="scene", raw=TRUE)
#'
#' ## Curl options
#' library('httr')
#' 
#' ### verbose
#' out <- Search_uri(index="shakespeare", type="line", config=verbose())
#' 
#' ### print progress
#' res <- Search_uri(config = progress(), size = 5000)
#' }
