##' @title Map Senamhi stations on an interactive map
##'
##' @description Show the stations of interest on an interactive map using Leaflet. Zoom levels are guessed based on an RStudio plot window. 
##'
##' @param station character; one or more station id numbers to show on the map.
##' @param zoom numeric; the level to zoom the map to.
##' 
##' @importFrom dplyr filter
##' @importFrom leaflet addAwesomeMarkers addCircleMarkers addTiles awesomeIcons leaflet setView 
##' @importFrom magrittr %>%
##' 
##' @export
##'
##' @author Conor I. Anderson
##'
##' @examples
##' # Make a map of all the stations.
##' \dontrun{map_stations(catalogue$StationID, zoom = 4)}
##' # Make a map of all stations in Cusco.
##' \dontrun{map_stations(catalogue$StationID[catalogue$Region == "CUSCO"])}
##' ##' # Make a map from station search results.
##' \dontrun{map_stations(station_search(region = "SAN MARTIN", baseline = 1981:2010))}

map_stations <- function(station, zoom) {
  
  if (!inherits(station, "data.frame")) {
    if (any(nchar(station) < 6)) {
      station[nchar(station) < 6] <- suppressWarnings(
        try(sprintf("%06d", as.numeric(station[nchar(station) < 6])),
            silent = TRUE))
    }
    
    if (inherits(station, "try-error") || !station %in% catalogue$StationID) {
      stop("One or more requested stations invalid.")
    }
    
    station <- filter(catalogue, StationID %in% station)
  }
  
  hilat <- ceiling(max(station$Latitude))
  lolat <- floor(min(station$Latitude))
  hilon <- ceiling(max(station$Longitude))
  lolon <- floor(min(station$Longitude))
  lats <- (hilat + lolat)/2
  lons <- (hilon + lolon)/2
  if (missing(zoom)) {
    latrng <- (hilat - lolat)
    if (latrng >= 16) {
      zoom = 4
    } else if (latrng >= 8) {
      zoom = 5
    } else if (latrng >= 5) {
      zoom = 6
    } else if (latrng >= 2) {
      zoom = 7
    } else if (latrng == 1) {
      zoom = 8
    } else zoom = 10
  }
  
  defIcons <-function(dat) {
    sapply(dat$Configuration, function(Configuration) {
      if(Configuration %in% c("M", "M1", "M2")) {
        "thermometer"
      } else {
        "waterdrop"
      } })
  }
  
  defColours <-function(dat) {
    sapply(dat$Configuration, function(Configuration) {
    if(Configuration %in% c("M", "M1", "M2")) {
      "orange"
    } else {
      "blue"
    } })
  }
  
  icons <- awesomeIcons(
    icon = defIcons(station),
    iconColor = 'black', 
    library = 'ion',
    markerColor = defColours(station)
  )
  
  map <- leaflet(station) %>% addTiles() %>% 
    setView(lng = lons, lat = lats, zoom = zoom)  %>% 
    addAwesomeMarkers(~Longitude, ~Latitude, icon = icons,  
      label = paste0(station$StationID, " - ", station$Station, " (", station$Configuration, ")"))
  
  # Add a target if it exists
  target <- c(attr(station, "target_lon"), attr(station, "target_lat"))
  if (!is.null(target)) {
    map <- map %>% addCircleMarkers(lng = target[1], lat = target[2], color = "red", label = "target")
  }
  
  map
}
