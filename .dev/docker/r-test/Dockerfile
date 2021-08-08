# R Package Development: Core --------------------------------------------------
FROM tidylab/package:4.2.0

# Install Spark ----------------------------------------------------------------
# https://spark.rstudio.com/examples/stand-alone-aws/
# RUN R -q -e "install_cran('sparklyr', dependencies = TRUE)"
ARG SPARK_VERSION=2.4.0
ARG HADOOP_VERSION=2.7
#RUN R -q -e "print(Sys.getenv('SPARK_VERSION'))"
#RUN R -q -e "sparklyr::spark_install(Sys.getenv('SPARK_VERSION'), Sys.getenv('HADOOP_VERSION'), verbose = TRUE)"
#RUN R -q -e "if(!identical(sparklyr::spark_installed_versions()[[1]], Sys.getenv('SPARK_VERSION'))) sparklyr::spark_install(version = Sys.getenv('SPARK_VERSION'))"

# Install Project Dependencies -------------------------------------------------
COPY ./DESCRIPTION ./DESCRIPTION
RUN R -q -e "install_deps(dependencies = 'Depends')"
RUN R -q -e "install_deps(dependencies = 'Imports')"
RUN R -q -e "install_deps(dependencies = 'Suggests')"

# R Package Development: Testing------------------------------------------------
RUN touch .Renviron .Rprofile
RUN echo "" > .Rprofile

# Prepare Package Files --------------------------------------------------------
ARG R_USER=./home/rstudio/
ARG R_PACKAGE_NAME=rproject
COPY . ${R_USER}/${R_PACKAGE_NAME}
RUN cp .Rprofile ${R_USER}/${R_PACKAGE_NAME}
RUN cp .env ${R_USER}/.Renviron
WORKDIR ${R_USER}/${R_PACKAGE_NAME}

# Test-Suite -------------------------------------------------------------------
RUN R -q -e "system.time(devtools::document())"
RUN R -q -e "system.time(devtools::check(error_on = 'note'))"
RUN R -q -e "system.time(testthat::test_package(read.dcf('DESCRIPTION', 'Package')[[1]]))"

# Teardown ---------------------------------------------------------------------
ENTRYPOINT /bin/bash
