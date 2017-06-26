##' @title Map Senamhi stations on an interactive map
##'
##' @description Show the stations of interest on an interactive map using Leaflet. Zoom levels are guessed based on an RStudio plot window. 
##'
##' @param station character; one or more station id numbers to show on the map.
##' @param zoom numeric; the level to zoom the map to.
##' 
##' @importFrom leaflet addAwesomeMarkers addTiles awesomeIcons leaflet setView 
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
  
  if (inherits(station, "data.frame")) {
    station <- station$StationID
  }

  poi <- NULL
  
  for (i in station) {
    poi <- c(poi, which(catalogue$StationID == i))
  }
  poi <- catalogue[poi,]

  hilat <- ceiling(max(poi$Latitude))
  lolat <- floor(min(poi$Latitude))
  hilon <- ceiling(max(poi$Longitude))
  lolon <- floor(min(poi$Longitude))
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
    icon = defIcons(poi),
    iconColor = 'black', 
    library = 'ion',
    markerColor = defColours(poi)
  )
  
  leaflet(poi) %>% addTiles() %>% 
    setView(lng = lons, lat = lats, zoom = zoom)  %>% 
    addAwesomeMarkers(~Longitude, ~Latitude, icon = icons,  
      label = paste0(poi$StationID, " - ", poi$Station, " (", poi$Configuration, ")")) 
}
