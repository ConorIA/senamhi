##' @title A wrapper function to download and compile data from the Peruvian National Hydrological and Meterological Service
##'
##' @description Download and/or compile Peruvian historical climate data from the Senamhi web portal.
##'
##' @param tasks numerical; define which tasks to perform: 1) Download Data, 2) Compile CSV of Downloaded Data, 3) Both.
##' @param station numerical; the number of the station id number to process.
##' @param type character; defines if the station is (CON)ventional, (SUT)ron, or (SIA)p. Must be "CON", "SUT" or "SIA".
##' @param MorH character; defines if the station is (M)eterological or (H)ydrological. Must be "M" or "H".
##' @param startYear numerical; the first year to process.
##' @param endYear numerical; the last year to process.
##' @param startMonth numerical; the first month to process. Defaults to 1.
##' @param endMonth numerical; the last month to process. Defaults to 12.
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

senamhi <- function(tasks, station, type = "z", MorH = "z", startYear, endYear, startMonth = 1, endMonth = 12,
                    append = FALSE, custom = FALSE) {

    if (missing(tasks)) {
      print("Please choose the series of command you wish to run.")
      tasks <- readline(prompt = "1) Download Data, 2) Compile CSV of Downloaded Data, 3) Both: ")
    }
    if (missing(station))
      station <- readline(prompt = "Enter station number: ")
    while (!(type == "CON" | type == "SIA" | type == "SUT"))
      type <- readline(prompt = "Enter Type CON, SUT, or SIA: ")
    while (!(MorH == "M" | MorH == "H"))
      MorH <- readline(prompt = "Enter Field M or H: ")
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
          senamhiDownload(station, type, MorH, startYear, endYear, startMonth, endMonth)
          senamhiWriteCSV(station, type, MorH, startYear, endYear, startMonth, endMonth, custom, append)
        } else
          print("Please choose an option between 1 and 3")
      }
    }
  }
