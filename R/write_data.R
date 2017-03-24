##' @title Compile data from the Peruvian National Hydrological and Meterological Service
##'
##' @description Compile a CSV file of Peruvian historical climate data from the Senamhi web portal.
##'
##' @param station character; the station id number to process.
##' @param year numerical; a vector of years to process.
##' @param write_mode character; if set to 'append', the script will append the data to an exisiting file; if set to 'overwrite', it will overwrite an existing file. If not set, it will not overwrite.
##' @param trim logical; if set to TRUE, the script will trim missing data from the start and end of the data set. Note only completely missing years will be trimmed.
##' @param clean logical; if set to TRUE, the script will delete all of the downloaded HTML files.
##'
##' @return None
##'
##' @author Conor I. Anderson
##'
##' @importFrom XML readHTMLTable
##' @importFrom tibble as_tibble has_name
##' @importFrom utils setTxtProgressBar txtProgressBar
##' @importFrom readr write_csv
##'
##' @export
##'
##' @examples
##' \dontrun{write_data('000401', 2000:2005, trim = TRUE)}

write_data <- function(station, year, write_mode = "z", trim = TRUE, clean = FALSE) {
  
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
        "Caudal (m^3/s)")
    if (type == "SUT") 
      colnames <- c("Fecha", "Tmean (C)", "Tmax (C)", "Tmin (C)", "Humidity (%)", 
        "Lluvia (mm)", "Presion (mb)", "Velocidad del Viento (m/s)", "Direccion del Viento", 
        "Nivel Medio (m)")
  } else {
    if (type == "CON") 
      colnames <- c("Fecha", "Tmax (C)", "Tmin (C)", "TBS07 (C)", "TBS13 (C)", 
        "TBS19 (C)", "TBH07 (C)", "TBH13 (C)", "TBH19 (C)", "Prec07 (mm)", 
        "Prec19 (mm)", "Direccion del Viento", "Velocidad del Viento (m/s)")
    if (type == "SUT" | type == "SIA" | type == "DAV") 
      colnames <- c("Fecha", "Tmean (C)", "Tmax (C)", "Tmin (C)", "Humedad (%)", 
        "Lluvia (mm)", "Presion (mb)", "Velocidad del Viento (m/s)", "Direccion del Viento")
  }
  
  # GenFileList
  month <- sprintf("%02d", 1:12)
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
  
  number_of_dates <- as.numeric(as.Date(endDate) - as.Date(startDate)) + 1
  datecolumn <- seq(as.Date(startDate), by = "day", length.out = number_of_dates)
  
  dat <- as_tibble(matrix(nrow = length(datecolumn), ncol = length(colnames)))
  names(dat) <- colnames
  dat$Fecha <- datecolumn
  row <- 1
  
  print("Compiling data.")
  prog <- txtProgressBar(min = 0, max = length(files), style = 3)
  on.exit(close(prog))
  
  ## Loop through files and input data to table
  for (i in 1:length(files)) {
    date <- as.Date(datelist[i], format = "%Y-%m-%d")
    table <- try(readHTMLTable(files[i], stringsAsFactors = FALSE))
    if (inherits(table, "try-error")) {
      stop("Could not read the requested file. Are you sure you downloaded it?")
    }
    table <- as_tibble(table[[1]])
    if (nrow(table) > 1) {
      ## Sometimes the HTML files only have a few days, instead of the whole month
      if (nrow(table) - 1 != number_of_days(date)) {
        table <- table[-1, ]
        for (j in 1:nrow(table)) {
          datadate <- as.character(table[j, 1])
          datadate <- strsplit(datadate, split = "-")[[1]]
          datadate <- as.numeric(datadate[1])
          thisrow <- row + datadate - 1
          if (!is.na(thisrow)) dat[thisrow, 2:length(dat)] <- table[j, 2:ncol(table)]
        }
      } else {
        # Sometimes the HTML files only have a subset of the columns
        if (ncol(table) != length(colnames)) {
          ## Assuming that this only happens with precipitation for now.
          table <- table[-1, ]
          dat$`Prec07 (mm)`[row:(row + nrow(table) - 1)] <- table[[2]]
          dat$`Prec19 (mm)`[row:(row + nrow(table) - 1)] <- table[[3]]
        } else {
          dat[row:(row + number_of_days(date) - 1), 2:ncol(dat)] <- table[2:nrow(table),2:ncol(table)]
        }
      }
    }
    row <- row + number_of_days(date)
    setTxtProgressBar(prog, value = i)
  }
  
  # Replace missing value codes
  for (col in 2:ncol(dat)) {
    badrows <- which(dat[[col]] %in% list("", -999, -888))
    dat[badrows,col] <- NA
  }
  
  # Make sure that the columns are the right type
  dat$Fecha <- as.Date(dat$Fecha, format = "%Y-%m-%d")
  if (config == "H") {
    if (type == "CON") {
      dat$`Nivel06 (m)` <- as.numeric(dat$`Nivel06 (m)`)
      dat$`Nivel10 (m)` <- as.numeric(dat$`Nivel10 (m)`)
      dat$`Nivel14 (m)` <- as.numeric(dat$`Nivel14 (m)`)
      dat$`Nivel18 (m)` <- as.numeric(dat$`Nivel18 (m)`)
      dat$`Caudal (m^3/s)` <- as.numeric(dat$`Caudal (m^3/s)`)
    } else {
      dat$`Tmean (C)` <- as.numeric(dat$`Tmean (C)`)
      dat$`Tmax (C)` <- as.numeric(dat$`Tmax (C)`)
      dat$`Tmin (C)` <- as.numeric(dat$`Tmin (C)`)
      dat$`Humidity (%)` <- as.numeric(dat$`Humidity (%)`)
      dat$`Lluvia (mm)` <- as.numeric(dat$`Lluvia (mm)`)
      dat$`Presion (mb)` <- as.numeric(dat$`Presion (mb)`)
      dat$`Direccion del Viento` <- as.character(dat$`Direccion del Viento`)
      dat$`Nivel Medio (m)` <- as.numeric(dat$`Nivel Medio (m)`)
    }
  } else {
    if (type == "CON") {
      dat$`Tmax (C)` <- as.numeric(dat$`Tmax (C)`)
      dat$`Tmin (C)` <- as.numeric(dat$`Tmin (C)`) 
      dat$`TBS07 (C)` <- as.numeric(dat$`TBS07 (C)`)
      dat$`TBS13 (C)` <- as.numeric(dat$`TBS13 (C)`)
      dat$`TBS19 (C)` <- as.numeric(dat$`TBS19 (C)`)
      dat$`TBH07 (C)` <- as.numeric(dat$`TBH07 (C)`)
      dat$`TBH13 (C)` <- as.numeric(dat$`TBH13 (C)`)
      dat$`TBH19 (C)` <- as.numeric(dat$`TBH19 (C)`)
      dat$`Prec07 (mm)` <- as.numeric(dat$`Prec07 (mm)`)
      dat$`Prec19 (mm)` <- as.numeric(dat$`Prec19 (mm)`)
      dat$`Direccion del Viento` <- as.character(dat$`Direccion del Viento`)
      dat <- add_column(dat, `Tmean (C)` = round(((dat$`Tmax (C)` + dat$`Tmin (C)`)/2), digits = 1), .after = 1)
    }
    if (type == "SUT" | type == "SIA" | type == "DAV") {
      dat$`Tmean (C)` <- as.numeric(dat$`Tmean (C)`)
      dat$`Tmax (C)` <- as.numeric(dat$`Tmax (C)`)
      dat$`Tmin (C)` <- as.numeric(dat$`Tmin (C)`)
      dat$`Humedad (%)` <- as.numeric(dat$`Humedad (%)`)
      dat$`Lluvia (mm)` <- as.numeric(dat$`Lluvia (mm)`)
      dat$`Presion (mb)` <- as.numeric(dat$`Presion (mb)`)
      dat$`Direccion del Viento` <- as.character(dat$`Direccion del Viento`)
    }
  }
  if (has_name(dat, "Velocidad del Viento (m/s)")) {
    if (length(grep(".", dat$`Velocidad del Viento (m/s)`, fixed = TRUE)) > 0) {
      dat$`Velocidad del Viento (m/s)` <- as.double(dat$`Velocidad del Viento (m/s)`)
    } else {
      dat$`Velocidad del Viento (m/s)` <- as.integer(dat$`Velocidad del Viento (m/s)`)
    }
  }
  
  if (trim) {
    dat <- try(.trim_data(dat))
    if (inherits(dat, "try-error")) {
      return("There is no good data in this file.")
    }
  }
  if (clean) unlink(files)
  
  if (write_mode == "append") {
      write_csv(dat, filename, append = TRUE)
  } else {
      write_csv(dat, filename)
  }
}
