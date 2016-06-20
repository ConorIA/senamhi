##' @title A wrapper function to download and compile data from the Peruvian National Hydrological and Meterological Service
##'
##' @description Download and/or compile Peruvian historical climate data from the Senamhi web portal.
##'
##' @param tasks numerical; define which tasks to perform: 1) Download Data, 2) Compile CSV of Downloaded Data, 3) Both.
##' @param station character; the number of the station id number to process. Can also be a vector of station ids.
##' @param automatic logical; if set to true (default), the script will attempt to guess the type and MorH values as well as startYear and endYear
##' @param dataAvail logical; if set to true (default), the script will either automatically attempt to choose start and end datas, or return a(n outdated) table of the data available for your station.
##' @param type character; defines if the station is (CON)ventional, DAV, (SUT)ron, or (SIA)p. Must be "CON", "DAV", "SUT" or "SIA".
##' @param MorH character; defines if the station is (M)eterological (2) or (H)ydrological. Must be "M", "M2" or "H".
##' @param startYear numerical; the first year to process.
##' @param endYear numerical; the last year to process.
##' @param startMonth numerical; the first month to process. Defaults to 1.
##' @param endMonth numerical; the last month to process. Defaults to 12.
##' @param overwrite logical; if true, the script will overwrite downloaded files if they exist.
##' @param append logical; if true, the script will append the data to an exisiting file, otherwise it will overwrite.
##' @param custom logical; if true, the script will provide the opportunity to manually enter column headers.
##'
##' @return None
##'
##' @export
##'
##' @author Conor I. Anderson
##'
##' @examples
##' senamhi()
##' senamhi(3, 000401, type = "CON", MorH = "M", 1971, 2000)

senamhi <- function(tasks, station, automatic = TRUE, dataAvail = TRUE, type = "z", MorH = "z", startYear, endYear, startMonth = 1, endMonth = 12,
                    overwrite = FALSE, append = FALSE, custom = FALSE) {

    if (missing(tasks)) {
      print("Please choose the series of command you wish to run.")
      tasks <- readline(prompt = "1) Download Data, 2) Compile CSV of Downloaded Data, 3) Both: ")
    }
    if (missing(station))
      station <- readline(prompt = "Enter station number: ")
    
    ##Add a work-around to download multiple stations
    if (length(station) > 1) lapply(station, senamhi, tasks = tasks, automatic, dataAvail = dataAvail, type = type, MorH = MorH, startYear = startYear, endYear = endYear, startMonth = startMonth, endMonth = endMonth,
                                    append = append, custom = custom)
    
    ## Input Station Characteristics for single stations
    if (automatic == TRUE) {
      guess <- senamhiGuess(station)
      type <- guess[1]
      MorH <- guess[2]
      if (guess[1] == "ERROR" | guess[2] == "ERROR") print("Something went wrong. Please enter manually")
    }
    while (!(type == "CON" | type == "DAV" | type == "SIA" | type == "SUT"))
      type <- readline(prompt = "Enter Type CON, DAV, SUT, or SIA: ")
    while (!(MorH == "M" | MorH == "M2" | MorH == "H"))
      MorH <- readline(prompt = "Enter Field M, M2 or H: ")

    ## Choose Data Range
    if (dataAvail == TRUE & (missing(startYear) | missing(endYear))) {
      result <- try(senamhiGetPeriod(station, automatic))
      if (!inherits(result, "try-error")) {
        if (automatic == TRUE) {
          startYear <- result[1]
          endYear <- result[2]
        } else {
          cat("The following data is available.\n")
          print(table)
        }
      }
    }
    if (missing(startYear))
      startYear <- as.integer(readline(prompt = "Enter start year: "))
    if (missing(endYear))
      endYear <- as.integer(readline(prompt = "Enter end year: "))
    
    if (tasks == 1) {
      senamhiDownload(station, type, MorH, startYear, endYear, startMonth, endMonth)
    } else {
      if (tasks == 2) {
        senamhiWriteCSV(station, type, MorH, startYear, endYear, startMonth, endMonth)
      } else {
        if (tasks == 3) {
          senamhiDownload(station, type, MorH, startYear, endYear, startMonth, endMonth, overwrite)
          senamhiWriteCSV(station, type, MorH, startYear, endYear, startMonth, endMonth, custom, append)
        } else
          print("Please choose an option between 1 and 3")
      }
    }
  }
