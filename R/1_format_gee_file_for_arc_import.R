########################################################################### #
# 
# 1_format_gee_file_for_arc_import.R
#
# This helper module imports the csv files that result from running the script
# FRP_EVT in GEE. It reeformats column headings so they can be read in Arc. 
# Output files can be then processed via the python script 
# 
# intersect_frp_data_with_fire_perimeters.py
#
# Rbinding into a single file creates a world of trouble for Arc, hence the 
# multiple-file output.
#
# Input: home/jovyan/ca_frp/data/gee/maxFRP_CA_gte4sqkm_yyyy.csv
# Output: home/jovyan/ca_frp/data/gee/maxFRP_CA_gte4sqkm_yyyy_processed.csv
#
# To complete the next step (intersection of GEE files with vector fire data),
# outputting files with all 100+ EVT classes removed was necessary:
#
# Output2: maxFRP_CA_gte4sqkm_yyyy_processed_slim.csv 
#
#
########################################################################### #

library(dplyr)

# Set path info
path_in = "/home/jovyan/ca_frp/data/gee/"
filenames_in <- list.files(path_in, pattern = "*.csv")

# Process each file
for (filename_in in filenames_in) {
  
  x <- read.csv(file.path(path_in, filename_in), header = T)
  filename_sub <- substr(basename(filename_in), 1, nchar(basename(filename_in))-4)
  filename_out <- paste0(filename_sub, "_processed.csv")
  filename2_out <- paste0(filename_sub, "_processed_slim.csv")
  
  # rename first column for convenience
  colnames(x)[1] <- "index"
  
  # R slaps an "X" in front of numerical columns; switch it to "class"
  names_sub <- names(x)[which((substring(names(x), 1, 1) == "X"))]
  names(x)[which((substring(names(x), 1,1) == "X"))] <- paste0("class", substring(names_sub, 2))
  
  # get rid of dots
  names(x) <- gsub(".", "", names(x), fixed = TRUE)
  
  # drop geo column
  if ("geo" %in% names(x)) {
    x$geo <- NULL
  }
  
  # drop class9999 column
  if ("class9999" %in% names(x)) {
    x$class9999 <- NULL
  }
  
  # drop histogram column
  if ("histogram" %in% names(x)) {
    x$histogram <- NULL
  }
  
  # drop label column
  if ("label" %in% names(x)) {
    x$label <- NULL
  }
  
  # drop date column
  if ("date" %in% names(x)) {
    x$date <- NULL
  }
  
  # drop lonID column
  if ("lonID" %in% names(x)) {
    x$lonID <- NULL
  }
  
  # drop groups column
  if ("groups" %in% names(x)) {
    x$groups <- NULL
  }
  
  # drop 1st row, which is blank (1 exists for each file)
  x <- x[-1, ]
  
  # save output
  #write.csv(x, file = file.path(path_in, filename_out), row.names = FALSE)
  
  # remove EVT classes by dropping all 'class' columns
  x <- x %>% select(-contains('class'))
  
  #write.csv(x, file = file.path(path_in, filename2_out), row.names = FALSE)
}
