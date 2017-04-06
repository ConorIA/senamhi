##' @title [DEPRECATED] Generate Local Catalogue
##'
##' @description Generate or update a catalogue of locally downloaded stations.
##'
##' @param station character; optional character string to specify one or more stations.
##' @param localcatalogue character; optional character string to specify catalogue object to update.
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
    if (file.exists("local_catalogue.rda")) {
      load("local_catalogue.rda")
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
  row <- grep(station, catalogue$StationID)
  if (length(row) != 1) {
    stop("I could not identify the station. Please check the station number and try again.")
  }
  
  dat <- try(read_data(station), silent = TRUE)
  if (inherits(dat, "try-error")) {
    return(warning("There was an error checking that station. The file might not exist.", call. = FALSE, immediate. = TRUE))
  }
  
  if (is.na(localcatalogue$`Data Start`[row]) | localcatalogue$`Data Start`[row] != format(dat$Fecha[1], format = "%Y")) localcatalogue$`Data Start`[row] <- format(dat$Fecha[1], format = "%Y")
  if (is.na(localcatalogue$`Data End`[row]) | localcatalogue$`Data End`[row] != format(dat$Fecha[nrow(dat)], format = "%Y")) localcatalogue$`Data End`[row] <- format(dat$Fecha[nrow(dat)], format = "%Y")
  localcatalogue$`Period (Yr)`[row] <- 1 + as.numeric(localcatalogue$`Data End`[row]) - as.numeric(localcatalogue$`Data Start`[row])
  if (is.na(localcatalogue$Downloaded[row]) | localcatalogue$Downloaded[row] != "Yes") localcatalogue$Downloaded[row] <- "Yes"
  save(localcatalogue, file = "local_catalogue.rda", compress = "xz", compression_level = 9)
  return("Values updated.")
}