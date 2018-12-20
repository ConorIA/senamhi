##' @title Map Senamhi stations on an interactive map
##'
##' @description Show the stations of interest on an interactive map using Leaflet. Zoom levels are guessed based on an RStudio plot window. 
##'
##' @param station character; one or more station id numbers to show on the map.
##' @param type character; either "osm" for OpenStreetMap tiles, or "sentinel" for cloudless satellite by EOX IT Services GmbH (\url{https://s2maps.eu}).
##' 
##' @importFrom dplyr "%>%" filter
##' @importFrom rlang .data
##' 
##' @export
##'
##' @author Conor I. Anderson
##'
##' @examples
##' # Map a single station
##' map_stations(401)
##' # Make a map from station search results.
##' map_stations(station_search(region = "SAN MARTIN", baseline = 1981:2010))

map_stations <- function(station, type = "osm") {
  
  if (!requireNamespace("leaflet", quietly = TRUE)) {
    stop("The \"leaflet\" packge is required to create maps. Please install it.",
         call. = FALSE)
  }
  
  catalogue <- .get_catalogue()
  
  if (!inherits(station, "data.frame")) {
    if (any(nchar(station) < 6)) {
      station[nchar(station) < 6] <- suppressWarnings(
        try(sprintf("%06d", as.numeric(station[nchar(station) < 6])),
            silent = TRUE))
    }
    
    if (inherits(station, "try-error") || !station %in% catalogue$StationID) {
      stop("One or more requested stations invalid.")
    }
    
    station <- filter(catalogue, .data$StationID %in% station)
  }
  
  icons <- leaflet::awesomeIcons(
    icon = unname(sapply(station$Configuration, function(x) {
      if (x %in% c("M", "M1", "M2")) "thermometer" else "waterdrop"
    })),
    iconColor = 'black', 
    library = 'ion',
    markerColor = unname(sapply(station$Configuration, function(x) {
      if (x %in% c("M", "M1", "M2")) "orange" else "blue"
    }))
  )
  
  map <- if (type == "sentinel") {
    leaflet::leaflet(station, options = leaflet::leafletOptions(
      crs = leaflet::leafletCRS("L.CRS.EPSG4326"))) %>%
      leaflet::addWMSTiles(
        "https://tiles.maps.eox.at/wms?service=wms",
        layers = "s2cloudless",
        options = leaflet::WMSTileOptions(format = "image/jpeg"),
        attribution = paste("Sentinel-2 cloudless - https://s2maps.eu by EOX",
                            "IT Services GmbH (Contains modified Copernicus",
                            "Sentinel data 2016 & 2017)")
      )
  } else {
    if (type != "osm") warning("Unrecognized map type. Defaulting to osm.")
    leaflet::leaflet(station) %>% leaflet::addTiles()
  }
  
  map <- map %>%
    leaflet::addAwesomeMarkers(~Longitude, ~Latitude, icon = icons,
                      label = paste0(station$StationID, " - ",
                                     station$Station, 
                                     " (", station$Configuration, ")",
                                     " @ ", round(station$Latitude, 2), ", ",
                                     round(station$Longitude, 2)))

  # Add a target if it exists
  target <- c(attr(station, "target_lon"), attr(station, "target_lat"))
  if (!is.null(target)) {
    map <- map %>% leaflet::addCircleMarkers(lng = target[1], lat = target[2],
                                    color = "red", label = paste0("Target: ",
                                                                  target[2],
                                                                  ", ",
                                                                  target[1]))
  }
  
  map
}
