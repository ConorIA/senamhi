#' [DEPRECATED] Guess the period of available compiled data
#'
#' @param station character; station ID to process
#' @param fallback numeric; vector of year to fall back on
#'
#' @return Vector of years of archived data
#' 
#' @keywords internal

.guess_year <-  function(station, fallback) {
  station_data <- catalogue[catalogue$StationID == station, ]
  if (is.na(station_data$`Data Start`) || is.na(station_data$`Data End`)) {
    if (missing(fallback)) {
      print("Available data undefined and no fallback specified. Skipping this station.")
      return("No period defined.")
    }
    if (is.na(station_data$`Data Start`) && !is.na(station_data$`Data End`)) {
      print(paste("Data start undefined. Using fallback from", min(fallback), "to", station_data$`Data End`))
      year <- min(fallback):station_data$`Data End`
    }
    if (!is.na(station_data$`Data Start`) && is.na(station_data$`Data End`)) {
      print(paste("Data end undefined. Using fallback from", station_data$`Data Start`, "to", max(fallback)))
      year <- station_data$`Data Start`:max(fallback)
    }
    if (is.na(station_data$`Data Start`) && is.na(station_data$`Data End`)) {
      print(paste("Available data undefined. Using fallback from", min(fallback), "to", max(fallback)))
      year <- min(fallback):max(fallback)
    }
  } else {
    if (station_data$`Data End` == "2010+") {
      print(paste("Not sure when data period ends. We will try until", 
                  (as.numeric(format(Sys.Date(), format = "%Y")) - 1)))
      endYear <- as.numeric(format(Sys.Date(), format = "%Y")) - 1
    } else {
      endYear <- station_data$`Data End`
    }
    year <- station_data$`Data Start`:endYear
  }
  year
}