##' @title A function to determine the full catalogue of available Peruvian National Hydrological and Meterological Service stations
##'
##' @description Generate a .rda file containing a list of all of the stations operated by Senamhi.
##'
##' @return catalogue.rda
##'
##' @export
##'
##' @author Conor I. Anderson
##'
##' @examples
##' senamhiCatalogue()

senamhiCatalogue <- function () {
  vector <- seq(1, 25, by = 1)
  vector <- vector[-7]
  vector <- sprintf("%02d", vector)
  urlList <- paste("http://www.senamhi.gob.pe/include_mapas/_map_data_hist03.php?drEsta=", vector, sep = "")
  
  if (!dir.exists("data")) {
    check <- try(dir.create("data"))
    if (inherits(check, "try-error")) {
      stop("I couldn't write out the directory. Check your permissions.")
    }
  }

  df = NULL
  Sys.setlocale('LC_ALL','C') 
  for (i in 1:length(vector)) {
    test <- file.exists(paste("data/", vector[i], ".html", sep = ""))
    if (!test) curl_download(urlList[i], paste("data/", vector[i], ".html", sep = ""))
    data <- htmlTreeParse(paste("data/", vector[i], ".html", sep = ""))
    data <- data[3]
    data <- unlist(data)
    data <- data[21]
    data <- strsplit(data, "var ubica")[[1]]
    j <- 2
    while (j <= length(data)) {
      row <- strsplit(data[j], ",")[[1]]
      name <- strsplit(row[3], "-")[[1]]
      row <- c(name, row[6:10], row[12:13])
      row <- gsub("'", '', row)
      row <- gsub("\\\\", '', row)
      row <- gsub("));", '', row)
      row <- gsub("}\r\n}", '', row)
      row <- gsub("^\\s+|\\s+$", "", row)
      df <- rbind(df, row)
      j <- j+1
    }
    i <- i+1
    colnames(df) <- c("Station", "StationID", "Lat", "Lon", "Region", "Provincia", "Local", "Class", "Type")
  }
  save(df, file = "catalogue.rda")
  return(df)
}


