##' @title Map Senamhi stations on an interactive map
##'
##' @description Show the stations of interest on an interactive map using Leaflet. Zoom levels are guessed based on an RStudio plot window. 
##'
##' @param station character; one or more station id numbers to show on the map.
##' @param zoom numeric; the level to zoom the map to.
##' 
##' @importFrom leaflet leaflet addTiles setView addMarkers 
##' 
##' @export
##'
##' @author Conor I. Anderson
##'
##' @examples
##' # Make a map of all the stations.
##' \dontrun{map_stations(catalogue$StationID), zoom = 4}
##' # Make a map of all stations in Cusco.
##' \dontrun{map_stations(catalogue$StationID[catalogue$Region == "CUSCO"])}

map_stations <- function(station, zoom) {
  
  poi <- NULL
  
  for (i in station) {
    poi <- c(poi, grep(i, catalogue$StationID))
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
  
  leaflet() %>% addTiles() %>% 
    setView(lng = lons, lat = lats, zoom = zoom)  %>% 
    addMarkers(poi$Station, lng = poi$Longitude, lat = poi$Latitude, 
               popup = paste0(poi$StationID, " - ", poi$Station, " (", poi$Configuration, ")")) 
}