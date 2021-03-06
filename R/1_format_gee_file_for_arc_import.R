########################################################################### #
# 
# 1_format_gee_file_for_arc_import.R
#
# This module imports the csv files that result from running the script
# FRP_EVT in GEE. It reeformats column headings so they can be read in Arc. 
# Output files can be then processed via the python script 
# 
# intersect_frp_data_with_fire_perimeters.py
#
# Input files: home/jovyan/ca_frp/data/gee/maxFRP_CA_gte4sqkm_yyyy.csv
# Output files: home/jovyan/ca_frp/data/gee/maxFRP_CA_gte4sqkm_yyyy_processed.csv
#
# To complete the next step--intersecting GEE files with vector fire data via
# the python script--outputting files with all 100+ EVT classes removed was necessary:
#
# Output2: maxFRP_CA_gte4sqkm_yyyy_processed_slim.csv 
#
# A consolidated version of all slim files is ingested in the python script:
# Output3: maxFRP_CA_gte4sqkm_yyyytoyyyy_processed_slim.csv (hardcoded filename)
# 
########################################################################### #

library(dplyr)

# Set paths and files
path_in = "/home/jovyan/ca_frp"
path_data = file.path(path_in, "data")
filenames_in <- list.files(file.path(path_data, "gee"), pattern = "*.csv")
filename_out_slim_all <- "maxFRP_CA_gte4sqkm_20012to2020_processed_slim.csv"

# Process each file
for (filename_in in filenames_in) {
  
  x <- read.csv(file.path(path_data, "gee", filename_in), header = T)
  filename_sub <- substr(basename(filename_in), 1, nchar(basename(filename_in)) - 4)
  filename_out <- paste0(filename_sub, "_processed.csv")
  filename_out_slim <- paste0(filename_sub, "_processed_slim.csv")
  
  # rename first column for convenience
  colnames(x)[1] <- "index"
  
  # R slaps an "X" in front of numerical columns; switch it to "class"
  names_sub <- names(x)[which((substring(names(x), 1, 1) == "X"))]
  names(x)[which((substring(names(x), 1, 1) == "X"))] <- paste0("class", substring(names_sub, 2))
  
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
  write.csv(x, file = file.path(path_data, "gee", filename_out), row.names = FALSE)
  
  # Create "slim" file by dropping all EVT columns
  x <- x %>% select(-contains('class'))
  
  write.csv(x, file = file.path(path_data, "gee", filename_out_slim), row.names = FALSE)
}

# Merge all "slim" files into a single one that can be processed in Arc

setwd(file.path(path_data, "gee"))
mergedData <- 
  do.call(rbind,
          lapply(list.files(file.path(path_data, "gee"), pattern = "*slim.csv"), read.csv))

write.csv(mergedData, file = file.path(path_data, "gee", filename_out_slim_all), row.names = FALSE)


