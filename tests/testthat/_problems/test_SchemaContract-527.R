# Extracted from test_SchemaContract.R:527

# setup ------------------------------------------------------------------------
library(testthat)
test_env <- simulate_test_env(package = "rtemis", path = "..")
attach(test_env, warn.conflicts = FALSE)

# prequel ----------------------------------------------------------------------
.contract_family <- function(base, ...) {
  lapply(list(...), function(pair) {
    list(cls = pair[[1L]], setup = pair[[2L]], base = base)
  })
}
.contract_classes <- c(
  .contract_family(
    DecompositionConfig,
    list(PCAConfig, "setup_PCA"),
    list(ICAConfig, "setup_ICA"),
    list(NMFConfig, "setup_NMF"),
    list(UMAPConfig, "setup_UMAP"),
    list(tSNEConfig, "setup_tSNE"),
    list(IsomapConfig, "setup_Isomap")
  ),
  .contract_family(
    ClusteringConfig,
    list(KMeansConfig, "setup_KMeans"),
    list(HardCLConfig, "setup_HardCL"),
    list(NeuralGasConfig, "setup_NeuralGas"),
    list(CMeansConfig, "setup_CMeans"),
    list(DBSCANConfig, "setup_DBSCAN"),
    list(GMMConfig, "setup_GMM"),
    list(HOPACHConfig, "setup_HOPACH"),
    list(PAMConfig, "setup_PAM"),
    list(PAMKConfig, "setup_PAMK"),
    list(SpectralRBFConfig, "setup_SpectralRBF"),
    list(SpectralLaplaceConfig, "setup_SpectralLaplace"),
    list(SpectralLocalConfig, "setup_SpectralLocal")
  ),
  .contract_family(
    DeviceConfig,
    list(CUDADeviceConfig, "setup_CUDA")
  ),
  .contract_family(
    PAMKCriterionConfig,
    list(ASWCriterionConfig, "setup_ASWCriterion"),
    list(CHCriterionConfig, "setup_CHCriterion"),
    list(MultiASWCriterionConfig, "setup_MultiASWCriterion")
  ),
  .contract_family(
    ResamplerConfig,
    list(KFoldConfig, "setup_KFold"),
    list(StratSubConfig, "setup_StratSub"),
    list(StratBootConfig, "setup_StratBoot"),
    list(BootstrapConfig, "setup_Bootstrap"),
    list(LOOCVConfig, "setup_LOOCV"),
    list(CustomConfig, "setup_Custom")
  ),
  .contract_family(TunerConfig, list(GridSearchConfig, "setup_GridSearch")),
  .contract_family(ExplanationConfig, list(SHAPConfig, "setup_SHAP")),
  .contract_family(
    ConformalConfig,
    list(SplitConformalConfig, "setup_SplitConformal"),
    list(CVPlusConfig, "setup_CVPlus"),
    list(CQRConfig, "setup_CQR")
  ),
  .contract_family(
    Hyperparameters,
    list(GLMHyperparameters, "setup_GLM"),
    list(GAMHyperparameters, "setup_GAM"),
    list(CARTHyperparameters, "setup_CART"),
    list(GLMNETHyperparameters, "setup_GLMNET"),
    list(GLMTreeHyperparameters, "setup_GLMTree"),
    list(LightCARTHyperparameters, "setup_LightCART"),
    list(LightRFHyperparameters, "setup_LightRF"),
    list(LightGBMHyperparameters, "setup_LightGBM"),
    list(LightRuleFitHyperparameters, "setup_LightRuleFit"),
    list(IsotonicHyperparameters, "setup_Isotonic"),
    list(LinearSVMHyperparameters, "setup_LinearSVM"),
    list(RadialSVMHyperparameters, "setup_RadialSVM"),
    list(MLPHyperparameters, "setup_MLP"),
    list(TabNetHyperparameters, "setup_TabNet"),
    list(RangerHyperparameters, "setup_Ranger"),
    list(SPLSHyperparameters, "setup_SPLS"),
    list(KNNHyperparameters, "setup_KNN"),
    list(MARSHyperparameters, "setup_MARS"),
    list(BARTHyperparameters, "setup_BART"),
    list(HALHyperparameters, "setup_HAL"),
    list(MonotonicHALHyperparameters, "setup_MonotonicHAL"),
    list(LINADHyperparameters, "setup_LINAD"),
    list(LINADForestHyperparameters, "setup_LINADForest"),
    list(NNLSHyperparameters, "setup_NNLS"),
    list(SuperLearnerHyperparameters, "setup_SuperLearner"),
    list(ModalityStackingHyperparameters, "setup_ModalityStacking"),
    list(
      ConditionalSuperLearnerHyperparameters,
      "setup_ConditionalSuperLearner"
    )
  ),
  .contract_family(
    IngestConfig,
    list(DelimitedIngestConfig, "setup_DelimitedIngest"),
    list(ParquetIngestConfig, "setup_ParquetIngest"),
    list(XLSXIngestConfig, "setup_XLSXIngest"),
    list(RDSIngestConfig, "setup_RDSIngest"),
    list(DTAIngestConfig, "setup_DTAIngest"),
    list(ARFFIngestConfig, "setup_ARFFIngest")
  ),
  .contract_family(
    PartitionConfig,
    list(RandomPartitionConfig, "setup_RandomPartition"),
    list(TimePartitionConfig, "setup_TimePartition"),
    list(GroupPartitionConfig, "setup_GroupPartition"),
    list(PredefinedPartitionConfig, "setup_PredefinedPartition")
  ),
  .contract_family(
    ExecutionConfig,
    list(SerialExecutionConfig, "setup_SerialExecution"),
    list(FutureExecutionConfig, "setup_FutureExecution"),
    list(MiraiExecutionConfig, "setup_MiraiExecution")
  ),
  .contract_family(
    NULL,
    list(PreprocessorConfig, "setup_Preprocessor"),
    list(SupervisedPreprocessorConfig, "setup_SupervisedPreprocessor"),
    list(SuperConfigPaths, "setup_SuperConfig"),
    list(DecomposeConfig, "setup_DecomposeConfig"),
    list(ClusterConfig, "setup_ClusterConfig"),
    list(NystromConfig, "setup_Nystrom")
  )
)
.contract_no_setup <- c(
  "Supervised",
  "Regression",
  "Classification",
  "SupervisedRes",
  "RegressionRes",
  "ClassificationRes",
  "Resampler",
  "Implementation",
  "VariableImportance",
  "Provenance",
  "DataFingerprint",
  "DataRef",
  "RegressionMetrics",
  "ClassificationMetrics",
  "ClusteringMetrics",
  "DecompositionMetrics",
  "RegressionMetricsRes",
  "ClassificationMetricsRes",
  "Diagnostic",
  "Diagnostics",
  "DataProfile"
)
.contract_by_name <- c(
  "CPUDeviceConfig",
  "MPSDeviceConfig",
  "OpenCLDeviceConfig"
)
.contract_no_schema <- "setup_SuperConfigLive"
.contract_deprecated <- "setup_Resampler"
.contract_schema <- function(entry, record = FALSE) {
  S7_to_JSONSchema(
    entry[["cls"]],
    id = paste0(
      "https://schema.rtemis.org/test/v1/",
      if (record) "record" else "schema",
      ".json"
    ),
    base = entry[["base"]],
    record = record
  )
}
.constant_props <- function(schema) {
  names(Filter(function(p) "const" %in% names(p), schema[["properties"]]))
}
.authored_props <- function(schema) {
  props <- schema[["properties"]]
  props <- Filter(function(p) !isTRUE(p[["readOnly"]]), props)
  setdiff(names(props), c("$schema", .constant_props(schema)))
}
.catalog_entries <- function(catalog) {
  c(
    unlist(lapply(catalog$families, `[[`, "algorithms"), recursive = FALSE),
    catalog$flat_configs
  )
}

# test -------------------------------------------------------------------------
env <- schema_catalog()
leaves <- unlist(
    lapply(env[["families"]], `[[`, "algorithms"),
    recursive = FALSE
  )
registered <- c(
    vapply(leaves, function(a) a[["cls"]]@name, character(1L)),
    vapply(env[["flat_configs"]], function(f) f[["cls"]]@name, character(1L))
  )
mapped <- vapply(
    .contract_classes,
    function(e) e[["cls"]]@name,
    character(1L)
  )
expect_identical(
    sort(setdiff(registered, c(mapped, .contract_no_setup, .contract_by_name))),
    character(),
    info = "registered but untested: add to .contract_classes"
  )
expect_identical(
    sort(setdiff(mapped, registered)),
    character(),
    info = "tested but no longer registered: drop from .contract_classes"
  )
for (family in env[["families"]]) {
    for (algo in family[["algorithms"]]) {
      entry <- Filter(
        function(e) identical(e[["cls"]]@name, algo[["cls"]]@name),
        .contract_classes
      )[[1L]]
      expect_identical(
        entry[["base"]]@name,
        family[["base_class"]]@name,
        info = algo[["cls"]]@name
      )
    }
  }
