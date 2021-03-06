# utilities ---------------------------------------------------------------
line_break <- function() paste0("\n", paste0(rep("#", 80), collapse = ""))
banner <- function(title) paste0(line_break(), paste0("\n## ", title), line_break(), "\n", collapse = "")
read_lines <- function(path) paste(readLines(path), collapse = "\n")
