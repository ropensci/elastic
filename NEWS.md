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
