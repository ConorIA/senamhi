##' @title Generate Local Catalogue
##'
##' @description Generate or update a catalogue of locally downloaded stations.
##'
##' @param station character; optional character string to specify one or more stations.
##' @param localcatalogue character; optional character string to specify catalogue object to update. by region.
##'
##' @return A data frame containing the details of matching stations.
##' 
##' @importFrom readr read_csv 
##' @importFrom tibble add_column has_name
##' 
##' @export
##'
##' @author Conor I. Anderson
##'
##' @examples
##' # Update catalogue information for 'Tarapoto'.
##' \dontrun{generate_local_catalogue("000401")}
##' 

generate_local_catalogue <- function(station, localcatalogue){
  
  if (missing(localcatalogue)) {
    if (file.exists("localCatalogue.rda")) {
      load("localCatalogue.rda")
    } else {
      localcatalogue <- as_tibble(catalogue)
      localcatalogue <- add_column(localcatalogue, `Period (Yr)` = rep(NA, nrow(localcatalogue)), .after = 6)
      localcatalogue <- add_column(localcatalogue, Downloaded = rep(NA, nrow(localcatalogue)))
    }
  }
  
  if (missing(station)) {
    print("No station specified, looking for all stations. This may take a while!")
    station <- localcatalogue$StationID
  }
  
  if (length(station) > 1){
    lapply(station, generate_local_catalogue)
    return("Bulk action finished.")
  }
  
  print(paste0("Checking station ", station, "...")  )
  row <- grep(station, localcatalogue$StationID)
  region <- localcatalogue$Region[row]
  stationName <- localcatalogue$Station[row]
  filename <- paste0(region, "/", station, " - ", stationName, ".csv")

  ## Generate the column types
  if (localcatalogue$Configuration[row] == "H") {
    if (localcatalogue$Type[row] == "CON") 
      types <- "Dddddd"
    if (localcatalogue$Type[row] == "SUT") 
      types <- "Dddddddccd"
  } else {
    if (localcatalogue$Type[row] == "CON") 
      types <- "Ddddddddddddcc"
    if (localcatalogue$Type[row] == "SUT" | localcatalogue$Type[row] == "SIA" | localcatalogue$Type[row] == "DAV") 
      types <- "Dddddddcc"
  }
  
  dat  <- try(read_csv(filename, col_types = types))
  if (inherits(dat, "try-error")) {
    return("I could not read the file. Check station number.")
  }
  
  if (has_name(dat, "Velocidad del Viento (m/s)")) {
    if (length(grep(".", dat$`Velocidad del Viento (m/s)`, fixed = TRUE)) > 0) {
      dat$`Velocidad del Viento (m/s)` <- as.double(dat$`Velocidad del Viento (m/s)`)
    } else {
      dat$`Velocidad del Viento (m/s)` <- as.integer(dat$`Velocidad del Viento (m/s)`)
    }
  }
  
  if (is.na(localcatalogue$`Data Start`[row]) | localcatalogue$`Data Start`[row] != format(dat$Fecha[1], format = "%Y")) localcatalogue$`Data Start`[row] <- format(dat$Fecha[1], format = "%Y")
  if (is.na(localcatalogue$`Data End`[row]) | localcatalogue$`Data End`[row] != format(dat$Fecha[nrow(dat)], format = "%Y")) localcatalogue$`Data End`[row] <- format(dat$Fecha[nrow(dat)], format = "%Y")
  localcatalogue$`Period (Yr)`[row] <- 1 + as.numeric(localcatalogue$`Data End`[row]) - as.numeric(localcatalogue$`Data Start`[row])
  if (is.na(localcatalogue$Downloaded[row]) | localcatalogue$Downloaded[row] != "Yes") localcatalogue$Downloaded[row] <- "Yes"
  save(localcatalogue, file = "localCatalogue.rda")
  return("Values updated.")
}