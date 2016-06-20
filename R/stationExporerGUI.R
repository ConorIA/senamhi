##' @title A Shiny interface to Senamhi weather and river stations
##'
##' @description A function to launch a shiny web app to explore Senamhi stations.
##'
##' @return none
##' 
##' @author Conor I. Anderson
##'
##' @export

stationExplorerGUI <- function() {
  if ("shiny" %in% rownames(installed.packages()) == FALSE | "DT" %in% rownames(installed.packages()) == FALSE) {
    cat("This optional function requires the shiny and DT packages. \n")
    res <- readline(prompt = "Do you want to install them now? (y/N) ")
    if (res == "y") {
      install <- NULL
      if ("shiny" %in% rownames(installed.packages()) == FALSE) install <- c(install, "shiny")
      if ("DT" %in% rownames(installed.packages()) == FALSE) install <- c(install, "DT")
      install.packages(install)
    } else {
      stop("Cannot continue without the required packages.", call. = FALSE)
    }
  }
  appDir <- system.file("shiny", "ShinyStationExplorer", package = "senamhiR")
  if (appDir == "") {
    stop("Could not find the shiny directory. Try re-installing `senamhiR`.", call. = FALSE)
  }
  shiny::runApp(appDir, display.mode = "normal")
}
