##' @title Guess station characteristics
##'
##' @description Attempt to guess station characteristics.
##'
##' @param station character; the station id number to process.
##' @param writeMode character; if set to 'overwrite', the script will overwrite downloaded files if they exist.
##'
##' @return vector
##'
##' @keywords internal
##'
##' @author Conor I. Anderson
##' 
##' @importFrom XML htmlTreeParse
##'
##' @examples
##' \dontrun{guessConfig("000401")}

.guessConfig <- function(station, writeMode = "z") {

  ## Ask user to input variables
  if (missing(station))
    station <- readline(prompt = "Enter station number: ")

  ##genURL
  url <- paste0("http://www.senamhi.gob.pe/include_mapas/_dat_esta_tipo.php?estaciones=",
    station)

  ##Download the data
  print(paste0("Checking station characteristics for ", station, "."))
  filename <- tempfile()
  .downloadAction(url, filename, writeMode)
  stationData <- htmlTreeParse(filename)
  stationData <- unlist(stationData[3])
  stationData <- stationData[grep("_dat_esta_tipo02.php", stationData)]

  ##Check config
  test <- grep("t_e=M1", stationData)
  if (length(test) > 0) {
    config <- "M1"
  } else {
    test <- grep("t_e=M2", stationData)
    if (length(test) > 0) {
      config <- "M2"
    } else {
      test <- grep("t_e=M", stationData)
      if (length(test) > 0) {
        config <- "M"
      } else {
        test <- grep("t_e=H", stationData)
        if (length(test) > 0) {
          config <- "H"
        } else {
          config <- "ERROR"
        }
      }
    }
  }

  ##Check station type
  test <- grep("tipo=CON", stationData)
  if (length(test) > 0) {
    type <- "CON"
  } else {
    test <- grep("tipo=DAV", stationData)
    if (length(test) > 0) {
      type <- "DAV"
    } else {
      test <- grep("tipo=SUT", stationData)
      if (length(test) > 0) {
        type <- "SUT"
      } else {
        test <- grep("tipo=SIA", stationData)
        if (length(test) > 0) {
          type <- "SIA"
        } else {
          type <- "ERROR"
        }
      }
    }
  }
  result <- c(type, config)
  if (result[1] == "ERROR" | result[2] == "ERROR") stop("We could not determine the configuration of this station.")
  return(result)
}
