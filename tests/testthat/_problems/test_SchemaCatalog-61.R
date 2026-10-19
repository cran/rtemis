# Extracted from test_SchemaCatalog.R:61

# setup ------------------------------------------------------------------------
library(testthat)
test_env <- simulate_test_env(package = "rtemis", path = "..")
attach(test_env, warn.conflicts = FALSE)

# test -------------------------------------------------------------------------
original <- jsonlite::fromJSON(
    test_path("fixtures", "schema-publication.json"),
    simplifyVector = FALSE
  )
catalog <- schema_catalog()
identities <- names(schema_reference_urls(
    catalog,
    "https://schema.rtemis.org"
  ))
expect_true(all(startsWith(identities, "rtemis::")))
derived <- list(
    families = lapply(catalog[["families"]], function(f) {
      list(
        base_class = f[["base_class"]]@name,
        title = f[["title"]],
        description = f[["description"]],
        discriminator_description = f[["discriminator_description"]],
        algorithms = lapply(f[["algorithms"]], function(a) {
          list(class = a[["cls"]]@name, description = a[["desc"]])
        })
      )
    }),
    documents = lapply(catalog[["flat_configs"]], function(f) {
      list(
        class = f[["cls"]]@name,
        title = f[["title"]],
        description = f[["description"]]
      )
    })
  )
expect_identical(
    setdiff(names(derived[["documents"]]), names(original[["documents"]])),
    c(
      "classification",
      "classificationres",
      "implementation",
      "regression",
      "regressionres",
      "resamplerresult",
      "supervisedresult",
      "supervisedres",
      "variableimportance"
    )
  )
derived[["documents"]][c(
    "classification",
    "classificationres",
    "implementation",
    "regression",
    "regressionres",
    "resamplerresult",
    "supervisedresult",
    "supervisedres",
    "variableimportance"
  )] <- NULL
expect_identical(derived, original)
