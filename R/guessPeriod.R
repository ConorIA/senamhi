##' @title Query available data from the Peruvian National Hydrological and Meterological Service
##'
##' @description Query the available data for a given station from the Senamhi web portal.
##'
##' @param station character; the number of the station id number to process.
##' @param automatic logical; if set to true (default), the script will attempt to guess the startYear and endYear values.
##' @param overwrite logical; if true, the script will overwrite downloaded files if they exist.
##'
##' @return data.frame
##'
##' @author Conor I. Anderson
##' 
##' @importFrom XML readHTMLTable
##' 
##' @export
##'  
##' @examples
##' guessPeriod()
##' guessPeriod("000401")

guessPeriod <- function(station, automatic = TRUE, overwrite = FALSE) {

  ## Ask user to input variables
  if (missing(station))
    station <- readline(prompt = "Enter station number: ")

  ##genURL
  url <- paste("http://www.senamhi.gob.pe/include_mapas/_dat_esta_periodo.php?estaciones=",
    station, sep = "")

  if (!dir.exists(as.character(station))) {
    check <- try(dir.create(as.character(station)))
    if (inherits(check, "try-error")) {
      stop("I couldn't write out the directory. Check your permissions.")
    }
  }

 ##Download the data
  print(paste0("Checking data at ", station, "."))
  filename <- paste(station, "/", "availableData.html", sep = "")
  downloadAction(url, filename, overwrite)
  
  table <- readHTMLTable(paste(station, "/", "availableData.html", sep = ""), as.data.frame = TRUE)
  table <- as.data.frame(table[3])
  if (ncol(table) > 1) {
    names(table) <- c("Parameter", "DataFrom", "DataTo")
    if (automatic == TRUE) {
      startYear <- min(as.numeric(levels(table$DataFrom)))
      endYear <- max(as.numeric(levels(table$DataTo)))
      if (endYear == 2010) {
        print("Highest year is 2010, assuming newer data. Trying to last year.")
        currentYear <- as.numeric(format(Sys.time(), "%Y"))
        endYear <- currentYear - 1
      }
      result <- c(startYear, endYear)
      return(result)
    } else {
      return(table)
    }
  }
  else {
    stop("We could not determine data availability for this station.")
  }
}
