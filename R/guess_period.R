##' @title Query available data from the Peruvian National Hydrological and Meterological Service
##'
##' @description Query the available data for a given station from the Senamhi web portal.
##'
##' @param station character; the station id number to process.
##' @param automatic logical; if set to true (default), the script will attempt to guess the startYear and endYear values.
##' @param write_mode character; if set to 'overwrite', the script will overwrite downloaded files if they exist.
##'
##' @return data.frame
##'
##' @keywords internal
##'
##' @author Conor I. Anderson
##' 
##' @importFrom XML readHTMLTable
##'  
##' @examples
##' \dontrun{.guess_period('000401')}

.guess_period <- function(station, automatic = TRUE, write_mode = "z") {
    
    ## genURL
    url <- paste0("http://www.senamhi.gob.pe/include_mapas/_dat_esta_periodo.php?estaciones=", 
        station)
    
    ## Download the data
    print(paste0("Checking data at ", station, "."))
    filename <- tempfile()
    .download_action(url, filename, write_mode)
    
    table <- readHTMLTable(filename, as.data.frame = TRUE)
    table <- as.data.frame(table[3])
    if (ncol(table) > 1) {
        names(table) <- c("Parameter", "DataFrom", "DataTo")
        if (automatic == TRUE) {
            startYear <- min(as.numeric(levels(table$DataFrom)))
            endYear <- max(as.numeric(levels(table$DataTo)))
            if (endYear == 2010) {
                endYear <- "2010+"
            }
            result <- c(startYear, endYear)
            return(result)
        } else {
            return(table)
        }
    } else {
        stop("We could not determine data availability for this station.")
    }
}
