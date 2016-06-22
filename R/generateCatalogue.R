##' @title A function to determine the full catalogue of available Peruvian National Hydrological and Meterological Service stations
##'
##' @description Generate a .rda file containing a list of all of the stations operated by Senamhi. You should not need to execute this function, as the data is already included in the package.
##'
##' @return catalogue.rda
##'
##' @author Conor I. Anderson
##'
##' @importFrom XML htmlTreeParse

generateCatalogue <- function () {
  
  vector <- seq(1, 25, by = 1)
  vector <- vector[-7]
  vector <- sprintf("%02d", vector)
  urlList <- paste("http://www.senamhi.gob.pe/include_mapas/_map_data_hist03.php?drEsta=", vector, sep = "")
  
  if (!dir.exists("catalogue data")) {
    check <- try(dir.create("catalogue data"))
    if (inherits(check, "try-error")) {
      stop("I couldn't write out the directory. Check your permissions.")
    }
  }
  
  Sys.setlocale('LC_ALL','C') 
  catalogue = NULL
  for (i in 1:length(vector)) {
    downloadAction(url = urlList[i], filename = paste("catalogue data/", vector[i], ".html", sep = ""))
    data <- htmlTreeParse(paste("catalogue data/", vector[i], ".html", sep = ""))
    data <- data[3]
    data <- unlist(data)
    data <- data[21]
    data <- strsplit(data, "var ubica")[[1]]
    j <- 2
    while (j <= length(data)) {
      row <- strsplit(data[j], ",")[[1]]
      name <- strsplit(row[3], " - ")[[1]]
      ## There are a couple of cases where the station name is formatted with a spaced hyphen
      if (length(name) == 3) name <- c(paste(name[1:2], collapse=" - "), name[3])
      row <- c(name, row[4:10])
      
      ## Commands to clean up the data
      row <- gsub("Meteorol&oacute;gica", "Meteorologica", row)
      row <- gsub("Hidrol&oacute;gica", "Hidrologica", row)
      row <- gsub("\303\221", 'N', row)
      row <- gsub("\321", 'N', row)
      row <- gsub("'", '', row)
      row <- gsub("\\\\", '', row)
      row <- gsub("));", '', row)
      row <- gsub("}\r\n}", '', row)
      row <- gsub("^\\s+|\\s+$", "", row)
      
      # Add it to the catalogue
      catalogue <- rbind(catalogue, row)
      j <- j+1
    }
    i <- i+1
    colnames(catalogue) <- c("Station", "StationID", "Type", "Configuration", "Latitude", "Longitude", "Region", "Province", "District")
  }
  rownames(catalogue) <- NULL
  catalogue <- as.data.frame(catalogue, stringsAsFactors = FALSE)
  save(catalogue, file = "catalogue.rda")
  return(catalogue)
}


