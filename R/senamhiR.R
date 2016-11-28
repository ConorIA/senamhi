##' @title Download and/or compile data from the Peruvian National Hydrological and Meterological Service
##'
##' @description Download and/or compile Peruvian historical climate data from the Senamhi web portal.
##'
##' @param tasks numerical; define which tasks to perform: 1) Download Data, 2) Compile CSV of Downloaded Data, 3) Both.
##' @param station character; the station id number to process. Can also be a vector of station ids.
##' @param year numerical; a vector of years to process. Defaults to the full known range.
##' @param month numerical; a vector of months to process. Defaults to 1:12.
##' @param fallback vector; if no year is specified, and the period of available data is unknown, this vector will provide a fallback start and end year to download. If not specified, such stations will be skipped.
##' @param write_mode character; if set to 'append', the script will append the data to an exisiting file; if set to 'overwrite', it will overwrite an existing file. If not set, it will not overwrite.
##'
##' @author Conor I. Anderson
##' 
##' @export
##' 
##' @examples
##' \dontrun{senamhiR(3, '000401', 1998:2015)}
##' \dontrun{senamhiR(3, c('000401', '000152', '000219'), fallback = c(1961,1990))}

senamhiR <- function(tasks, station, year, month = 1:12, fallback, write_mode = "z") {
  if (missing(tasks)) 
    tasks <- readline(prompt = "1) Download Data, 2) Compile CSV of Downloaded Data, 3) Both: ")
  while (tasks != 1 && tasks != 2 && tasks != 3) {
    print("Please choose the series of command you wish to run.")
    tasks <- readline(prompt = "1) Download Data, 2) Compile CSV of Downloaded Data, 3) Both: ")
  }
  if (missing(station)) {
    station <- readline(prompt = "Enter station number(s) separated by commas: ")
    station <- trimws(unlist(strsplit(station, split = ",")))
  }
  
  ## Add a work-around to download multiple stations
  if (length(station) > 1) {
    lapply(station, senamhiR, tasks = tasks, year = year, month = month, fallback = fallback, 
      write_mode = write_mode)
    return("Bulk action completed.")
  }
  
  ## Choose range of years
  if (missing(year)) {
    station_data <- catalogue[catalogue$StationID == station, ]
    if (is.na(station_data$`Data Start`) || is.na(station_data$`Data End`)) {
      if (missing(fallback)) {
        print("Available data undefined and no fallback specified. Skipping this station.")
        return("No period defined.")
      }
      print(paste("Available data undefined. Using fallback from", fallback[1], "to", fallback[length(fallback)]))
      year <- fallback[1]:fallback[length(fallback)]
    } else {
      if (station_data$`Data End` == "2010+") {
        print(paste("Not sure when data period ends. We will try until", 
          (as.numeric(format(Sys.Date(), format = "%Y")) - 1)))
        endYear <- as.numeric(format(Sys.Date(), format = "%Y")) - 1
      } else {
        endYear <- station_data$`Data End`
      }
      year <- station_data$`Data Start`:endYear
    }
  }
  print(paste0("Processing station ", station, "."))
  if (tasks == 1 || tasks == 3) {
    download_data(station = station, year = year, month = month)
  }
  if (tasks == 2 || tasks == 3) {
    write_data(station = station, year = year, write_mode = write_mode)
  }
}
