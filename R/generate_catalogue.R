##' @title A function to determine the full catalogue of available Peruvian National Hydrological and Meterological Service stations
##'
##' @description Generate a .rda file containing a list of all of the stations operated by Senamhi. You should not need to execute this function, as the data is already included in the package.
##'
##' @return catalogue.rda
##' 
##' @keywords internal
##' 
##' @author Conor I. Anderson
##'
##' @importFrom XML htmlTreeParse

.generate_catalogue <- function() {
  
  vector <- seq(1, 25, by = 1)
  vector <- vector[-7]
  vector <- sprintf("%02d", vector)
  urlList <- paste0("http://www.senamhi.gob.pe/include_mapas/_map_data_hist03.php?drEsta=", 
    vector)
  
  Sys.setlocale(category = "LC_ALL", locale = "C")
  catalogue = NULL
  dir <- tempdir()
  
  for (i in 1:length(vector)) {
    .download_action(url = urlList[i], filename = paste0(dir, "/", vector[i], 
      ".html"))
    data <- htmlTreeParse(paste0(dir, "/", vector[i], ".html"))
    data <- unlist(data[3])
    data <- data[21]
    data <- strsplit(data, "var ubica")[[1]]
    j <- 2
    while (j <= length(data)) {
      row <- strsplit(data[j], ",")[[1]]
      name <- strsplit(row[3], " - ")[[1]]
      ## There are a couple of cases where the station name is formatted with a spaced
      ## hyphen
      if (length(name) == 3) 
        name <- c(paste(name[1:2], collapse = " - "), name[3])
      name <- gsub("'", "", name)
      station <- as.character(name[2])
      period <- try(.guess_period(station))
      if (!inherits(period, "try-error")) {
        start <- period[1]
        end <- period[2]
      } else {
        start <- NA
        end <- NA
      }
      config <- try(.guess_config(station))
      if (!inherits(config, "try-error")) {
        type <- config[1]
        config <- config[2]
      } else {
        type <- NA
        config <- NA
      }
      row <- c(name, type, config, start, end, row[13], row[6:10])
      
      ## Commands to clean up the data
      row <- gsub("Ñ", "N", row)
      row <- gsub("\xd1", "N", row)
      row <- gsub("'", "", row)
      row <- gsub("\\\\", "", row)
      row <- gsub("));", "", row)
      row <- gsub("}\r\n}", "", row)
      row <- gsub("^\\s+|\\s+$", "", row)
      # Set station status
      if (row[7] == "C" | row[7] == "P") 
        row[7] <- "closed"
      if (row[7] == "F") 
        row[7] <- "working"
      # Convert lat/long to decimal degrees
      latitude <- as.numeric(unlist(strsplit(row[8], split = " ")))
      latitude <- -(latitude[1] + (latitude[2]/60) + (latitude[3]/3600))
      row[8] <- latitude
      longitude <- as.numeric(unlist(strsplit(row[9], split = " ")))
      longitude <- -(longitude[1] + (longitude[2]/60) + (longitude[3]/3600))
      row[9] <- longitude
      # Add it to the catalogue
      catalogue <- rbind(catalogue, row)
      j <- j + 1
    }
    i <- i + 1
    colnames(catalogue) <- c("Station", "StationID", "Type", "Configuration", 
      "Data Start", "Data End", "Station Status", "Latitude", "Longitude", 
      "Region", "Province", "District")
  }
  rownames(catalogue) <- NULL
  catalogue <- as.data.frame(catalogue, stringsAsFactors = FALSE)
  catalogue$Latitude <- as.numeric(catalogue$Latitude)
  catalogue$Longitude <- as.numeric(catalogue$Longitude)
  comment(catalogue) <- "Note: The Senamhi database detailing available historical information has not been updated since 2010, as such, any station with data available until 2010 is assumed to be current, and has been marked as having data until 2015. Actual data availability may vary for these stations. Especially for closed stations."
  save(catalogue, file = "catalogue.rda")
  return("Catalogue saved as catalogue.rda")
}


