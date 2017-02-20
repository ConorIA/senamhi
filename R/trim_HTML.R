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

  station_data <- catalogue[catalogue$StationID == station, ]
  stationName <- station_data$Station
  region <- station_data$Region

  newwd <- file.path(oldwd, region, "HTML", paste(station, "-", stationName))
  setwd(newwd)

  files <- dir()
  # data.frame(Files = files, Size = file.size(files))

  first_index <- min(which(file.size(files) > 3037))
  first_year <- substring(files[first_index], 1, 4)
  
  while (first_index == 1) {
    print("Looks like out first HTML file is good! Let's try for an extra year")
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
    print("Looks like out last HTML file is good! Let's try for an extra year")
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
  } else {
    unlink(files[files_year < first_year | files_year > last_year])
  }
  setwd(oldwd)
}