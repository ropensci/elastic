\name{es_search}
\alias{es_search}
\title{Full text search of any CouchDB databases using Elasticsearch.}
\usage{
es_search(url = "http://127.0.0.1", port = 9200, dbname = NULL,
  parse = TRUE, verbose = TRUE, ...)
}
\arguments{
  \item{url}{the url, defaults to localhost
  (http://127.0.0.1)}

  \item{port}{port to connect to, defaults to 5984}

  \item{dbname}{Database name. (charcter)}

  \item{parse}{If TRUE (default), data is parsed to list.
  If FALSE, then raw JSON.}

  \item{verbose}{Verbosity (default) or not. Ignored if
  parse=FALSE}

  \item{...}{Further args passed on to elastic search HTTP
  API.}
}
\description{
Full text search of any CouchDB databases using
Elasticsearch.
}
\details{
There are a lot of terms you can use for Elasticsearch. See
here
\url{http://www.elasticsearch.org/guide/reference/query-dsl/}
for the documentation.
}
\examples{
\dontrun{
results <- es_search(dbname="rplos_db", q="scienceseeker")
sapply(results$hits$hits, function(x) x$`_id`) # get the document IDs
lapply(results$hits$hits, function(x) x$`_source`) # get the document contents
sapply(results$hits$hits, function(x) x$`_source`)[[1]][[1]] # get one of the documents contents'


doc1 <- '{"name":"james","icecream":"mint"}'
doc2 <- '{"name":"jane","icecream":"rocky road"}'
sofa_writedoc(dbname="mydb", doc=doc1)
sofa_writedoc(dbname="mydb", doc=doc2)
es_search(dbname="mydb", q="mint")
}
}

