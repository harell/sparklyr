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

