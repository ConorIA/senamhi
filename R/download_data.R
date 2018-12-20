##' @title Access data from the Peruvian National Hydrological and Meterological Service via API
##'
##' @description Download archived Peruvian historical climate data from the Senamhi via an independent API.
##'
##' @param station character; the station id number to process.
##' @param year numeric; an ordered vector of years to retrieve.
##'
##' @return tbl_df
##'
##' @author Conor I. Anderson
##' 
##' @importFrom httr add_headers content POST stop_for_status
##'
##' @export
##' 
##' @examples
##' \dontrun{download_data('000401')}


download_data <- function(station, year = NULL) {
  r <- POST("https://api.conr.ca/pcd/get", 
            body = list(station = station, year = year), encode = "json",
            config = list(add_headers(accept = "application/octet-stream")))
  stop_for_status(r)
  unserialize(content(r))
}
