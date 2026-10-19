# Extracted from test_RecordDocuments.R:161

# setup ------------------------------------------------------------------------
library(testthat)
test_env <- simulate_test_env(package = "rtemis", path = "..")
attach(test_env, warn.conflicts = FALSE)

# prequel ----------------------------------------------------------------------
testthat::skip_if_not_installed("jsonvalidate")
.stub_external_refs <- function(node) {
  if (!is.list(node)) {
    return(node)
  }
  ref <- node[["$ref"]]
  if (is.character(ref) && length(ref) == 1L && startsWith(ref, "https://")) {
    return(list(type = "object"))
  }
  lapply(node, .stub_external_refs)
}
.record_bundle <- function(base, leaf, discriminator, family) {
  slug <- tolower(discriminator_value(leaf, discriminator))
  leaf_id <- paste0(
    "https://schema.rtemis.org/",
    family,
    "/",
    slug,
    "/v1/record.json"
  )
  disp <- S7_dispatcher_JSONSchema(
    classes = list(leaf),
    id = paste0("https://schema.rtemis.org/", family, "/v1/record.json"),
    discriminator = discriminator,
    base = base,
    record = TRUE,
    title = family,
    description = family,
    discriminator_description = discriminator
  )
  d <- S7_to_JSONSchema(
    leaf,
    id = leaf_id,
    title = leaf@name,
    description = leaf@name,
    base = base,
    record = TRUE,
    closed = FALSE
  )
  d[["$id"]] <- NULL
  d[["properties"]][["$schema"]] <- NULL
  d <- .stub_external_refs(d)
  # The dispatcher declares the base's shared fields, which can reference other
  # families too (an execution config's `device`); its dispatch clauses are
  # rewritten below, so only its properties are stubbed.
  disp[["properties"]] <- .stub_external_refs(disp[["properties"]])
  disp[["$defs"]] <- stats::setNames(list(d), slug)
  disp[["$id"]] <- NULL
  disp[["allOf"]] <- lapply(disp[["allOf"]], function(clause) {
    if (!is.null(clause[["then"]][["$ref"]])) {
      clause[["then"]][["$ref"]] <- paste0("#/$defs/", slug)
    }
    clause
  })
  jsonvalidate::json_validator(
    jsonlite::toJSON(disp, auto_unbox = TRUE, null = "null"),
    engine = "ajv"
  )
}
.cases <- function() {
  list(
    execution = setup_SerialExecution(seed = 1L),
    execution_parallel = setup_MiraiExecution(n_workers = 2L, seed = 1L),
    execution_device = setup_SerialExecution(
      device = setup_CUDADevice(ids = 0:1),
      seed = 1L
    ),
    device = setup_CUDADevice(ids = 1L),
    clustering = setup_KMeans(k = 3L),
    clustering_nested = setup_PAMK(
      krange = 2:4,
      criterion = setup_MultiASWCriterion(n_subsets = 5L)
    ),
    pamkcriterion = setup_MultiASWCriterion(n_subsets = 5L),
    decomposition = setup_PCA(k = 2L),
    resampler = setup_KFold(3L),
    tuner = setup_GridSearch(resampler_config = setup_KFold(3L)),
    ingest = setup_DelimitedIngest(),
    partition = setup_RandomPartition(),
    conformal = setup_SplitConformal(),
    explanation = setup_SHAP(),
    hyperparameters = setup_GLM()
  )
}

# test -------------------------------------------------------------------------
for (nm in names(.cases())) {
    obj <- .cases()[[nm]]
    cls <- S7_class(obj)
    base <- family_base(cls)
    discriminator <- family_discriminator(obj)
    expect_false(
      is.null(discriminator),
      info = paste0(nm, ": family has no declared discriminator.")
    )
    if (is.null(discriminator)) {
      # Report every affected family rather than stopping at the first.
      next
    }
    validator <- .record_bundle(base, cls, discriminator, tolower(base@name))
    doc <- jsonlite::toJSON(
      nested_record(obj, obj),
      auto_unbox = TRUE,
      null = "null"
    )
    # Validating against the schema is not enough on its own: a writer and a
    # schema that are short in the *same* way agree with each other. This says
    # what a record is for -- every value it carries states where it came from
    # -- and is derived from the document, not from the helpers that built it.
    #
    # Two exemptions, both structural: the discriminator is implied by the
    # variant rather than chosen, and a nested config block carries an `origin`
    # of its own.
    record <- nested_record(obj, obj)
    fields <- setdiff(names(record), "origin")
    nested <- Filter(
      function(f) is.list(record[[f]]) && "origin" %in% names(record[[f]]),
      fields
    )
    expect_setequal(
      names(record[["origin"]]),
      setdiff(fields, c(discriminator, nested))
    )

    result <- validator(doc, verbose = TRUE)
    errors <- attr(result, "errors")
    expect_true(
      isTRUE(result),
      info = paste0(
        nm,
        " (",
        cls@name,
        "): the record rtemis writes does not validate against the record ",
        "schema rtemis publishes.\n",
        if (!is.null(errors)) {
          paste(utils::head(errors[["message"]], 8), collapse = "\n")
        }
      )
    )
  }
