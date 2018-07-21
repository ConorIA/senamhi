##' @title Find Senamhi stations matching various criteria
##'
##' @description Search for Senamhi stations by name, region, available data, and/or distance to a target.
##'
##' @param name character; optional character vector to filter results by station name.
##' @param ignore.case logical; by default the search for station names is not case-sensitive.
##' @param glob logical; whether to allow regular expressions in the \code{name}. See \code{\link{glob2rx}}.
##' @param region character; optional character string to filter results by region.
##' @param period numeric; optional, either a range of years or the total number of years of data that must be available.
##' @param config character; the configuration of the station ((m)eteorological or (h)ydrological)
##' @param target numeric; optional station ID of a target station, or a vector of length 2 containing latitude and longitude (in that order).
##' @param dist numeric; vector with a range of distance from the target in km. Only used if a target is specified. (default is 0:100)
##' @param sort Boolean; if TRUE (default), will sort the resultant table by distance from `target`. Only used if a target is specified.
##' @param ... Additional arguments passed to \code{\link{grep}}.
##'
##' @return A data frame containing the details of matching stations.
##' 
##' @importFrom dplyr arrange filter mutate rowwise
##' @importFrom geosphere distGeo 
##' @importFrom utils glob2rx
##' 
##' @export
##'
##' @author Conor I. Anderson
##'
##' @examples
##' # Find all stations containing 'Tarapoto' in their name.
##' station_search('Tarapoto')
##' 
##' # Find all stations starting with "San"
##' station_search(name = "San*", glob = TRUE)
##' 
##' # Find stations with data available from 1971 to 2000.
##' station_search(period = 1971:2000)
##' 
##' # Find all stations between 0 and 100 km from Station '000401'
##' station_search(target = '000401', dist = 0:100)
##' 

station_search <- function(name = NULL, ignore.case = TRUE, glob = FALSE, region = NULL, 
  period = NULL, config = NULL, target = NULL, dist = 0:100, sort = TRUE, ...) {
  
  catalogue <- .get_catalogue()
  
  if (!is.null(target) && length(target) == 1L && nchar(target) < 6) {
    target <- suppressWarnings(try(sprintf("%06d", as.numeric(target)), silent = TRUE))
    if (inherits(target, "try-error") || !target %in% catalogue$StationID) {
      stop("Target station appears invalid.")
    }
  }
  
  filt <- catalogue
  
  # If `name` is not NULL, filter by name
  if (!is.null(name)) {
    if (glob) name <- glob2rx(name)
    if (length(name) > 1) name <- paste(name, collapse = "|")
    filt <- filter(filt, grepl(name, Station, ignore.case = ignore.case, ...))
  } 
  
  # If `region` is not NULL, filter by name
  if (!is.null(region)) {
    filt <- filter(filt, Region == toupper(region))
    if (nrow(filt) == 0) {
      stop("No data found for that region. Did you spell it correctly?")
    }
  }
  
  # If `config` is not NULL, filter by config
  if (!is.null(config)) {
    filt <- filter(filt, grepl(config, Configuration, ignore.case = ignore.case, ...))
    if (nrow(filt) == 0) {
      stop("No data found for that config. Did you pass \"m\" or \"h\"?")
    }
  }
  
  # If `period` is not NULL, filter by available data
  if (!is.null(period)) {
    if (length(period) == 1) {
      filt <- filter(filt, `Period (Yr)` >= period)
    } else {
      filt <- filter(filt, `Data Start` <= min(period) & `Data End` >= max(period))  
    }
    if (nrow(filt) == 0) {
      stop("No station was found for the specified period.")
    }
  }

  # If `target` is not NULL, filter by distance to target
  if (!is.null(target)) {
    if (length(target) == 1L) {
      p1 <- catalogue %>% filter(StationID == target) %>% select(Longitude, Latitude) %>% unlist
    } else if (length(target) == 2L) {
      p1 <- c(target[2], target[1])
    } else stop("error: check target format")
    filt <-  rowwise(filt) %>%
      mutate(Dist = distGeo(p1, c(Longitude, Latitude))/1000) %>%
      filter(Dist >= min(dist) & Dist <= max(dist))
    if (sort == TRUE) filt <- arrange(filt, Dist)
    attr(filt, "target_lon") <- p1[1]
    attr(filt, "target_lat") <- p1[2]
  }
  
  filt
}
