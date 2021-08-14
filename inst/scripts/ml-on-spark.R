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
    synthetic_data <- purrr::map_dfc(rep(n, m), rnorm)
    |> dplyr::rename_with(~ stringr::str_c("X", .x) |> stringr::str_remove_all("\\."))
    |> dplyr::rowwise()
    |> dplyr::mutate(y = sum(w * dplyr::c_across()))
    |> dplyr::ungroup()
    |> tibble::rowid_to_column("id")
)


# Export Dataset ----------------------------------------------------------
path_temp <- tempfile("spark-"); fs::dir_create(path_temp)
synthetic_data |> dplyr::select(id, dplyr::starts_with("X")) |> arrow::write_parquet(sink = file.path(path_temp, "X.parquet"))
synthetic_data |> dplyr::select(id, dplyr::starts_with("y")) |> arrow::write_parquet(sink = file.path(path_temp, "y.parquet"))


# Import data to Spark ----------------------------------------------------
tbl_spark_X <- sparklyr::spark_read_parquet(spark_conn, name = "X", file.path(path_temp, "X.parquet"))
tbl_spark_y <- sparklyr::spark_read_parquet(spark_conn, name = "y", file.path(path_temp, "y.parquet"))


# Join Databases ----------------------------------------------------------
tbl_spark <- dplyr::left_join(tbl_spark_X, tbl_spark_y, by = "id")
# object.size(tbl_spark) < object.size(synthetic_data)


# Teardown ----------------------------------------------------------------
unlink(path_temp)
sparklyr::spark_disconnect(sc = spark_conn)
