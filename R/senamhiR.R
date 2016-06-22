##' @title A wrapper function to download and compile data from the Peruvian National Hydrological and Meterological Service
##'
##' @description Download and/or compile Peruvian historical climate data from the Senamhi web portal.
##'
##' @param tasks numerical; define which tasks to perform: 1) Download Data, 2) Compile CSV of Downloaded Data, 3) Both.
##' @param station character; the number of the station id number to process. Can also be a vector of station ids.
##' @param automatic logical; if set to true (default), the script will attempt to guess the type and config values as well as startYear and endYear
##' @param dataAvail logical; if set to true (default), the script will either automatically attempt to choose start and end datas, or return a(n outdated) table of the data available for your station.
##' @param fallback vector; if dataAvail is used, this vector will provide a fallback start and end year to download if the auto find fails.
##' @param type character; defines if the station is (CON)ventional, DAV, (SUT)ron, or (SIA)p. Must be "CON", "DAV", "SUT" or "SIA".
##' @param config character; defines if the station is (M)eterological (2) or (H)ydrological. Must be "M", "M1", "M2" or "H".
##' @param startYear numerical; the first year to process.
##' @param endYear numerical; the last year to process.
##' @param startMonth numerical; the first month to process. Defaults to 1.
##' @param endMonth numerical; the last month to process. Defaults to 12.
##' @param overwrite logical; if true, the script will overwrite downloaded files and compiled csv files if they exist.
##' @param append logical; if true, the script will append the data to an exisiting file, otherwise it will overwrite.
##' @param custom logical; if true, the script will provide the opportunity to manually enter column headers.
##'
##' @return None
##'
##' @author Conor I. Anderson
##' 
##' @export
##' 
##' @examples
##' \dontrun{senamhiR(3, "000401", startYear = 1998, endYear = 2015)}
##' \dontrun{senamhiR(3, c("000401", "000152", "000219"), fallback = c(1961,1990))}

senamhiR <- function(tasks, station, automatic = TRUE, dataAvail = TRUE, fallback = NULL, type = "z", config = "z", startYear, endYear, startMonth = 1, endMonth = 12,
                    overwrite = FALSE, append = FALSE, custom = FALSE) {

    if (missing(tasks)) {
      print("Please choose the series of command you wish to run.")
      tasks <- readline(prompt = "1) Download Data, 2) Compile CSV of Downloaded Data, 3) Both: ")
    }
    if (missing(station))
      station <- readline(prompt = "Enter station number: ")
    
    ##Add a work-around to download multiple stations
    if (length(station) > 1) {
      lapply(station, senamhiR, tasks = tasks, automatic, dataAvail = dataAvail, fallback = fallback, type = type, config = config, startYear = startYear, endYear = endYear, startMonth = startMonth, endMonth = endMonth,
                                    overwrite = overwrite, append = append, custom = custom)
      return("Batch jobs completed")
    }
    
    ## Input Station Characteristics for single stations
    if (automatic == TRUE) {
      guess <- guessConfig(station, overwrite)
      type <- guess[1]
      config <- guess[2]
      if (guess[1] == "ERROR" | guess[2] == "ERROR") print("Something went wrong. Please enter manually")
    }
    while (!(type == "CON" | type == "DAV" | type == "SIA" | type == "SUT"))
      type <- readline(prompt = "Must be one of CON, DAV, SUT, or SIA: ")
    while (!(config == "M" |config == "M1" | config == "M2" | config == "H"))
      config <- readline(prompt = "Must be one of M, M1, M2 or H: ")

    ## Choose Data Range
    if (dataAvail == TRUE & (missing(startYear) | missing(endYear))) {
      result <- try(guessPeriod(station, automatic, overwrite))
      if (!inherits(result, "try-error")) {
        if (automatic == TRUE) {
          startYear <- result[1]
          endYear <- result[2]
        } else {
          print("The following data is available.")
          print(result)
        }
      } else {
        if (length(fallback) == 2) {
          print("Using fallback dates")
          startYear <- fallback[1]
          endYear <- fallback[2]
        }
      }
    }
    if (missing(startYear))
      startYear <- as.integer(readline(prompt = "Enter start year: "))
    if (missing(endYear))
      endYear <- as.integer(readline(prompt = "Enter end year: "))
    
    if (tasks == 1) {
      downloadData(station, type, config, startYear, endYear, startMonth, endMonth)
    } else {
      if (tasks == 2) {
        writeCSV(station, type, config, startYear, endYear, startMonth, endMonth)
      } else {
        if (tasks == 3) {
          downloadData(station, type, config, startYear, endYear, startMonth, endMonth, overwrite)
          writeCSV(station, type, config, startYear, endYear, startMonth, endMonth, overwrite, custom, append)
        } else
          print("Please choose an option between 1 and 3")
      }
    }
  }
