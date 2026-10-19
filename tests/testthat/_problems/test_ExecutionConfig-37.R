# Extracted from test_ExecutionConfig.R:37

# setup ------------------------------------------------------------------------
library(testthat)
test_env <- simulate_test_env(package = "rtemis", path = "..")
attach(test_env, warn.conflicts = FALSE)

# prequel ----------------------------------------------------------------------
ec <- FutureExecutionConfig(
  n_workers = 4L,
  future_plan = "multisession"
)
ec

# test -------------------------------------------------------------------------
expect_s7_class(ec, ExecutionConfig)
expect_s7_class(ec, ParallelExecutionConfig)
expect_identical(ec@backend, "future")
expect_s7_class(SerialExecutionConfig(), ExecutionConfig)
expect_identical(SerialExecutionConfig()@backend, "none")
expect_identical(MiraiExecutionConfig()@backend, "mirai")
expect_named(
    props(SerialExecutionConfig()),
    c(
      "backend",
      "n_workers_algorithm",
      "warm_workers",
      "on_error",
      "seed",
      "shared_memory"
    )
  )
