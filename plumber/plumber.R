library(plumber)
library(DBI)
library(RMySQL)
library(tibble)
library(storr)

source("plumber_settings.R")

st_pcd <- storr_rds("/data/pcd/")

.clean_table <- function(datain, config, type, clean_names = FALSE, remove_missing = FALSE, fix_types = FALSE) {
  
  if (clean_names) {
    ## Generate the column names
    if (config == "H") {
      if (type == "CON") 
        colnames <- c("Fecha", "Nivel06 (m)", "Nivel10 (m)", "Nivel14 (m)", "Nivel18 (m)", 
                      "Caudal (m^3/s)")
      if (type == "SUT") 
        colnames <- c("Fecha", "Tmean (C)", "Tmax (C)", "Tmin (C)", "Humedad (%)", 
                      "Lluvia (mm)", "Presion (mb)", "Velocidad del Viento (m/s)", "Direccion del Viento", 
                      "Nivel Medio (m)")
    } else {
      if (type == "CON") {
        colnames <- c("Fecha", "Tmean (C)", "Tmax (C)", "Tmin (C)", "TBS07 (C)", "TBS13 (C)", 
                      "TBS19 (C)", "TBH07 (C)", "TBH13 (C)", "TBH19 (C)", "Prec07 (mm)", 
                      "Prec19 (mm)", "Direccion del Viento", "Velocidad del Viento (m/s)")
        if (missing(datain) || ncol(datain) == 13) colnames <- colnames[-2]
      }
      if (type == "SUT" | type == "SIA" | type == "DAV") 
        colnames <- c("Fecha", "Tmean (C)", "Tmax (C)", "Tmin (C)", "Humedad (%)", 
                      "Lluvia (mm)", "Presion (mb)", "Velocidad del Viento (m/s)", "Direccion del Viento")
    }
    if (missing(datain)) return(colnames)
    names(datain) <- colnames
  }
  
  if (remove_missing) {
    for (col in 2:ncol(datain)) {
      badrows <- which(datain[[col]] %in% list("", -999, -888))
      datain[badrows,col] <- NA
    }
  }
  
  if (fix_types) {
    # Make sure that the columns are the right type
    datain$Fecha <- as.Date(datain$Fecha, format = "%Y-%m-%d")
    if (config == "H") {
      if (type == "CON") {
        datain$`Nivel06 (m)` <- as.numeric(datain$`Nivel06 (m)`)
        datain$`Nivel10 (m)` <- as.numeric(datain$`Nivel10 (m)`)
        datain$`Nivel14 (m)` <- as.numeric(datain$`Nivel14 (m)`)
        datain$`Nivel18 (m)` <- as.numeric(datain$`Nivel18 (m)`)
        datain$`Caudal (m^3/s)` <- as.numeric(datain$`Caudal (m^3/s)`)
      } else {
        datain$`Tmean (C)` <- as.numeric(datain$`Tmean (C)`)
        datain$`Tmax (C)` <- as.numeric(datain$`Tmax (C)`)
        datain$`Tmin (C)` <- as.numeric(datain$`Tmin (C)`)
        datain$`Humedad (%)` <- as.numeric(datain$`Humedad (%)`)
        datain$`Lluvia (mm)` <- as.numeric(datain$`Lluvia (mm)`)
        datain$`Presion (mb)` <- as.numeric(datain$`Presion (mb)`)
        datain$`Direccion del Viento` <- as.character(datain$`Direccion del Viento`)
        datain$`Nivel Medio (m)` <- as.numeric(datain$`Nivel Medio (m)`)
      }
    } else {
      if (type == "CON") {
        if (has_name(datain, "Tmean (C)")) datain$`Tmean (C)` <- as.numeric(datain$`Tmean (C)`)
        datain$`Tmax (C)` <- as.numeric(datain$`Tmax (C)`)
        datain$`Tmin (C)` <- as.numeric(datain$`Tmin (C)`) 
        datain$`TBS07 (C)` <- as.numeric(datain$`TBS07 (C)`)
        datain$`TBS13 (C)` <- as.numeric(datain$`TBS13 (C)`)
        datain$`TBS19 (C)` <- as.numeric(datain$`TBS19 (C)`)
        datain$`TBH07 (C)` <- as.numeric(datain$`TBH07 (C)`)
        datain$`TBH13 (C)` <- as.numeric(datain$`TBH13 (C)`)
        datain$`TBH19 (C)` <- as.numeric(datain$`TBH19 (C)`)
        datain$`Prec07 (mm)` <- as.numeric(datain$`Prec07 (mm)`)
        datain$`Prec19 (mm)` <- as.numeric(datain$`Prec19 (mm)`)
        datain$`Direccion del Viento` <- as.character(datain$`Direccion del Viento`)
      }
      if (type == "SUT" | type == "SIA" | type == "DAV") {
        datain$`Tmean (C)` <- as.numeric(datain$`Tmean (C)`)
        datain$`Tmax (C)` <- as.numeric(datain$`Tmax (C)`)
        datain$`Tmin (C)` <- as.numeric(datain$`Tmin (C)`)
        datain$`Humedad (%)` <- as.numeric(datain$`Humedad (%)`)
        datain$`Lluvia (mm)` <- as.numeric(datain$`Lluvia (mm)`)
        datain$`Presion (mb)` <- as.numeric(datain$`Presion (mb)`)
        datain$`Direccion del Viento` <- as.character(datain$`Direccion del Viento`)
      }
    }
    if (has_name(datain, "Velocidad del Viento (m/s)")) {
      if (length(grep(".", datain$`Velocidad del Viento (m/s)`, fixed = TRUE)) > 0) {
        datain$`Velocidad del Viento (m/s)` <- as.double(datain$`Velocidad del Viento (m/s)`)
      } else {
        datain$`Velocidad del Viento (m/s)` <- as.integer(datain$`Velocidad del Viento (m/s)`)
      }
    }
  }
  datain
}

