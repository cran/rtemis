# Extracted from test_PropDocs.R:400

# setup ------------------------------------------------------------------------
library(testthat)
test_env <- simulate_test_env(package = "rtemis", path = "..")
attach(test_env, warn.conflicts = FALSE)

# prequel ----------------------------------------------------------------------
AuditDemoConfig <- S7::new_class(
  name = "AuditDemoConfig",
  package = NULL,
  properties = list(
    n = prop_integer(1L, min = 1L, description = "Count."),
    mode = prop_string(
      "a",
      enum = c("a", "b"),
      description = "Mode."
    ),
    rate = prop_float(
      0.5,
      min = 0,
      max = 1,
      tunable = TRUE,
      description = "Rate."
    )
  )
)
.audit_demo_dir <- function(param_lines) {
  dir <- withr::local_tempdir(.local_envir = parent.frame())
  writeLines(
    c(
      "#' Setup AuditDemo",
      "#'",
      param_lines,
      "setup_AuditDemo <- function() NULL"
    ),
    file.path(dir, "setup_AuditDemo.R")
  )
  dir
}

# test -------------------------------------------------------------------------
r_dir <- test_path("..", "..", "R")
skip_if_not(dir.exists(r_dir), "package R/ sources not available")
findings <- audit_prop_docs(r_dir)
if (nrow(findings) > 0L) {
    detail <- paste0(
      findings[["class"]],
      "@",
      findings[["property"]],
      " [",
      findings[["check"]],
      "] documented: ",
      findings[["documented"]],
      " | declared: ",
      findings[["declared"]],
      collapse = "\n"
    )
    fail(paste0(
      "Property documentation drift (run `Rscript data-raw/audit_props.R`):\n",
      detail
    ))
  } else {
    succeed()
  }
