devtools::load_all(); library(testthat)
connect()

shakespeare <- system.file("examples", "shakespeare_data.json", package = "elastic")
invisible(docs_bulk(shakespeare))

plosdat <- system.file("examples", "plos_data.json", package = "elastic")
invisible(docs_bulk(plosdat))

gbifdat <- system.file("examples", "gbif_data.json", package = "elastic")
invisible(docs_bulk(gbifdat))

gbifgeo <- system.file("examples", "gbif_geo.json", package = "elastic")
invisible(docs_bulk(gbifgeo))
