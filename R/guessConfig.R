##' @title Guess station characteristics
##'
##' @description Attempt to guess station characteristics.
##'
##' @param station character; the number of the station id number to process.
##' @param overwrite logical; if true, the script will overwrite downloaded files if they exist.
##'
##' @return vector
##'
##' @author Conor I. Anderson
##'
##' @importFrom XML htmlTreeParse
##'
##' @export
##'
##' @examples
##' \dontrun{guessConfig("000401")}

guessConfig <- function(station, overwrite = FALSE) {

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
  print(paste0("Checking station characteristics for ", station, "."))
  filename <- paste(station, "/", "stationInfo.html", sep = "")
  downloadAction(url, filename, overwrite)
  stationData <- htmlTreeParse(paste(station, "/", "stationInfo.html", sep = ""))
  stationData <- stationData[3]

  ##Check config
  test <- grep("Meteorológica 1", stationData)
  if (length(test) > 0) {
    config <- "M1"
  } else {
    test <- grep("Meteorológica 2", stationData)
    if (length(test) > 0) {
      config <- "M2"
    } else {
      test <- grep("Meteorológica", stationData)
      if (length(test) > 0) {
        config <- "M"
      } else {
        test <- grep("Hidrológica", stationData)
        if (length(test) > 0) {
          config <- "H"
        } else {
          config <- "ERROR"
        }
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
  result <- c(type, config)
}
