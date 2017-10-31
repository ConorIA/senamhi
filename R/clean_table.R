#' Clean up table names and types
#'
#' @param datain the data.frame to process
#' @param config the station configuration
#' @param type the station type
#' @param clean_names Boolean; whether to clean up table names
#' @param remove_missing Boolean; whether to remove missing value codes, e.g. -888, -999
#' @param fix_types Boolean; whether to fix column types
#'
#' @return tbl_df
#' 
#' @importFrom tibble has_name
#' @keywords internal
#'
#' @author Conor I. Anderson

.clean_table <- function(datain, config, type, clean_names = FALSE, remove_missing = FALSE, fix_types = FALSE) {
  
  if (clean_names) {
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
        datain$`Humidity (%)` <- as.numeric(datain$`Humidity (%)`)
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
