context("mappings")

invisible(connect())

## create plos index first -----------------------------------
invisible(tryCatch(index_delete(index = "plos", verbose = FALSE), error = function(e) e))
plosdat <- system.file("examples", "plos_data.json", package = "elastic")
invisible(docs_bulk(plosdat))

test_that("type_exists works", {

  res <- tryCatch(docs_get("plos", "article", id=1002, verbose = FALSE), 
                  error = function(e) e)
  if (!is(res, 'error')) {
    docs_create("plos", "article", id=1002, body=list(id="12345", title="New title"))
  }
  te1 <- type_exists(index = "plos", type = "article")
  te2 <- type_exists(index = "plos", type = "articles")

  expect_true(te1)
  expect_false(te2)
})

test_that("mapping_create works", {

  ## listvbody works
  body <- list(reference = list(properties = list(
   journal = list(type="string"),
   year = list(type="long")
  )))
  invisible(mapping_create(index = "plos", type = "reference", body=body))
  mc2 <- mapping_get("plos", "reference")

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
  invisible(mapping_create(index = "plos", type = "citation", body=body))
  mc1 <- mapping_get("plos", "citation")

  expect_is(mc1, "list")
  expect_named(mc1, "plos")
  expect_named(mc1$plos$mappings, "citation")

  ## fails well
  ### A bad mapping body
  body <- list(things = list(properties = list(
    journal = list("string")
  )))
  if (es_version() < 120) {
    expect_error(mapping_create(index = "plos", type = "things", body = body),
                 "ClassCastException")
  } else {
    expect_error(mapping_create(index = "plos", type = "things", body = body),
                 "Expected map for property")
  }
})

test_that("mapping_get works", {

  expect_is(mapping_get('_all'), "list")
  mapping_get(index = "plos")
  expect_named(mapping_get(index = "plos", type = "citation")$plos$mappings, "citation")

  maps <- mapping_get(index = "plos", type = c("article", "citation", "reference"))$plos$mappings
  expect_is(maps, "list")
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

test_that("field_mapping_get works", {
  
  if (!es_version() < 110) {
    
    # Get field mappings
    # get all indices
    fmg1 <- field_mapping_get(index = "_all", type = "reference", field = "text")
    # fuzzy field get
    fmg2 <- field_mapping_get(index = "plos", type = "article", field = "*")
    # get defaults
    fmg3 <- field_mapping_get(index = "plos", type = "article", field = "title", include_defaults = TRUE)
    # get many
    fmg4 <- field_mapping_get(type = "article", field = c("title", "id"))
    
    expect_is(fmg1, "list")
    expect_is(fmg2, "list")
    expect_is(fmg3, "list")
    expect_is(fmg4, "list")
    
    expect_equal(length(fmg1$plos$mappings), 0)
    expect_named(fmg3$plos$mappings$article, "title")
    expect_named(fmg3$plos$mappings$article$title$mapping, "title")
    expect_named(fmg4$plos$mappings$article, c("id", "title"))
    
    # fails well
    expect_error(field_mapping_get(index = "_all", field = "text"), "is not TRUE")
    expect_error(field_mapping_get(type = "article"), "argument \"field\" is missing")
    
  }
})

# cleanup -----------
invisible(index_delete("plos", verbose = FALSE))
