# Setup -------------------------------------------------------------------
pkgload::load_all()
spark$install(version = "2.4.4")
spark_conn <- sparklyr::spark_connect(master = 'local')


# Generate Synthetic Data -------------------------------------------------
set.seed(1159)
n <- 1e4
m <- 4
w <- runif(m, -0.5, 0.5)
suppressMessages(
    dummy_data <- purrr::map_dfc(rep(n, m), rnorm)
    |> dplyr::rename_with(~ stringr::str_c("X", .x) |> stringr::str_remove_all("\\."))
    |> dplyr::rowwise()
    |> dplyr::mutate(y = sum(w * dplyr::c_across()))
    |> dplyr::ungroup()
)


# Working with parquet files ----------------------------------------------
path_temp <- tempfile("spark-"); fs::dir_create(path_temp)
system.time(readr::write_csv(dummy_data, file.path(path_temp, "data.csv")))         # 0.12 sec
system.time(arrow::write_dataset(dummy_data, file.path(path_temp, "data.parquet"))) # 0.01 sec

path_temp |> file.path("data.csv") |> fs::file_size()                       # 962K
path_temp |> file.path("data.parquet", "part-0.parquet") |> fs::file_size() # 705K

# # Copying data into Spark -------------------------------------------------
# dataset_names <- data(package = "nycflights13") |> purrr::pluck("results") |> dplyr::as_tibble() |> dplyr::pull("Item")
# for(dataset_name in dataset_names) dplyr::copy_to(
#     dest = spark_conn,
#     df = eval(parse(text = paste0("nycflights13::", dataset_name))),
#     name = dataset_name,
#     overwrite = TRUE
# )
#
#
# # Exploring Spark data types ----------------------------------------------
# (
#     schema <- dplyr::tbl(spark_conn, "flights")
#     |> sparklyr::sdf_schema()
#     |> dplyr::bind_rows()
# )
#
#
# # Transforming continuous variables to logical ----------------------------
# (
#     flights <- dplyr::tbl(spark_conn, "flights")
#

# Teardown ----------------------------------------------------------------
unlink(path_temp)
sparklyr::spark_disconnect(sc = spark_conn)
