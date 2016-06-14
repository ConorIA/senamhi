##' @title Query available data from the Peruvian National Hydrological and Meterological Service
##'
##' @description Query the available data for a given station from the Senamhi web portal.
##'
##' @param station numerical; the number of the station id number to process.
##'
##' @return data.frame
##'
##' @export
##'
##' @author Conor I. Anderson
##'
##' @examples
##' senamhiGetPeriod()
##' senamhiGetPeriod(000401)

senamhiGetPeriod <- function(station) {

  if ("curl" %in% rownames(installed.packages()) == FALSE) {
    print("Installing the curl package")
    install.packages("curl")
  }
  require(curl)

  if ("XML" %in% rownames(installed.packages()) == FALSE) {
    print("Installing the XML package")
    install.packages("XML")
  }
  require(XML)

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
  cat(paste0("Checking data at ", station, ".\n"))
  curl_download(url, paste(station, "/", "availableData.html", sep = ""))

  table <- readHTMLTable(paste(station, "/", "availableData.html", sep = ""))
  table <- as.data.frame(table[3])
  if (ncol(table) > 1) names(table) <- c("Parameter", "DataFrom", "DataTo")
  else stop("We could not determine data availability for this station.")
  return(table)
}
