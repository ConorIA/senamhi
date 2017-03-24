##' @title Read data from the Peruvian National Hydrological and Meterological Service
##'
##' @description Read a CSV file of Peruvian historical climate data from the Senamhi web portal.
##'
##' @param station character; the station id number to process.
##' @param path character; the path to the file. By default, the script expects the csv files to be sorted by region. 
##'
##' @return A tibble (tbl_df) of the relative information.
##'
##' @author Conor I. Anderson
##'
##' @importFrom tibble has_name
##' @importFrom readr read_csv
##'
##' @export
##'
##' @examples
##' \dontrun{read_data('000401')}

read_data <- function(station, path = "default") {
  
  ## Fail if we try to read multiple stations
  if (length(station) > 1) {
    stop("Sorry, for now I can only read a single station at a time.")
  }
  
  row <- grep(station, catalogue$StationID)
  if (length(row) != 1) {
    stop("I could not identify the station. Please check the station number and try again.")
  }
  
  if (path == "default") {
    folder <- paste0(catalogue$Region[row], "/")
  } else {
    folder <- if (path == "") "." else path
  }
  
  filename <- paste0(folder, "/", station, " - ", catalogue$Station[row], ".csv")
  if (!file.exists(filename)) {
    stop("I can't find a csv file for that station. Please use the `export_data()` function to create it.")
  }
  
  # Generate the column types
  if (catalogue$Configuration[row] == "H") {
    if (catalogue$Type[row] == "CON") 
      types <- "Dddddd"
    if (catalogue$Type[row] == "SUT") 
      types <- "Dddddddccd"
  } else {
    if (catalogue$Type[row] == "CON") 
      types <- "Ddddddddddddcc"
    if (catalogue$Type[row] == "SUT" | catalogue$Type[row] == "SIA" | catalogue$Type[row] == "DAV") 
      types <- "Dddddddcc"
  }
  
  # Read the .csv file 
  dat  <- try(read_csv(filename, col_types = types))
  if (inherits(dat, "try-error")) {
    return("I could not read the file. Please ensure that it exists and that you have the right permissions.")
  }
  
  # Fix the "Volocidad del Viento" column, which is sometimes numeric and sometimes integer (avoid false precision)
  if (has_name(dat, "Velocidad del Viento (m/s)")) {
    if (length(grep(".", dat$`Velocidad del Viento (m/s)`, fixed = TRUE)) > 0) {
      dat$`Velocidad del Viento (m/s)` <- as.double(dat$`Velocidad del Viento (m/s)`)
    } else {
      dat$`Velocidad del Viento (m/s)` <- as.integer(dat$`Velocidad del Viento (m/s)`)
    }
  }
  
  return(dat)
}