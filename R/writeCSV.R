##' @title Compile data from the Peruvian National Hydrological and Meterological Service
##'
##' @description Compile as CSV file of Peruvian historical climate data from the Senamhi web portal.
##'
##' @param station numerical; the number of the station id number to process.
##' @param type character; defines if the station is (CON)ventional, DAV, (SUT)ron, or (SIA)p. Must be "CON", "DAV", "SUT" or "SIA".
##' @param config character; defines if the station is (M)eterological (2) or (H)ydrological. Must be "M", "M2" or "H".
##' @param startYear numerical; the first year to process.
##' @param endYear numerical; the last year to process.
##' @param startMonth numerical; the first month to process. Defaults to 1.
##' @param endMonth numerical; the last month to process. Defaults to 12.
##' @param overwrite logical; if true, the script will overwrite the compiled csv file if it exists.
##' @param append logical; if true, the script will append the data to an exisiting file, otherwise it will overwrite.
##' @param custom logical; if true, the script will provide the opportunity to manually enter column headers.
##'
##' @return None
##'
##' @author Conor I. Anderson
##'
##' @importFrom XML readHTMLTable
##'
##' @export
##'
##' @examples
##' writeCSV()
##' writeCSV(000401, type = "CON", config = "M", 1971, 2000, 1, 12)

writeCSV <- function(station, type = "z", config = "z", startYear, endYear, startMonth = 1, endMonth = 12,
                            overwrite = FALSE, append = FALSE, custom = FALSE) {
  
  stationName <- senamhi:::catalogue$StationID==station
  stationName <- as.character(senamhi:::catalogue$Station[stationName])
  filename <- paste(as.character(station), " - ", stationName, ".csv", sep = "")
  
  if(file.exists(filename) & !overwrite) {
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

  data <- data.frame()

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

  #GenFileList
  years <- seq(startYear, endYear)
  months <- seq(startMonth, endMonth)
  months <- sprintf("%02d", months)
  files <- apply(expand.grid(months, years), 1, function(x) paste(x[2], x[1], sep = ""))
  files <- paste(as.character(station), "/", files, ".html", sep = "")

  #GenDates
  datelist <- apply(expand.grid(months, years), 1, function(x) paste(x[2], x[1], sep = "-"))
  datelist <- paste(datelist, "01", sep = "-")

  ## Code to handle custom column headers (for inactive stations, for example)
  ## Use the argument "custom = TRUE" to activate this functionality

  if (custom == TRUE) {
    colnames <- NULL
    print("Please enter custom column names. Leave blank to stop.")
    c = 1
    while (c > 0) {
      colname <- readline(prompt = (paste("Column ", c, ": ", sep = "")))
      if (colname != "") {
        colnames <- c(colnames, colname)
        c <- c + 1
      } else
        c = 0
    }
  } else { ## If we want to try a built-in template (but there are a lot of combinations)
    if (config == "H") {
      if (type == "CON") colnames <- c("Fecha", "Nivel06 (m)", "Nivel10 (m)", "Nivel14 (m)", "Nivel18 (m)", "Caudal (m³/s)")
      if (type == "SUT") colnames <- c("Fecha", "Tmean (°C)", "Tmax (°C)", "Tmin (°C)", "Humidity (%)", "Lluvia (mm)", "Presion (mb)", "Velocidad del Viento (m/s)", "Direccion del Viento", "Nivel Medio (m)")
    } else {
      if (type == "CON") colnames <- c("Fecha", "Tmax (°C)", "Tmin (°C)", "TBS07 (°C)", "TBS13 (°C)", "TBS19 (°C)", "TBH07 (°C)", "TBH13 (°C)", "TBH19 (°C)", "Prec07 (mm)", "Prec19 (mm)", "Direccion del Viento", "Velocidad del Viento (m/s)")
      if (type == "SUT" | type == "SIA") colnames <- c("Fecha", "Tmean (°C)", "Tmax (°C)", "Tmin (°C)", "Humedad (%)", "Lluvia (mm)", "Presion (mb)", "Velocidad del Viento (m/s)", "Direccion del Viento")
    }
  }

  i = 1
  for (i in 1:length(files)) {
    date <- as.Date(datelist[i], format = "%Y-%m-%d")
    datecolumn <- seq(date, by = 1, length.out = numberOfDays(date))
    table <- readHTMLTable(files[i], stringsAsFactors = FALSE)
    table <- as.data.frame(table[1])
    if (nrow(table) > 1) {
      if (nrow(table)-1 != length(datecolumn)) {
        table2 <- table[-1,]
        table <- matrix(data = as.character("NA"), nrow = length(datecolumn), ncol = (length(colnames) - 1))
        table <- cbind(datecolumn, as.data.frame(table, stringsAsFactors = FALSE))
        j <- 1
        while (j <= nrow(table2)) {
          datadate <- as.character(table2[j,1])
          datadate <- strsplit(datadate, split = "-")[[1]]
          datadate <- datadate[1]
          datadate <- sprintf("%02d", as.numeric(datadate))
          index <- format(datecolumn, "%d") == datadate
          thisrow <- c(as.character(datecolumn[index]), table2[j,2:ncol(table2)])
          table[index,] <- thisrow
          j <- j+1
          } 
        }
        else {
          if (ncol(table) != length(colnames)) {
            ## Assuming that this only happens with precipitation for now.
            table2 <- table[-1,]
            table <- matrix(data = as.character("NA"), nrow = length(datecolumn), ncol = (length(colnames)-1))
            table <- cbind(datecolumn, as.data.frame(table, stringsAsFactors = FALSE))
            table[,10] <- table2[,2]
            table[,11] <- table2[,3]
          } else {
            table <- subset(table[2:length(table[, 1]), 2:length(table)])
            table <- cbind(datecolumn, table)
          }
        }
    } else {
      table <- matrix("NA", nrow = length(datecolumn), ncol = (length(colnames) - 1))
      table <- cbind(datecolumn, as.data.frame(table))
    }
    names(table) <- names(data)
    data <- rbind(data, table)
    ++i
  }
  names(data) <- (colnames)
  if (append == TRUE) write.table(data, filename, append = TRUE, sep = ",", col.names = FALSE,row.names = FALSE)
  else write.table(data, filename, sep = ",", row.names = FALSE)
}
