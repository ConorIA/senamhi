##' @title Find Senamhi stations matching various criteria
##'
##' @description Search for Senamhi stations by name, region, available data, and/or distance to a target.
##'
##' @param name character; optional character string to filter results by station name.
##' @param region character; optional character string to filter results by region.
##' @param ignore.case logical; by default the search for station names is not case-sensitive.
##' @param baseline vector; optional vector with a start and end year for a desired baseline.
##' @param target numeric; optional station ID of a target station, or a vector of length 2 containing latitude and longitude (in that order).
##' @param mindist numeric; minimum distance from the target in km. Only used if a target is specified. (defaults to 0)
##' @param maxdist numeric; maximum distance from the target in km. Only used if a target is specified. (defaults to 100)
##' @param sort Boolean; if TRUE (default), will sort the resultant table by distance from `target`. Only used if a target is specified.
##' @param ... Additional arguments passed to \code{\link{grep}}.
##'
##' @return A data frame containing the details of matching stations.
##' 
##' @importFrom geosphere distGeo 
##' 
##' @export
##'
##' @author Conor I. Anderson
##'
##' @examples
##' # Find all stations containing 'Tarapoto' in their name.
##' station_search('Tarapoto')
##' 
##' # Find stations with data available from 1971 to 2000.
##' station_search(baseline = c(1971, 2000))
##' 
##' # Find all stations between 0 and 100 km from Station '000401'
##' station_search(target = '000401', mindist = 0, maxdist = 100)
##' 

station_search <- function(name = NULL, region = NULL, baseline = NULL, ignore.case = TRUE, 
  target = NULL, mindist = 0, maxdist = 100, sort = TRUE, ...) {
  
  # If `name` is not NULL, filter by name
  if (!is.null(name)) {
    index <- grep(name, catalogue$Station, ignore.case = ignore.case, ...)
  } else {
    index <- 1:nrow(catalogue)
  }
  
  # If `region` is not NULL, filter by name
  if (!is.null(region)) {
    index <- index[grep(region, catalogue$Region[index], ignore.case = ignore.case, 
      ...)]
  }
  
  # Make a table with the info we want
  df <- catalogue[index, ]
  
  # If `baseline` is not NULL, filter by available data
  if (!is.null(baseline)) {
    index = NULL
    # Identify all stations outside of our baseline
    for (i in 1:nrow(df)) {
      if (is.na(df$`Data Start`[i]) | df$`Data Start`[i] > baseline[1]) 
        index <- c(index, i) else if (is.na(df$`Data End`[i]) | df$`Data End`[i] < baseline[length(baseline)]) 
        index <- c(index, i)
    }
    # Delete those stations
    if (!is.null(index)) 
      df <- df[-index, ]
  }
  
  # If `target` is not NULL, filter by distance to target
  if (!is.null(target)) {
    if (length(target) == 1L) {
      p1 <- c(df$Longitude[grep(paste0("\\b", as.character(target), "\\b"), 
        df$StationID)], df$Latitude[grep(paste0("\\b", as.character(target), 
        "\\b"), df$StationID)])
    } else if (length(target) == 2L) {
      p1 <- c(target[2], target[1])
    } else stop("error: check target format")
    df$Dist <- rep(NA, nrow(df))
    for (j in 1:nrow(df)) {
      df$Dist[j] <- (distGeo(p1, c(df$Longitude[j], df$Latitude[j]))/1000)
    }
    df <- df[(!is.na(df$Dist) & (df$Dist >= mindist) & (df$Dist <= maxdist)), 
      ]
    if (sort == TRUE) 
      df <- df[order(df$Dist), ]
  }
  df
}
