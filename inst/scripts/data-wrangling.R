# Setup -------------------------------------------------------------------
pkgload::load_all()
spark$install(version = "2.4.0")
spark_conn <- sparklyr::spark_connect(
    master = 'local',
    config = sparklyr::spark_config(file.path(".", "inst", "configurations", "spark.yml"))
)
on.exit(sparklyr::spark_disconnect(sc = spark_conn))


# Copying data into Spark -------------------------------------------------
## Copy mtcars to Spark
tbl_spark <- dplyr::copy_to(spark_conn, mtcars, overwrite = TRUE)

## List the data frames available in Spark
dplyr::src_tbls(spark_conn)


# Measure object size and dimensions: Large in Spark, Small in R session --
## See how big the dataset is
dim(tbl_spark)

## See how small the tibble is
format(object.size(tbl_spark), units = "MB")


# Exploring the structure of tibbles --------------------------------------
# Print 5 rows, all columns
print(tbl_spark, n = 5, width = Inf)

# Examine structure of tibble
str(tbl_spark)

# Examine structure of data
dplyr::glimpse(tbl_spark)


# Selecting columns -------------------------------------------------------


