# Setup -------------------------------------------------------------------
pkgload::load_all()
spark$install(version = "2.4.0")


# Basic commands ----------------------------------------------------------
# Connect to your Spark cluster
spark_conn <- sparklyr::spark_connect(
    master = 'local',
    config = sparklyr::spark_config(file.path(".", "inst", "configurations", "spark.yml"))
)

# Print the version of Spark
sparklyr::spark_version(sc = spark_conn)

# Disconnect from Spark
sparklyr::spark_disconnect(sc = spark_conn)