#* Return the requested table
#* @serializer contentType list(type="application/octet-stream")
#* @get /catalogue
function() {
  catalogue <- st_pcd$get("catalogue")
  serialize(catalogue, NULL)
}

get_mariadb <- function(station, year = NULL) {
  
  catalogue <- st_pcd$get("catalogue")

  station_data <- catalogue[catalogue$StationID == station, ]
  type = station_data$Type
  config = station_data$Configuration
  
  conn <- dbConnect(MySQL(), user = username, password = password, host = "pcd.conr.ca", dbname = "pcd")
  on.exit(dbDisconnect(conn))
  
  sql_table <- paste0("ID_", station)
  if (sum(dbListTables(conn) %in% sql_table) != 1) {
    dbDisconnect(conn)
    stop("There was an error getting that table.")
  }
  
  if (is.null(year) | length(year) == 0) {
    dat <- as_tibble(dbReadTable(conn, sql_table, row.names = NULL))
  } else {
    start <- min(year)
    end <- max(year)
    dat <- as_tibble(dbGetQuery(conn, paste0("SELECT * FROM ", sql_table, " WHERE Fecha BETWEEN \"", start, "-01-01\" AND \"", end, "-12-31\";")))
  }
  dat <- .clean_table(dat, config, type, clean_names = TRUE, fix_types = TRUE)
  dat
}

del_mariadb <- function(station) {
  
  conn <- dbConnect(MySQL(), user = username, password = password, host = "pcd.conr.ca", dbname = "pcd")
  on.exit(dbDisconnect(conn))
  
  sql_table <- paste0("ID_", station)
  if (sum(dbListTables(conn) %in% sql_table) == 1) {
    dbRemoveTable(conn, sql_table)
  } else {
    warning("Table doesn't exist")
  }

}

#* Return the requested table
#* @serializer contentType list(type="application/octet-stream")
#* @param station The station
#* @param year A vector of years to return
#* @post /get
function(station, year = NULL) {
  
  catalogue <- st_pcd$get("catalogue")
  
  if (nchar(station) < 6) {
    station <- suppressWarnings(try(sprintf("%06d", as.numeric(station)), silent = TRUE))
    if (inherits(station, "try-error") | !station %in% catalogue$StationID) {
      stop("Station ID appears invalid.")
    }
  }
  
  if (st_pcd$exists(station)) {
    dat <- st_pcd$get(station)
  } else {
    message("Moving data from mariadb to plumber")
    dat <- try(get_mariadb(station, NULL))
    if (inherits(dat, "type-error")) {
      stop("We encountered an error!")
    }
    st_pcd$set(station, value = dat)
    del_mariadb(station)
  }
  
  if (!is.null(year) && length(year) > 0) {
    dat <- dat[dat$Fecha >= paste0(min(year), "-01-01") & dat$Fecha <= paste0(max(year), "-12-31"),]
  }
  
  serialize(dat, NULL)
}
