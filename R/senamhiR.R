##' @title Download compiled data from the Peruvian National Hydrological and Meterological Service
##'
##' @description Download compiled Peruvian historical climate data from the Senamhi web portal.
##'
##' @param station character; the station id number to process. Can also be a vector of station ids, which will be returned as a list.
##' @param year numerical; a vector of years to process. Defaults to the full known range.
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

senamhiR <- function(station, year) {
  if (missing(station)) {
    station <- readline(prompt = "Enter station number(s) separated by commas: ")
    station <- trimws(unlist(strsplit(station, split = ",")))
  }
  
  if (any(nchar(station) < 6)) {
    station[nchar(station) < 6] <- suppressWarnings(
      try(sprintf("%06d", as.numeric(station[nchar(station) < 6])),
          silent = TRUE))
  }
  
  if (inherits(station, "try-error") || !station %in% catalogue$StationID) {
    stop("One or more requested stations invalid.")
  }
  
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
}
