context("mappings")

x <- connect(warn = FALSE)
load_omdb(x)

## create plos index first -----------------------------------
invisible(tryCatch(index_delete(x, index = "plos", verbose = FALSE), error = function(e) e))
plosdat <- system.file("examples", "plos_data.json", package = "elastic")
invisible(docs_bulk(x, plosdat))

test_that("type_exists works", {
  if (gsub("\\.", "", x$ping()$version$number) <= 100) skip('feature not in this ES version')
  
  res <- tryCatch(docs_get(x, "plos", "article", id=39, verbose = FALSE), 
                  error = function(e) e)
  if (!inherits(res, 'error')) {
    docs_create(x, "plos", "article", id=39, body=list(id="12345", title="New title"))
  }
  te1 <- type_exists(x, index = "plos", type = "article")
  te2 <- type_exists(x, index = "plos", type = "articles")

  expect_true(te1)
  expect_false(te2)
})

test_that("mapping_create works", {
  if (es_version(x) < 600) {
    ## listvbody works
    body <- list(reference = list(properties = list(
      journal = list(type="string"),
      year = list(type="long")
    )))
    invisible(mapping_create(x, index = "plos", type = "reference", body=body))
    mc2 <- mapping_get(x, "plos", "reference")
    
    expect_is(mc2, "list")
    expect_named(mc2, "plos")
    expect_named(mc2$plos$mappings, "reference")
    
    ### json body works
    body <- '{
    "citation": {
      "properties": {
        "journal": { "type": "string" },
        "year": { "type": "long" }
    }}}'
    invisible(mapping_create(x, index = "plos", type = "citation", body=body))
    mc1 <- mapping_get(x, "plos", "citation")
    
    expect_is(mc1, "list")
    expect_named(mc1, "plos")
    expect_named(mc1$plos$mappings, "citation")
    
    ## fails well
    ### A bad mapping body
    body <- list(things = list(properties = list(
      journal = list("string")
    )))
    if (es_version(x) < 120) {
      expect_error(mapping_create(x, index = "plos", type = "things", body = body),
                   "ClassCastException")
    } else {
      expect_error(mapping_create(x, index = "plos", type = "things", body = body),
                   "Expected map for property")
    }
  }
})

test_that("mapping_get works", {
  if (es_version(x) < 600) {
    
    expect_is(mapping_get(x, '_all'), "list")
    mapping_get(x, index = "plos")
    expect_named(mapping_get(x, index = "plos", type = "citation")$plos$mappings, "citation")
    
    maps <- mapping_get(x, index = "plos", type = c("article", "citation", "reference"))$plos$mappings
    expect_is(maps, "list")
    
  }
})

# test_that("mapping_delete works", {
#   # FIXME - not working right now
#   md1 <- mapping_delete(index = "plos", type = "citation")
#
#   expect_is(md1, "list")
#   expect_true(md1$acknowledged)
#
#   expect_error(mapping_delete("plos", "citation"), "No index has the type")
# })

invisible(tryCatch(index_delete(x, index = "plos", verbose = FALSE), error = function(e) e))
plosdat <- system.file("examples", "plos_data.json", package = "elastic")
invisible(docs_bulk(x, plosdat))

test_that("field_mapping_get works", {
  
  if (!es_version(x) < 110) {

    include_type_name <- if (es_version(x) >= 700) TRUE else NULL
    # temporary hack for v7alpha
    if (x$info()$version$number == "7.0.0-alpha2") include_type_name <- NULL
    
    # Get field mappings
    # get all indices
    fmg1 <- field_mapping_get(x, index = "_all", type = "omdb", field = "Country",
      include_type_name = include_type_name)
    # fuzzy field get
    fmg2 <- field_mapping_get(x, index = "plos", type = "article", field = "*",
      include_type_name = include_type_name)
    # get defaults
    fmg3 <- field_mapping_get(x, index = "plos", type = "article", field = "title",
      include_defaults = TRUE, include_type_name = include_type_name)
    # get many
    fmg4 <- field_mapping_get(x, type = "article", field = c("title", "id"),
      include_type_name = include_type_name)
    
    expect_is(fmg1, "list")
    expect_is(fmg2, "list")
    expect_is(fmg3, "list")
    expect_is(fmg4, "list")
    
    expect_equal(length(fmg1$plos$mappings), 0)
    expect_named(fmg3$plos$mappings$article, "title")
    expect_named(fmg3$plos$mappings$article$title$mapping, "title")
    expect_equal(sort(names(fmg4$plos$mappings$article)), c("id", "title"))
    
    # fails well
    expect_error(field_mapping_get(x, index = "_all", field = "text"), "is not TRUE")
    expect_error(field_mapping_get(x, type = "article"), "argument \"field\" is missing")
    
  }
})

# cleanup -----------
invisible(index_delete(x, "plos", verbose = FALSE))
