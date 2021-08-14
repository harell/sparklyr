# Setup -------------------------------------------------------------------
pkgload::load_all()
Sys.setenv(SPARK_HOME = sparklyr::spark_home_dir())

sc <- sparklyr::spark_connect(
    master = "http://localhost:8998",
    method = "livy",
    version = "2.4.4"
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




