I have read and agree to the the CRAN policies at 
http://cran.r-project.org/web/packages/policies.html

R CMD CHECK passed on my local OS X install on R 3.1.2 and R development 
version, Ubuntu running on Travis-CI, and Win builder.

All examples are wrapped in \dontrun because all funtions and
examples call the Elasticsearch http API.

On R CMD CHECK there is a note about possibly mis-spelled words,
including "API", "APIs", "Elasticsearch", "JSON", "NoSQL", and 
"indices". As far as I know, these are not incorrect spellings 
of these words/acronyms.

Thanks! Scott Chamberlain
