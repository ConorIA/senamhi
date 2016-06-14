##' @title Guess station characteristics
##'
##' @description Attempt to guess station characteristics.
##'
##' @param station numerical; the number of the station id number to process.
##'
##' @return vector
##'
##' @export
##'
##' @author Conor I. Anderson
##'
##' @examples
##' senamhiGuess()
##' senamhiGuess("000401")

senamhiGuess <- function(station) {

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
  url <- paste("http://www.senamhi.gob.pe/include_mapas/_dat_esta_tipo.php?estaciones=",
    station, sep = "")

  if (!dir.exists(as.character(station))) {
    check <- try(dir.create(as.character(station)))
    if (inherits(check, "try-error")) {
      stop("I couldn't write out the directory. Check your permissions.")
    }
  }

  ##Download the data
  cat("Checking station characteristics.\n")
  curl_download(url, paste(station, "/", "availableData.html", sep = ""))
  stationData <- htmlTreeParse(paste(station, "/", "availableData.html", sep = ""))
  stationData <- stationData[3]

  ##Check MorH
  test <- grep("Meteorológica 2", stationData)
  if (length(test) > 0) {
    MorH <- "M2"
    } else {
      test <- grep("Meteorológica", stationData)
      if (length(test) > 0) {
        MorH <- "M"
      } else {
        test <- grep("Hidrológica", stationData)
        if (length(test) > 0) {
          MorH <- "H"
        } else {
          MorH <- "ERROR"
        }
      }
    }

  ##Check station type
  test <- grep("Convencional", stationData)
  if (length(test) > 0) {
    type <- "CON"
  } else {
    test <- grep("Automtica", stationData)
    if (length(test) > 0) {
      type <- "AUT"
    } else {
      type <- "ERROR"
    }
  }

  if (type == "AUT") {
    print("Automatic station detected. Trying known types.")
    test <- grep("DAV", stationData)
    if (length(test) > 0) {
      type <- "DAV"
    } else {
      test <- grep("SUT", stationData)
      if (length(test) > 0) {
        type <- "SUT"
      } else {
        test <- grep("SIA", stationData)
        if (length(test) > 0) {
          type <- "SIA"
        } else {
          type <- "ERROR"
        }
      }
    }
  }
  result <- c(type, MorH)
}
