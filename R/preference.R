#' Preferences.
#' 
#' @name preference
#' 
#' @details 
#' \itemize{
#'  \item _primary The operation will go and be executed only on the primary shards.
#'  \item _primary_first The operation will go and be executed on the primary shard, and if 
#'  not available (failover), will execute on other shards.
#'  \item _local The operation will prefer to be executed on a local allocated shard if possible.
#'  \item _only_node:xyz Restricts the search to execute only on a node with the provided 
#'  node id (xyz in this case).
#'  \item _prefer_node:xyz Prefers execution on the node with the provided node 
#'  id (xyz in this case) if applicable.
#'  \item _shards:2,3 Restricts the operation to the specified shards. (2 and 3 in this case). 
#'  This preference can be combined with other preferences but it has to appear 
#'  first: _shards:2,3;_primary
#'  \item Custom (string) value A custom value will be used to guarantee that the same shards 
#'  will be used for the same custom value. This can help with "jumping values" when hitting 
#'  different shards in different refresh states. A sample value can be something like the web 
#'  session id, or the user name.
#' }
NULL
