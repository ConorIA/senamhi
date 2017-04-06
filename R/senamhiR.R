##' @title Download compiled data from the Peruvian National Hydrological and Meterological Service
##'
##' @description Download compiled Peruvian historical climate data from the Senamhi web portal.
##'
##' @param station character; the station id number to process. Can also be a vector of station ids, which will be returned as a list.
##' @param year numerical; a vector of years to process. Defaults to the full known range.
##' @param tasks [DEPRECATED] numerical; define which tasks to perform: 1) Download Data, 2) Compile CSV of Downloaded Data, 3) Both.
##' @param fallback [DEPRECATED] vector; if no year is specified, and the period of available data is unknown, this vector will provide a fallback start and end year to download. If not specified, such stations will be skipped.
##' @param write_mode [DEPRECATED] character; if set to 'append', the script will append the data to an exisiting file; if set to 'overwrite', it will overwrite an existing file. If not set, it will not overwrite.
##'
##' @author Conor I. Anderson
##' 
##' @importFrom tibble tibble
##' 
##' @export
##' 
##' @examples
##' \dontrun{senamhiR('000401', 1998:2015)}
##' \dontrun{senamhiR(c('000401', '000152', '000219'))}

senamhiR <- function(station, year, tasks, fallback, write_mode = "z") {
  if (missing(station)) {
    station <- readline(prompt = "Enter station number(s) separated by commas: ")
    station <- trimws(unlist(strsplit(station, split = ",")))
  }
  
  # If tasks is not specified (good), use MySQL
  if (missing(tasks)) {
    dataout <- list()
    for (stn in station) {
      if (missing(year)) year <- 1900:2100
      temp <- download_data_sql(stn, year)
      dataout <- c(dataout, list(temp))
    }
    if (length(station) == 1) {
      return(dataout[[1]])
    } else {
      return(dataout)
    }
    
  } else {
    # Use deprecated methods
    if (length(station) > 1) {
      lapply(station, senamhiR, year = year, tasks = tasks, fallback = fallback, 
             write_mode = write_mode)
      return("Bulk action completed.")
    }
    if (missing(year)) .guess_year(stn, fallback)
    print(paste0("Processing station ", station, "."))
    if (tasks == 1 || tasks == 3) {
      download_data(station = station, year = year)
    }
    if (tasks == 2 || tasks == 3) {
      write_data(station = station, year = year, write_mode = write_mode)
    }
  }
}
