elastic 0.7.2
=============

### MINOR IMPROVEMENTS

* Changed `docs_bulk()` to always return a list, whether it's given a file,
data.frame, or list. For a file, a named list is returned, while for a 
data.frame or list an unnamed list is returned as many chunks can be processed
and we don't attempt to wrangle the list output. Inputs of data.frame and list
used to return `NULL` as we didn't return anything from the internal for loop. 
You can wrap `docs_bulk` in `invisible()` if you don't want the list printed 
(#142)

### BUG FIXES

* Fixed bug in `docs_bulk()` and `msearch()` in which base URL construction
was not done correctly (#141) thanks @steeled !

elastic 0.7.0
=============

### NEW FEATURES

* New function `scroll_clear()` to clear search contexts created when
using `scroll()` (#140)
* New function `ping()` to ping an Elasticsearch server to see if
it is up (#138)
* `connect()` gains new parameter `es_path` to specify a context path, 
e.g., the `bar` in `http://foo.com/bar` (#137)

### MINOR IMPROVEMENTS

* Change all `httr::content()` calls to parse to plain text
and UTF-8 encoding (#118)
* Added note to docs that when using `scroll()` all scores are
zero b/c scores are not calculated/tracked (#127)
* `connect()` no longer pings the ES server when run, but can
now be done separately with `ping()` (#139)
* Let http request headers be sent with all requests - set with 
`connect()` (#129)
* Added `transport_schema` param to `connect()` to specify 
http or https (#130)
* By default use UUIDs with bulk API with `docs_bulk()` (#125)

### BUG FIXES

* Fix to fail well on empty body sent by user (#119)
* Fix to `docs_bulk()` function so that user supplied `doc_ids` 
are not changed at all now (#123)

elastic 0.6.0
=============

Compatibility for many Elasticsearch versions has improved. We've tested on ES versions
from the current (`v2.1.1`) back to `v1.0.0`, and `elastic` works with all versions.
There are some functions that stop with a message with some ES versions simply 
because older versions may not have had particular ES features. Please do let us 
know if you have problems with older versions of ES, so we can improve compatibility.

### NEW FEATURES

* Added `index_settings_update()` function to allow updating index settings (#66)
* All errors from the Elasticsearch server are now given back as `JSON`. 
Error parsing has thus changed in `elastic`. We now have two levels of error
behavior: 'simple' and 'complete'. These can be set in `connect()` with the 
`errors` parameter. Simple errors give back often just that there was an error,
sometimes a message with explanation is supplied. Complete errors give 
more explanation and even the ES stack trace if supplied in the ES error 
response (#92) (#93)
* New function `msearch()` to do multi-searches. This works by defining queries 
in a file, much like is done for a file to be used in bulk loading. (#103)
* New function `validate()` to validate a search. (#105)
* New suite of functions to work with the percolator service: `percolate_count()`, 
`percolate_delete()`, `percolate_list()`, `percolate_match()`, `percolate_register()`. 
The percolator works by first storing queries into an index and then you define 
documents in order to retrieve these queries. (#106)
* New function `field_stats()` to find statistical properties of a field without 
executing a search (#107)
* Added a Code of Conduct
* New function `cat_nodeattrs()`
* New function `index_recreate()` as a convenience function that detects if an 
index exists, and if so, deletes it first, then creates it again.

### MINOR IMPROVEMENTS

* `docs_bulk()` now supports passing in document ids (to the `_id` field) 
via the parameter `doc_ids` for each input data.frame or list & supports using ids
already in data.frame's or lists (#83)
* `cat_*()` functions cleaned up. previously, some functions had parameters
that were essentially silently ignored. Those parameters dropped now
from the functions. (#96)
* Elasticsearch had for a while 'search exists' functionality (via `/_search/exists`), 
but have removed that in favor of using regular `_search` with `size=0` and 
`terminate_after=1` instead. (#104)
* New parameter `lenient` in `Search()` and `Search_uri` to allow format based 
failures to be ignored, or not ignored.
* Better error handling for `docs_get()` when gthe document isn't found

### BUG FIXES

* Fixed problems in `docs_bulk()` in the use case where users use 
the function in a for loop, for example, and indexing started over, 
replacing documents with the same id (#83)
* Fixed bug in `cat_()` functions in which they sometimes failed 
when `parse=TRUE` (#88)
* Fixed bug in `docs_bulk()` in which user supplied document IDs weren't being 
passed correctly internally (#90)
* Fixed bug in `Search()` and `Search_uri()` where multiple indices weren't 
supported, whereas they should have been - supported now (#115)

### DEFUNCT

* The following functions are now defunct: `mlt()`, `nodes_shutdown()`, `index_status()`, 
and `mapping_delete()` (#94) (#98) (#99) (#110)

elastic 0.5.0
===============

### NEW FEATURES

* Added `index_settings_update()` function to allow updating index settings (#66)

### MINOR IMPROVEMENTS

* Replace `RCurl::curlEscape()` with `curl::curl_escape()` (#81)
* Explicitly import non-base R functions (#80)

### BUG FIXES

* Fixed problems introduced with `v1` of `httr`


elastic 0.4.0
===============

### NEW FEATURES

* New function `Search_uri()` where the search is defined entirely in the URL itself. 
Especially useful for cases in which `POST` requests are forbidden, e.g, on a server
that prevents `POST` requests (which the function `Search()` uses). (#58)
* New function `nodes_shutdown()` (#23)
* `docs_bulk()` gains ability to push data into Elasticsearch via the bulk http API 
from data.frame or list objects. Previously, this function only would accept a file
formatted correctly. In addition, gains new parameters: `index` - The index name to use. 
`type` - The type name to use. `chunk_size` - Size of each chunk. (#60) (#67) (#68)

### MINOR IMPROVEMENTS

* `cat_*()` functions gain new parameters: `h` to specify what fields to return; `help` to 
output available columns, and their meanings; `bytes` to give numbers back machine 
friendly; `parse` Parse to a data.frame or not
* `cat_*()` functions can now optionally capture data returned in to a data.frame (#64)
* `Search()` gains new parameter `search_path` to set the path that is used for searching. 
The default is `_search`, but sometimes in your configuration you've setup so that 
you don't need that path, or it's a different path. (023d28762e7e1028fcb0ad17867f08b5e2c92f93)

### BUG FIXES

* In `docs_mget()` added internal checker to make sure user passes in the right combination of 
`index`, `type`, and `id` parameters, or `index` and `type_id`, or just `index_type_id` (#42)
* Made `index`, `type`, and `id` parameters required in the function `docs_get()` (#43)
* Fixed bug in `scroll()` to allow long `scroll_id`'s by passing scroll ids in the body instead 
of as query parameter (#44)
* In `Search()` function, in the `error_parser()` error parser function, check to see if 
`error` element returned in response body from Elasticsearch, and if so, parse error, if not, 
pass on body (likely empty) (#45)
* In `Search()` function, added helper function to check size and from parameter
values passed in to make sure they are numbers. (#46)
* Across all functions where `index` and `type` parameters used, now using `RCurl::curlEscape()`
to URL escape. Other parameters passed in are go through `httr` CRUD methods, and do URL escaping
for us. (#49)
* Fixed links to development repo in DESCRIPTION file

elastic 0.3.0
===============

First version to go to CRAN.

### NEW FEATURES

* Added a function `scroll()` and a `scroll` parameter to the `Search()` function (#36)
* Added the function `explain()` to easily get at explanation of search results.
* Added a help file added to help explain timem and distance units. See `?units-time` and 
`?units=distance`
* New help file added to list and explain the various search functions. See `?searchapis`
* New function `tokenizer_set()` to set tokenizers
* `connect()` run on package load to set default base url of `localhost` and port of `9200` - 
you can override this by running that fxn yourself, or storing `es_base`, `es_port`, etc. 
in your `.Rprofile` file.

### IMPROVEMENTS

* Made CouchDB river plugin functions not exported for now, may bring back later. 
* Added vignettes for an intro and for search details and examples (#2)
* `es_search()` changed to `Search()`.
* More datasets included in the package for bulk data load (#16)
* All examples wrapped in `\dontrun` instead of `\donttest` so they don't fail on CRAN checks.
* `es_search_body()` removed - body based queries using the query DSL moved to the `Search()` 
function, passed into the `body` parameter.

elastic 0.2.0
===============

### IMPROVEMENTS

* Remoworked package API. Almost all functions have new names. Sorry for this major change
but it needed to be done. This brings `elastic` more in line with the official Elasticsearch
Python client (http://elasticsearch-py.readthedocs.org/en/master/).
* Similar functions are grouped together in the same manual file now to make finder related
functions easier. For example, all functions that work with indices are on the `index` manual
page, and all functions prefixed with `index_()`. Thematic manual files are: `index`, `cat`,
`cluster`, `alias`, `cdbriver`, `connect`, `documents`, `mapping`, `nodes`, and `search`.
* Note that the function `es_cat()` was changed to `cat_()` - we avoided `cat()` because as 
you know there is already a widely used function in base R, see `base::cat()`.
* We changed `cat` functions to separate functions for each command, instead of passing 
the command in as an argument. For example, `cat('aliases')` becomes `cat_aliases()`.
* The `es_` prefix remains only for `es_search()`, as we have to avoid conflict with 
`base::search()`. 
* Removed `assertthat` package import, using `stopifnot()` instead (#14)

elastic 0.1.0
===============

### NEW FEATURES

* First version.
