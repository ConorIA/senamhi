##' @title Guess station characteristics
##'
##' @description Attempt to guess station characteristics.
##'
##' @param station character; the station id number to process.
##' @param write_mode character; if set to 'overwrite', the script will overwrite downloaded files if they exist.
##'
##' @return vector
##'
##' @keywords internal
##'
##' @author Conor I. Anderson
##' 
##' @importFrom XML htmlTreeParse
##'
##' @examples
##' \dontrun{.guess_config('000401')}

.guess_config <- function(station, write_mode = "z") {
    
    ## Ask user to input variables
    if (missing(station)) 
        station <- readline(prompt = "Enter station number: ")
    
    ## genURL
    url <- paste0("http://www.senamhi.gob.pe/include_mapas/_dat_esta_tipo.php?estaciones=", 
        station)
    
    ## Download the data
    print(paste0("Checking station characteristics for ", station, "."))
    filename <- tempfile()
    .download_action(url, filename, write_mode)
    station_data <- htmlTreeParse(filename)
    station_data <- unlist(station_data[3])
    station_data <- station_data[grep("_dat_esta_tipo02.php", station_data)]
    
    ## Check config
    test <- grep("t_e=M1", station_data)
    if (length(test) > 0) {
        config <- "M1"
    } else {
        test <- grep("t_e=M2", station_data)
        if (length(test) > 0) {
            config <- "M2"
        } else {
            test <- grep("t_e=M", station_data)
            if (length(test) > 0) {
                config <- "M"
            } else {
                test <- grep("t_e=H", station_data)
                if (length(test) > 0) {
                  config <- "H"
                } else {
                  config <- "ERROR"
                }
            }
        }
    }
    
    ## Check station type
    test <- grep("tipo=CON", station_data)
    if (length(test) > 0) {
        type <- "CON"
    } else {
        test <- grep("tipo=DAV", station_data)
        if (length(test) > 0) {
            type <- "DAV"
        } else {
            test <- grep("tipo=SUT", station_data)
            if (length(test) > 0) {
                type <- "SUT"
            } else {
                test <- grep("tipo=SIA", station_data)
                if (length(test) > 0) {
                  type <- "SIA"
                } else {
                  type <- "ERROR"
                }
            }
        }
    }
    result <- c(type, config)
    if (result[1] == "ERROR" | result[2] == "ERROR") 
        stop("We could not determine the configuration of this station.")
    return(result)
}
