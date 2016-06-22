##' @title Sort downloaded and compiled data
##'
##' @description Sort downloaded html and compiled csv files into folders sorted by region.
##'
##' @param station character; the number of the station id number to process.
##'
##' @return none
##'
##' @author Conor I. Anderson
##' 
##' @export
##'  
##' @examples
##' \dontrun{sortFiles("000401")}

sortFiles <- function(station) {
  ## What is the name of the csv file?
  index <- senamhiR:::catalogue$StationID==station
  ## What region is the station from
  region <- as.character(senamhiR:::catalogue$Region[index])
  
  stationName <- as.character(senamhiR:::catalogue$Station[index])
  filename <- paste(as.character(station), " - ", stationName, ".csv", sep = "")
  
  if (!dir.exists(region)) dir.create(region)
  if (dir.exists(station)) file.rename(station, paste(region, station, sep = "/"))
  if (file.exists(filename)) file.rename(filename, paste(region, filename, sep = "/"))
}