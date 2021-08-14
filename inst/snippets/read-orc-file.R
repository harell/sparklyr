# <https://cwiki.apache.org/confluence/display/hive/languagemanual+orc>
# Setup -------------------------------------------------------------------
options(java.parameters =  c("-XX:+UseConcMarkSweepGC", "-Xmx16g"))
gc()

(
    spark_cofig <- sparklyr::spark_config()
    |> purrr::list_modify(
        spark.executor.memory = '8g',
        spark.driver.memory = '18g',
        spark.memory.offHeap.enabled = TRUE,
        spark.memory.offHeap.size = '8g',
        spark.sql.shuffle.partitions.local = 64
    )
)

spark_conn <- sparklyr::spark_connect(master = 'local', config = spark_cofig)


# Import data -------------------------------------------------------------
file_path <- getwd()
file_name <- "000001_0"
orc_data <- spark_conn |> sparklyr::spark_read_orc(path = file.path(file_path, file_name))


# Teardown ----------------------------------------------------------------
sparklyr::spark_disconnect(sc = spark_conn)
