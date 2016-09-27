##' @title A Shiny interface to Senamhi weather and river stations
##'
##' @description A function to launch a shiny web app to explore Senamhi stations.
##'
##' @return none
##' 
##' @author Conor I. Anderson
##'
##' @export

station_explorer <- function() {
  appDir <- system.file("shiny", "ShinyStationExplorer", package = "senamhiR")
  if (appDir == "") {
    stop("Could not find the shiny directory. Try re-installing `senamhiR`.", 
      call. = FALSE)
  }
  shiny::runApp(appDir, display.mode = "normal")
}
