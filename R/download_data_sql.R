##' @title Access data from the Peruvian National Hydrological and Meterological Service via MySQL
##'
##' @description Download Peruvian historical climate data from the Senamhi via a MySQL archive.
##'
##' @param station character; the station id number to process.
##'
##' @return tbl_df
##'
##' @author Conor I. Anderson
##' 
##' @importFrom RMySQL dbConnect
##'
##' @export
##' 
##' @examples
##' \dontrun{download_data_sql('000401')}

download_data_sql <- function(station, year) {
  
  station_data <- catalogue[catalogue$StationID == station, ]
  type = station_data$Type
  config = station_data$Configuration

  ## Generate the column names
  if (config == "H") {
    if (type == "CON") 
      colnames <- c("Fecha", "Nivel06 (m)", "Nivel10 (m)", "Nivel14 (m)", "Nivel18 (m)", 
        "Caudal (m^3/s)")
      types <- "Dddddd"
    if (type == "SUT") 
      colnames <- c("Fecha", "Tmean (C)", "Tmax (C)", "Tmin (C)", "Humidity (%)", 
        "Lluvia (mm)", "Presion (mb)", "Velocidad del Viento (m/s)", "Direccion del Viento", 
        "Nivel Medio (m)")
      types <- "Dddddddccd"
  } else {
    if (type == "CON") 
      colnames <- c("Fecha", "Tmean (C)", "Tmax (C)", "Tmin (C)", "TBS07 (C)", "TBS13 (C)", 
        "TBS19 (C)", "TBH07 (C)", "TBH13 (C)", "TBH19 (C)", "Prec07 (mm)", 
        "Prec19 (mm)", "Direccion del Viento", "Velocidad del Viento (m/s)")
      types <- "Ddddddddddddcc"
    if (type == "SUT" | type == "SIA" | type == "DAV") 
      colnames <- c("Fecha", "Tmean (C)", "Tmax (C)", "Tmin (C)", "Humedad (%)", 
        "Lluvia (mm)", "Presion (mb)", "Velocidad del Viento (m/s)", "Direccion del Viento")
      types <- "Dddddddcc"
  }
  
  conn <- dbConnect(MySQL(), user = "anonymous", host = Sys.getenv("SQL_HOST"), dbname = "pcd")
  sql_table <- paste0("ID_", station)
  if (sum(dbListTables(conn) %in% sql_table) != 1) stop("There was an error getting that table.")

  dat <- as_tibble(dbReadTable(conn, sql_table, row.names = NULL))
  names(dat) <- colnames
  
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
      dat$`Tmean (C)` <- as.numeric(dat$`Tmean (C)`)
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
  dat
}