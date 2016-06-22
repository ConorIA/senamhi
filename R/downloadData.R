##' @title Download from the Peruvian National Hydrological and Meterological Service
##'
##' @description Download Peruvian historical climate data from the Senamhi web portal.
##'
##' @param station character; the number of the station id number to process.
##' @param type character; defines if the station is (CON)ventional, DAV, (SUT)ron, or (SIA)p. Must be "CON", "DAV", "SUT" or "SIA".
##' @param config character; defines if the station is (M)eterological (1/2) or (H)ydrological. Must be "M", "M2" or "H".
##' @param startYear numerical; the first year to process.
##' @param endYear numerical; the last year to process.
##' @param startMonth numerical; the first month to process. Defaults to 1.
##' @param endMonth numerical; the last month to process. Defaults to 12.
##' @param endMonth numerical; the last month to process. Defaults to 12.
##' @param overwrite logical; if true, the script will overwrite downloaded files if they exist.
##'
##' @return None
##'
##' @author Conor I. Anderson
##'
##' @export
##' 
##' @examples
##' downloadData()
##' downloadData("000401", type = "CON", config = "M", 1971, 2000)

downloadData <- function(station, type = "z", config = "z", startYear, endYear, startMonth = 1, endMonth = 12, overwrite = FALSE) {

  if ("curl" %in% rownames(installed.packages()) == FALSE) {
    print("Installing the curl package")
    install.packages("curl")
  }
  require(curl)

  ## Ask user to input variables
  if (missing(station))
    station <- readline(prompt = "Enter station number: ")
  while (!(type == "CON" | type == "DAV" | type == "SIA" | type == "SUT"))
    type <- readline(prompt = "Must be one of CON, DAV, SUT, or SIA: ")
  while (!(config == "M" | config == "M1" | config == "M2" | config == "H"))
    config <- readline(prompt = "Must be one of M, M1, M2 or H: ")
  if (missing(startYear))
    startYear <- as.integer(readline(prompt = "Enter start year: "))
  if (missing(endYear))
    endYear <- as.integer(readline(prompt = "Enter end year: "))

  #GenDates
  years <- seq(startYear, endYear)
  months <- seq(startMonth, endMonth)
  months <- sprintf("%02d", months)
  dates <- apply(expand.grid(months, years), 1, function(x) paste(x[2], x[1], sep = ""))

  ##genURLs
  urlList <- paste("http://www.senamhi.gob.pe/include_mapas/_dat_esta_tipo02.php?estaciones=",
    station, "&tipo=", type, "&CBOFiltro=", dates, "&t_e=", config, sep = "")

  if (!dir.exists(as.character(station))) {
    check <- try(dir.create(as.character(station)))
    if (inherits(check, "try-error")) {
      stop("I couldn't write out the directory. Check your permissions.")
    }
  }

  ##Download the data
  print("Downloading the requested data.")
  ## Set up a progress Bar
  prog <- txtProgressBar(min = 0, max = length(urlList), style = 3)
  on.exit(close(prog))
  for (i in 1:length(urlList)) {
    filename <- paste(station, "/", dates[i], ".html", sep = "")
    downloadAction(url = urlList[i], filename, overwrite)
    setTxtProgressBar(prog, value = i)
  }
}
