##' @title Download from the Peruvian National Hydrological and Meterological Service
##'
##' @description Download Peruvian historical climate data from the Senamhi web portal.
##'
##' @param station numerical; the number of the station id number to process.
##' @param type character; defines if the station is (CON)ventional, (SUT)ron, or (SIA)p. Must be "CON", "SUT" or "SIA".
##' @param MorH character; defines if the station is (M)eterological or (H)ydrological. Must be "M" or "H".
##' @param startYear numerical; the first year to process.
##' @param endYear numerical; the last year to process.
##' @param startMonth numerical; the first month to process. Defaults to 1.
##' @param endMonth numerical; the last month to process. Defaults to 12.
##'
##' @return None
##'
##' @export
##'
##' @author Conor I. Anderson
##'
##' @examples
##' senamhiDownload()
##' senamhiDownload(000401, type = "CON", MorH = "M", 1971, 2000)

senamhiDownload <- function(station, type = "z", MorH = "z", startYear, endYear, startMonth = 1, endMonth = 12) {

  if ("curl" %in% rownames(installed.packages()) == FALSE) {
    print("Installing the curl package")
    install.packages("curl")
  }
  require(curl)

  ## Ask user to input variables
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

  #GenDates
  years <- seq(startYear, endYear)
  months <- seq(startMonth, endMonth)
  months <- sprintf("%02d", months)
  dates <- apply(expand.grid(months, years), 1, function(x) paste(x[2], x[1], sep = ""))

  ##genURLs
  urlList <- paste("http://www.senamhi.gob.pe/include_mapas/_dat_esta_tipo02.php?estaciones=",
    station, "&tipo=", type, "&CBOFiltro=", dates, "&t_e=", MorH, sep = "")

  if (!dir.exists(as.character(station))) {
    check <- try(dir.create(as.character(station)))
    if (inherits(check, "try-error")) {
      stop("I couldn't write out the directory. Check your permissions.")
    }
  }

  ## Set up a progress Bar
  prog <- txtProgressBar(min = 0, max = length(urlList), style = 3)
  on.exit(close(prog))

  ##Download the data
  cat("Downloading the requested data.\n")
  for (i in 1:length(urlList)) {
    curl_download(urlList[i], paste(station, "/", dates[i], ".html", sep = ""))
    setTxtProgressBar(prog, value = i)
  }
}
