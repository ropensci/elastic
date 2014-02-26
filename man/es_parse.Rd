\name{es_parse}
\alias{es_parse}
\alias{es_parse.elastic_get}
\alias{es_parse.elastic_mget}
\alias{es_parse.elastic_search}
\title{Parse raw data from es_get, es_mget, or es_search.}
\usage{
es_parse(input, parsetype, verbose)

\method{es_parse}{elastic_get}(input, parsetype = NULL, verbose = FALSE)

\method{es_parse}{elastic_mget}(input, parsetype = NULL, verbose = FALSE)

\method{es_parse}{elastic_search}(input, parsetype = NULL, verbose = FALSE)
}
\arguments{
  \item{input}{Output from solr_facet}

  \item{parsetype}{One of 'list' or 'df' (data.frame)}

  \item{verbose}{Print messages or not (default: FALSE).}
}
\description{
See details.
}
\details{
This is the parser used internally in es_get, es_mget, and
es_search, but if you output raw data from solr_facet using
raw=TRUE, then you can use this function to parse that data
(a sr_facet S3 object) after the fact to a list of
data.frame's for easier consumption. The data format type
is detected from the attribute "wt" on the sr_facet object.
}

