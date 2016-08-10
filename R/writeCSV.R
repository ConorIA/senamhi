##' @title Compile data from the Peruvian National Hydrological and Meterological Service
##'
##' @description Compile a CSV file of Peruvian historical climate data from the Senamhi web portal.
##'
##' @param station character; the station id number to process.
##' @param year numerical; a vector of years to process.
##' @param month numerical; a vector of months to process. Defaults to 1:12.
##' @param writeMode character; if set to 'append', the script will append the data to an exisiting file; if set to 'overwrite', it will overwrite an existing file. If not set, it will not overwrite.
##'
##' @return None
##'
##' @author Conor I. Anderson
##'
##' @importFrom XML readHTMLTable
##' @importFrom utils write.table
##'
##' @export
##'
##' @examples
##' \dontrun{writeCSV("000401", 2000:2005, 1:12)}

writeCSV <- function(station, year, month = 1:12, writeMode = "z") {
  
  stationData <- catalogue[catalogue$StationID==station,]
  type = stationData$Type
  config = stationData$Configuration
  
  stationName <- stationData$Station
  region <- stationData$Region
  filename <- paste0(region, "/", as.character(station), " - ", stationName, ".csv")
  
  if(file.exists(filename) && writeMode != "overwrite" && writeMode != "append") {
    return(warning(paste("File", filename, "exists. Not overwriting."), call. = FALSE, immediate. = TRUE))
  }
  
  # This snippet of code from Stack Overflow user Grzegorz Szpetkowski at
  # http://stackoverflow.com/questions/6243088/find-out-the-number-of-days-of-a-month-in-r
  
  numberOfDays <- function(date) {
    m <- format(date, format = "%m")
    while (format(date, format = "%m") == m) {
      date <- date + 1
    }
    return(as.integer(format(date - 1, format = "%d")))
  }
  ##--------------------------------------------------------------------------------------
  
  ## Generate the column names
  if (config == "H") {
    if (type == "CON") colnames <- c("Fecha", "Nivel06 (m)", "Nivel10 (m)", "Nivel14 (m)", "Nivel18 (m)", "Caudal (m\u00B3/s)")
    if (type == "SUT") colnames <- c("Fecha", "Tmean (\u00B0C)", "Tmax (\u00B0C)", "Tmin (\u00B0C)", "Humidity (%)", "Lluvia (mm)", "Presion (mb)", "Velocidad del Viento (m/s)", "Direccion del Viento", "Nivel Medio (m)")
  } else {
    if (type == "CON") colnames <- c("Fecha", "Tmax (\u00B0C)", "Tmin (\u00B0C)", "TBS07 (\u00B0C)", "TBS13 (\u00B0C)", "TBS19 (\u00B0C)", "TBH07 (\u00B0C)", "TBH13 (\u00B0C)", "TBH19 (\u00B0C)", "Prec07 (mm)", "Prec19 (mm)", "Direccion del Viento", "Velocidad del Viento (m/s)")
    if (type == "SUT" | type == "SIA" | type == "DAV") colnames <- c("Fecha", "Tmean (\u00B0C)", "Tmax (\u00B0C)", "Tmin (\u00B0C)", "Humedad (%)", "Lluvia (mm)", "Presion (mb)", "Velocidad del Viento (m/s)", "Direccion del Viento")
  }
  
  #GenFileList
  month <- sprintf("%02d", month)
  files <- apply(expand.grid(month, year), 1, function(x) paste0(x[2], x[1]))
  files <- paste0(region, "/HTML/", as.character(station), " - ", stationName, "/", files, ".html")
  
  #GenDates
  datelist <- apply(expand.grid(month, year), 1, function(x) paste(x[2], x[1], sep = "-"))
  datelist <- paste(datelist, "01", sep = "-")
  
  startDate <- paste(year[1],month[1],1, sep = "-")
  endDate <- as.Date(paste0(year[length(year)], "-", month[length(month)], "-01"), format = "%Y-%m-%d")
  endDate <- paste(year[length(year)],month[length(month)],numberOfDays(endDate), sep = "-")
  
  numberOfDates <- as.Date(endDate) - as.Date(startDate)
  numberOfDates <- as.numeric(numberOfDates) + 1
  datecolumn <- seq(as.Date(startDate), by = "day", length.out = numberOfDates)
  dat <- matrix(nrow = length(datecolumn), ncol = length(colnames))
  dat <- as.data.frame(dat)
  names(dat) <- colnames
  dat$Fecha <- datecolumn
  row <- 1
  
  ## Loop through files and input data to table
  for (i in 1:length(files)) {
    date <- as.Date(datelist[i], format = "%Y-%m-%d")
    table <- readHTMLTable(files[i], stringsAsFactors = FALSE)
    table <- as.data.frame(table[1])
    if (nrow(table) > 1) {
      ## Sometimes the HTML files only have a few days, instead of the whole month
      if (nrow(table)-1 != numberOfDays(date)) {
        table <- table[-1,]
        for (j in 1:nrow(table)) {
          datadate <- as.character(table[j,1])
          datadate <- strsplit(datadate, split = "-")[[1]]
          datadate <- as.numeric(datadate[1])
          thisrow <- row + datadate - 1
          dat[thisrow, 2:length(dat)] <- table[j,2:ncol(table)]
        }
      }
      else {
        ## This case hasn't been encountered by the new script. TO DO!
        if (ncol(table) != length(colnames)) {
          ## Assuming that this only happens with precipitation for now.
          table <- table[-1,]
          dat$`Prec07 (mm)`[row:(row+nrow(table)-1)] <- table[,2]
          dat$`Prec19 (mm)`[row:(row+nrow(table)-1)] <- table[,3]
        } else {
          dat[row:(row+numberOfDays(date)-1),2:length(dat)] <- subset(table[2:length(table[, 1]), 2:length(table)])
        }
      }
    } 
    row <- row+numberOfDays(date)
  }
  
  ## Add more useful date information
  Anho <- format(dat$Fecha, format = "%Y")
  Mes <- format(dat$Fecha, format = "%m")
  Dia <- format(dat$Fecha, format = "%d")
  dat <- cbind(dat[1], Anho, Mes, Dia, dat[2:ncol(dat)])
  
  if (writeMode == "append") write.table(dat, filename, append = TRUE, sep = ",", col.names = FALSE,row.names = FALSE)
  else write.table(dat, filename, sep = ",", row.names = FALSE)
}
