##' @title Access data from the Peruvian National Hydrological and Meterological Service via MySQL
##'
##' @description Download Peruvian historical climate data from the Senamhi via a MySQL archive.
##'
##' @param station character; the station id number to process.
##' @param year numeric; an ordered vector of years to retrieve.
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

  conn <- dbConnect(MySQL(), user = "anonymous", host = Sys.getenv("SQL_HOST"), dbname = "pcd")
  sql_table <- paste0("ID_", station)
  if (sum(dbListTables(conn) %in% sql_table) != 1) stop("There was an error getting that table.")

  if (missing(year)) {
    dat <- as_tibble(dbReadTable(conn, sql_table, row.names = NULL))
  } else {
    start <- min(year)
    end <- max(year)
    dat <- as_tibble(dbGetQuery(conn, paste0("SELECT * FROM ", sql_table, " WHERE Fecha BETWEEN \"", start, "-01-01\" AND \"", end, "-12-31\";")))
  }
  dat <- .clean_table(dat, config, type, clean_names = TRUE, fix_types = TRUE)

  dat
}
