# <https://spark.rstudio.com/dplyr/>
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
tbl_spark <- dplyr::tbl(spark_conn, "flights")


# Data Preprocessing ------------------------------------------------------
tbl_spark <- dplyr::tbl(spark_conn, "flights")

## Selecting unique rows
tbl_spark |> dplyr::select(carrier) |> dplyr::distinct()

## Displays the (multivariate) frequency distribution of the variables
(
    tbl_spark
    |> dplyr::count(carrier, sort = TRUE, name = "frequency")
    |> dplyr::slice_max(order_by = frequency, n = 5)
)


# Collecting data back from Spark -----------------------------------------
results <- dplyr::filter(tbl_spark, arr_delay == 0)
class(results)

# Collect the results
collected <- results %>% dplyr::collect()
class(collected)


# Storing intermediate results --------------------------------------------
## Compute the results
tbl_interm <- tbl_spark |> dplyr::filter(arr_delay == 0) |> dplyr::compute("intermediate_results")
class(tbl_interm)

## See the available datasets
dplyr::src_tbls(spark_conn)


# Using SQL query ---------------------------------------------------------
# Write SQL query
query <- "SELECT * FROM flights WHERE arr_delay = 0"

# Run the query
results <- DBI::dbGetQuery(spark_conn, query)
class(results)


# Joins -------------------------------------------------------------------
tbl_joined <- dplyr::left_join(
    dplyr::tbl(spark_conn, "flights"),
    dplyr::tbl(spark_conn, "airlines"),
    by = "carrier"
)
dim(tbl_joined)


# Teardown ----------------------------------------------------------------
sparklyr::spark_disconnect(sc = spark_conn)

