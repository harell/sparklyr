# Setup -------------------------------------------------------------------
pkgload::load_all()
spark$install(version = "2.4.4")

conf <- sparklyr::spark_config()
conf$spark.executor.memory <- "300M"
conf$spark.executor.cores <- 2
conf$spark.executor.instances <- 3
conf$spark.dynamicAllocation.enabled <- "false"

Sys.setenv(SPARK_HOME = sparklyr::spark_home_dir())
Sys.setenv(YARN_CONF_DIR = file.path(".", "inst", "configurations"))

spark_conn <- sparklyr::spark_connect(
    master = c("yarn-cluster", "yarn")[2],
    version = "2.4.4",
    config = conf
)

# Copying data into Spark -------------------------------------------------
dataset_names <- data(package = "nycflights13") |> purrr::pluck("results") |> dplyr::as_tibble() |> dplyr::pull("Item")
for(dataset_name in dataset_names) dplyr::copy_to(
    dest = spark_conn,
    df = eval(parse(text = paste0("nycflights13::", dataset_name))),
    name = dataset_name,
    overwrite = TRUE
)
dplyr::src_tbls(spark_conn)


# Teardown ----------------------------------------------------------------
sparklyr::spark_disconnect(sc = spark_conn)




