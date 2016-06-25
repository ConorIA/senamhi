##' @title Compile data from the Peruvian National Hydrological and Meterological Service
##'
##' @description Compile a CSV file of Peruvian historical climate data from the Senamhi web portal.
##'
##' @param station character; the number of the station id number to process.
##' @param type character; defines if the station is (CON)ventional, DAV, (SUT)ron, or (SIA)p. Must be "CON", "DAV", "SUT" or "SIA".
##' @param config character; defines if the station is (M)eterological (2) or (H)ydrological. Must be "M", "M2" or "H".
##' @param startYear numerical; the first year to process.
##' @param endYear numerical; the last year to process.
##' @param startMonth numerical; the first month to process. Defaults to 1.
##' @param endMonth numerical; the last month to process. Defaults to 12.
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
##' \dontrun{writeCSV("000401", type = "CON", config = "M", 1971, 2000, 1, 12)}

writeCSV <- function(station, type = "z", config = "z", startYear, endYear, startMonth = 1,        
                           endMonth = 12, writeMode = "z") {
  
  stationName <- catalogue$StationID==station
  stationName <- as.character(catalogue$Station[stationName])
  filename <- paste(as.character(station), " - ", stationName, ".csv", sep = "")
  
  if(file.exists(filename) & writeMode != "overwrite") {
    warning(paste("File ", filename, " exists. Not overwriting.", sep = ""), call. = FALSE, immediate. = TRUE)
    return()
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
  
  if (missing(station))
    station <- readline(prompt = "Enter station number: ")
  while (!(type == "CON" | type == "DAV" | type == "SIA" | type == "SUT"))
    type <- readline(prompt = "Must be one of CON, DAV, SUT, or SIA: ")
  while (!(config == "M" | config == "M1" | config == "M2" | config == "H"))
    config <- readline(prompt = "Must be one of M, M1, M2 or H: ")
  if (missing(startYear))
    startYear <- as.integer(readline(prompt = "Enter start year: "))
  if (missing(endYear))
    endYear <- as.integer(readline(prompt = "Enter end year: "))
  
  ## Generate the column names
  if (config == "H") {
    if (type == "CON") colnames <- c("Fecha", "Nivel06 (m)", "Nivel10 (m)", "Nivel14 (m)", "Nivel18 (m)", "Caudal (m\u00B3/s)")
    if (type == "SUT") colnames <- c("Fecha", "Tmean (\u00B0C)", "Tmax (\u00B0C)", "Tmin (\u00B0C)", "Humidity (%)", "Lluvia (mm)", "Presion (mb)", "Velocidad del Viento (m/s)", "Direccion del Viento", "Nivel Medio (m)")
  } else {
    if (type == "CON") colnames <- c("Fecha", "Tmax (\u00B0C)", "Tmin (\u00B0C)", "TBS07 (\u00B0C)", "TBS13 (\u00B0C)", "TBS19 (\u00B0C)", "TBH07 (\u00B0C)", "TBH13 (\u00B0C)", "TBH19 (\u00B0C)", "Prec07 (mm)", "Prec19 (mm)", "Direccion del Viento", "Velocidad del Viento (m/s)")
    if (type == "SUT" | type == "SIA" | type == "DAV") colnames <- c("Fecha", "Tmean (\u00B0C)", "Tmax (\u00B0C)", "Tmin (\u00B0C)", "Humedad (%)", "Lluvia (mm)", "Presion (mb)", "Velocidad del Viento (m/s)", "Direccion del Viento")
  }
  
  #GenFileList
  years <- seq(startYear, endYear)
  months <- seq(startMonth, endMonth)
  months <- sprintf("%02d", months)
  endMonth <- sprintf("%02d", endMonth)
  files <- apply(expand.grid(months, years), 1, function(x) paste(x[2], x[1], sep = ""))
  files <- paste(as.character(station), "/", files, ".html", sep = "")
  
  #GenDates
  datelist <- apply(expand.grid(months, years), 1, function(x) paste(x[2], x[1], sep = "-"))
  datelist <- paste(datelist, "01", sep = "-")
  
  startDate <- paste(startYear,startMonth,1, sep = "-")
  endDate <- as.Date(paste0(endYear, "-", endMonth, "-01"), format = "%Y-%m-%d")
  endDate <- paste(endYear,endMonth,numberOfDays(endDate), sep = "-")
  
  numberOfDates <- as.Date(endDate) - as.Date(startDate)
  numberOfDates <- as.numeric(numberOfDates) + 1
  datecolumn <- seq(as.Date(startDate), by = "day", length.out = numberOfDates)
  DF <- matrix(nrow = length(datecolumn), ncol = length(colnames))
  DF <- as.data.frame(DF)
  names(DF) <- colnames
  DF$Fecha <- datecolumn
  
  ## Loop through files and input data to table
  row <- 1
  i <- 1
  for (i in 1:length(files)) {
    date <- as.Date(datelist[i], format = "%Y-%m-%d")
    table <- readHTMLTable(files[i], stringsAsFactors = FALSE)
    table <- as.data.frame(table[1])
    if (nrow(table) > 1) {
      ## Sometimes the HTML files only have a few days, instead of the whole month
      if (nrow(table)-1 != numberOfDays(date)) {
        table <- table[-1,]
        j <- 1
        while (j <= nrow(table)) {
          datadate <- as.character(table[j,1])
          datadate <- strsplit(datadate, split = "-")[[1]]
          datadate <- as.numeric(datadate[1])
          thisrow <- row + datadate - 1
          DF[thisrow, 2:length(DF)] <- table[j,2:ncol(table)]
          j <- j+1
        }
      }
      else {
        ## This case hasn't been encountered by the new script. TO DO!
        if (ncol(table) != length(colnames)) {
          ## Assuming that this only happens with precipitation for now.
          table <- table[-1,]
          DF$`Prec07 (mm)`[row:(row+nrow(table)-1)] <- table[,2]
          DF$`Prec19 (mm)`[row:(row+nrow(table)-1)] <- table[,3]
        } else {
          DF[row:(row+numberOfDays(date)-1),2:length(DF)] <- subset(table[2:length(table[, 1]), 2:length(table)])
        }
      }
    } 
    row <- row+numberOfDays(date)
    ++i
  }
  if (writeMode == "append") write.table(data, filename, append = TRUE, sep = ",", col.names = FALSE,row.names = FALSE)
  else write.table(DF, filename, sep = ",", row.names = FALSE)
}
