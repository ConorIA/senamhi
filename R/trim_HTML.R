##' @title HTML file trimmer
##' 
##' @description A helper function to trim HTML files for years with missing data.
##'
##' @param station character; the StationID of the station to process.
##' 
##' @keywords internal
##'
##' @author Conor I. Anderson

.trim_HTML <- function(station, interactive = TRUE) {

  oldwd <- getwd()
  
  cat_index <- which(catalogue$StationID == station)

  station_data <- catalogue[cat_index, ]
  stationName <- station_data$Station
  region <- station_data$Region

  newwd <- file.path(oldwd, region, "HTML", paste(station, "-", stationName))
  setwd(newwd)

  files <- dir()
  # data.frame(Files = files, Size = file.size(files))

  first_index <- min(which(file.size(files) > 3037))
  if (length(first_index) == 0) {
    print("Uhh ohh, it looks like there is no good data here.")
    if (interactive == TRUE) {
      go <- readline(prompt = "Should we blow the station away? (y/N)")
      if (go == "y" | go == "Y") unlink(files)
      go <- readline(prompt = "Should we update the catalogue? (y/N)")
      if (go == "y" | go == "Y") catalogue$`Data Start`[cat_index] <- "NONE"; catalogue$`Data End`[cat_index] <- "NONE" 
    } else {
      if (go == "y" | go == "Y") unlink(files)
      catalogue$`Data Start`[cat_index] <- "NONE"; catalogue$`Data End`[cat_index] <- "NONE" 
    }
  }
  first_year <- substring(files[first_index], 1, 4)
  
  while (first_index == 1) {
    print("Looks like our first HTML file is good! Let's try for an extra year")
    setwd(oldwd)
    senamhiR(1, station, year = (as.numeric(first_year)-1))
    setwd(newwd)
    files <- dir()
    first_index <- min(which(file.size(files) > 3037))
    first_year <- substring(files[first_index], 1, 4)
  }

  last_index <-max(which(file.size(files) > 3037))
  last_year <- substring(files[last_index], 1, 4)
  while (last_index == length(files) && last_year != (format(Sys.Date(), format = "%Y")) - 1) {
    print("Looks like our last HTML file is good! Let's try for an extra year")
    setwd(oldwd)
    senamhiR(1, station, year = (as.numeric(last_year) + 1))
    setwd(newwd)
    files <- dir()
    files_year <- substring(files, 1, 4)
    last_index <- max(which(file.size(files) > 3037))
    last_year <- substring(files[last_index], 1, 4)
  }
  print(paste0("We have data from ", first_year, " to ", last_year, "."))
  print("We are doing to blow away the following files.")
  data.frame(Files = files[files_year < first_year | files_year > last_year], Size = file.size(files[files_year < first_year | files_year > last_year]))
  if (interactive == TRUE) {
    go <- readline(prompt = "Should we go ahead? (y/N)")
    if (go == "y" | go == "Y") unlink(files[files_year < first_year | files_year > last_year])
    go <- readline(prompt = "Should we update the catalogue? (y/N)")
    if (go == "y" | go == "Y") catalogue$`Data Start`[cat_index] <- first_year; catalogue$`Data End`[cat_index] <- last_year 
  } else {
    unlink(files[files_year < first_year | files_year > last_year])
    catalogue$`Data Start`[cat_index] <- first_year; catalogue$`Data End`[cat_index] <- last_year 
  }
  setwd(oldwd)
}