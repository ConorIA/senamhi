##' @title Compile data from the Peruvian National Hydrological and Meterological Service
##'
##' @description Compile a CSV file of Peruvian historical climate data from the Senamhi web portal.
##'
##' @param station character; the station id number to process.
##' @param year numerical; a vector of years to process.
##' @param month numerical; a vector of months to process. Defaults to 1:12.
##' @param write_mode character; if set to 'append', the script will append the data to an exisiting file; if set to 'overwrite', it will overwrite an existing file. If not set, it will not overwrite.
##' @param trim logical; if set to TRUE, the script will trim missing data from the start and end of the data set. Note only completely missing years will be trimmed.
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
##' \dontrun{export_data('000401', 2000:2005, 1:12, trim = TRUE)}

export_data <- function(station, year, month = 1:12, write_mode = "z", trim = TRUE) {
  
  station_data <- catalogue[catalogue$StationID == station, ]
  type = station_data$Type
  config = station_data$Configuration
  
  station_name <- station_data$Station
  region <- station_data$Region
  filename <- paste0(region, "/", as.character(station), " - ", station_name, ".csv")
  
  if (file.exists(filename) && write_mode != "overwrite" && write_mode != "append") {
    return(warning(paste("File", filename, "exists. Not overwriting."), call. = FALSE, 
      immediate. = TRUE))
  }
  
  # This snippet of code from Stack Overflow user Grzegorz Szpetkowski at
  # http://stackoverflow.com/questions/6243088/find-out-the-number-of-days-of-a-month-in-r
  
  number_of_days <- function(date) {
    m <- format(date, format = "%m")
    while (format(date, format = "%m") == m) {
      date <- date + 1
    }
    return(as.integer(format(date - 1, format = "%d")))
  }
  ##--------------------------------------------------------------------------------------
  
  ## Generate the column names
  if (config == "H") {
    if (type == "CON") 
      colnames <- c("Fecha", "Nivel06 (m)", "Nivel10 (m)", "Nivel14 (m)", "Nivel18 (m)", 
        "Caudal (m³/s)")
    if (type == "SUT") 
      colnames <- c("Fecha", "Tmean (°C)", "Tmax (°C)", "Tmin (°C)", "Humidity (%)", 
        "Lluvia (mm)", "Presion (mb)", "Velocidad del Viento (m/s)", "Direccion del Viento", 
        "Nivel Medio (m)")
  } else {
    if (type == "CON") 
      colnames <- c("Fecha", "Tmax (°C)", "Tmin (°C)", "TBS07 (°C)", "TBS13 (°C)", 
        "TBS19 (°C)", "TBH07 (°C)", "TBH13 (°C)", "TBH19 (°C)", "Prec07 (mm)", 
        "Prec19 (mm)", "Direccion del Viento", "Velocidad del Viento (m/s)")
    if (type == "SUT" | type == "SIA" | type == "DAV") 
      colnames <- c("Fecha", "Tmean (°C)", "Tmax (°C)", "Tmin (°C)", "Humedad (%)", 
        "Lluvia (mm)", "Presion (mb)", "Velocidad del Viento (m/s)", "Direccion del Viento")
  }
  
  # GenFileList
  month <- sprintf("%02d", month)
  files <- apply(expand.grid(month, year), 1, function(x) paste0(x[2], x[1]))
  files <- paste0(region, "/HTML/", as.character(station), " - ", station_name, 
    "/", files, ".html")
  
  # GenDates
  datelist <- apply(expand.grid(month, year), 1, function(x) paste(x[2], x[1], 
    sep = "-"))
  datelist <- paste(datelist, "01", sep = "-")
  
  startDate <- paste(year[1], month[1], 1, sep = "-")
  endDate <- as.Date(paste0(year[length(year)], "-", month[length(month)], "-01"), 
    format = "%Y-%m-%d")
  endDate <- paste(year[length(year)], month[length(month)], number_of_days(endDate), 
    sep = "-")
  
  number_of_dates <- as.Date(endDate) - as.Date(startDate)
  number_of_dates <- as.numeric(number_of_dates) + 1
  datecolumn <- seq(as.Date(startDate), by = "day", length.out = number_of_dates)
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
      if (nrow(table) - 1 != number_of_days(date)) {
        table <- table[-1, ]
        for (j in 1:nrow(table)) {
          datadate <- as.character(table[j, 1])
          datadate <- strsplit(datadate, split = "-")[[1]]
          datadate <- as.numeric(datadate[1])
          thisrow <- row + datadate - 1
          dat[thisrow, 2:length(dat)] <- table[j, 2:ncol(table)]
        }
      } else {
        ## This case hasn't been encountered by the new script. TO DO!
        if (ncol(table) != length(colnames)) {
          ## Assuming that this only happens with precipitation for now.
          table <- table[-1, ]
          dat$`Prec07 (mm)`[row:(row + nrow(table) - 1)] <- table[, 2]
          dat$`Prec19 (mm)`[row:(row + nrow(table) - 1)] <- table[, 3]
        } else {
          dat[row:(row + number_of_days(date) - 1), 2:length(dat)] <- subset(table[2:length(table[, 
          1]), 2:length(table)])
        }
      }
    }
    row <- row + number_of_days(date)
  }
  
  ## Add more useful date information
  Anho <- format(dat$Fecha, format = "%Y")
  Mes <- format(dat$Fecha, format = "%m")
  Dia <- format(dat$Fecha, format = "%d")
  dat <- cbind(dat[1], Anho, Mes, Dia, dat[2:ncol(dat)], stringsAsFactors = FALSE)
  
  if (trim) dat <- .trim_data(dat)
  
  if (write_mode == "append") {
    write.table(dat, filename, append = TRUE, sep = ",", col.names = FALSE, row.names = FALSE)
  } else {
    write.table(dat, filename, sep = ",", row.names = FALSE)
  }
}
