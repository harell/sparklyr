#' sparklyr has two "native" interfaces. Native means that they call Java or
#' Scala code to access Spark libraries directly, without any conversion to SQL.
#'
#' * sparklyr supports the Spark DataFrame API with functions that have an
#' sdf_prefix.
#'
#' * It also supports access to Spark's machine learning library, MLlib, with
#' "feature transformation" functions that begin ft_, and "machine learning"
#' functions that begin ml_
#'
#' NOTE:
#' * Most Spark MLlib modeling functions require DoubleType inputs and return
#' DoubleType outputs.
#' * it is up to the you to convert logical or integer data into numeric data
#' and back again.
#'
# Setup -------------------------------------------------------------------
pkgload::load_all()
spark$install(version = "2.4.4")
spark_conn <- sparklyr::spark_connect(
    master = 'local',
    config = sparklyr::spark_config(file.path(".", "inst", "configurations", "spark.yml"))
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


# Transforming continuous variables to logical ----------------------------
(
    flights <- dplyr::tbl(spark_conn, "flights")
    # Binarise arr_delay to was_delayed
    |> sparklyr::ft_binarizer("arr_delay", "was_delayed", 0)
    # Retrieve a subsample that includes the newest data
    |> dplyr::slice_max(order_by = time_hour, n = 5)
    # Collect the result
    |> dplyr::collect()
    # Convert was_delayed to logical
    |> dplyr::mutate(was_delayed = as.logical(was_delayed))
    # Focus on the amended columns
    |> dplyr::select(arr_delay, was_delayed)
)


# Transforming continuous variables into categorical ----------------------
(
    flights <- dplyr::tbl(spark_conn, "flights")
    # Bucketize month to quarter using splits vector
    # |   Q0  |   Q1  |   Q2  |     Q3   |
    # 0 ------4-------7-------10---------13
    # | 1,2,3 | 4,5,6 | 7,8,9 | 10,11,12 |
    |> sparklyr::ft_bucketizer("month", "quarter", c(0,4,7,10,13))
    # Collect the result
    |> dplyr::collect()
    # Convert decade to factor using decade_labels
    |> dplyr::mutate(quarter = ordered(quarter, levels = 0:3, labels = 1:4))
    # Focus on the amended columns
    |> dplyr::select(month, quarter)
    |> dplyr::arrange(month)
)



# Teardown ----------------------------------------------------------------
sparklyr::spark_disconnect(sc = spark_conn)




