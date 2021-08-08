# remotes::install_github("cran/SparkR@3.1.2")
pkgload::load_all()

# a <- sparklyr::spark_session(spark_conn)
#
# dplyr::src_tbls(spark_conn)
#
sparklyr::connection_is_open(spark_conn)
#
#
#
# sparklyr::spark_disconnect(sc = spark_conn)
sparklyr::spark_session(spark_conn)
