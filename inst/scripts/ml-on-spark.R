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
)


# Export Dataset ----------------------------------------------------------
path_temp <- tempfile("spark-"); fs::dir_create(path_temp)
arrow::write_parquet(x = synthetic_data, sink = file.path(path_temp, "data.parquet"))


# Import data to Spark ----------------------------------------------------
tbl_spark <- sparklyr::spark_read_parquet(spark_conn, name = "SYNTETIC_DATA", path_temp)


# Teardown ----------------------------------------------------------------
unlink(path_temp)
sparklyr::spark_disconnect(sc = spark_conn)
