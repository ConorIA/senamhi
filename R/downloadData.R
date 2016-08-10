##' @title Download from the Peruvian National Hydrological and Meterological Service
##'
##' @description Download Peruvian historical climate data from the Senamhi web portal.
##'
##' @param station character; the station id number to process.
##' @param year numerical; a vector of years to process.
##' @param month numerical; a vector of months to process. Defaults to 1:12.
##' @param writeMode character; if set to 'overwrite', the script will overwrite downloaded files if they exist.
##'
##' @return None
##'
##' @author Conor I. Anderson
##' 
##' @importFrom curl curl_download
##' @importFrom utils setTxtProgressBar 
##' @importFrom utils txtProgressBar
##'
##' @export
##' 
##' @examples
##' \dontrun{downloadData("000401", 1971:2000)}

downloadData <- function(station, year, month = 1:12, writeMode = "z") {

  stationData <- catalogue[catalogue$StationID==station,]
  stationName <- stationData$Station
  region <- stationData$Region
  type = stationData$Type
  config = stationData$Configuration
  
  month <- sprintf("%02d", month)
  dates <- apply(expand.grid(month, year), 1, function(x) paste0(x[2], x[1]))

  ##genURLs
  urlList <- paste0("http://www.senamhi.gob.pe/include_mapas/_dat_esta_tipo02.php?estaciones=",
    station, "&tipo=", type, "&CBOFiltro=", dates, "&t_e=", config)
  
  foldername <- paste0(region, "/HTML/", as.character(station), " - ", stationName)
  if (!dir.exists(foldername)) {
    check <- try(dir.create(foldername, recursive = TRUE))
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
    filename <- paste0(foldername, "/", dates[i], ".html")
    .downloadAction(url = urlList[i], filename, writeMode)
    setTxtProgressBar(prog, value = i)
  }
}
