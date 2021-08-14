#' @title Spark Utility Functions
#' @keywords internal
#' @export
#' @examples
#' ls(spark)
spark <- new.env()


# install -----------------------------------------------------------------
spark$install <- function(version = "2.3.0"){
    if(isFALSE(spark$is_installed(version))){
        if(identical(.Platform$OS.type, "windows")){
            eval(parse(text = "install.packages('installr')"))
            home_path <- file.path("C:", "Users", Sys.getenv("USERNAME"), "AppData", "Local", "spark", "8-MR3", "jdk-8")
            installr::install.java(version = "8-MR3", path = home_path)

            file_path <- file.path(".Renviron")
            if(isFALSE(file.exists(file_path))) file.create(file_path)
            write(paste0("JAVA_HOME", "=", file.path(home_path, "java-se-8u41-ri")), file_path, append = TRUE)
            readRenviron(file_path)
        }# end if windows

        sparklyr::spark_install(version)
    }# end if spark is installed

    invisible()
}


spark$install <- function(version = "2.3.0"){
    # windows | installed
    # windows | not installed
        if(identical(.Platform$OS.type, "windows")){
            if(isFALSE(spark$is_installed(version))){
            eval(parse(text = "install.packages('installr')"))
            home_path <- file.path("C:", "Users", Sys.getenv("USERNAME"), "AppData", "Local", "spark", "8-MR3", "jdk-8")
            installr::install.java(version = "8-MR3", path = home_path)
            Sys.setenv(JAVA_HOME = file.path(home_path, "java-se-8u41-ri"))
        }# end if spark is installed

        sparklyr::spark_install(version)
    }# end if windows

    invisible()
}


# is_installed ------------------------------------------------------------
spark$is_installed <- function(version){
    spark_versions <- sparklyr::spark_installed_versions()[[1]]
    if(identical(spark_versions, character(0))){
        return(FALSE)
    } else if(missing(version)){
        return(TRUE)
    } else {
        return(version %in% spark_versions)
    }
}


