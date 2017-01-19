##' @title Perform a quick audit for missing values for a given Senamhi station
##'
##' @description Returns a tibble with the proportion of missing values at a station for a given year and variables. 
##'
##' @param station character; a station id number to process.
##' @param variables numeric or character; By default, all variables will be included. Pass a numeric vector to specify columns to include, or pass a character vector to try to match column names. 
##' @param reverse Boolean; if true, will show proportion present instead of proportion missing.
##' 
##' @importFrom tibble tibble add_column
##' 
##' @export
##'
##' @author Conor I. Anderson
##'
##' @examples
##' \dontrun{quick_audit("000401", "Tmax", reverse = TRUE)}
##' \dontrun{quick_audit("000401", 2:10)}

quick_audit <- function(station, variables, reverse = FALSE) {
  
  dat <- read_data(station)
  
  if (missing(variables)) {
    variables <- 2:ncol(dat)
  } else {
    if (inherits(variables, "character")) {
      for (var in seq_along(variables)) {
        variables[var] <- as.numeric(grep(variables[var], names(dat), ignore.case = TRUE))
      }
    }
    variables <- as.numeric(variables)
  }
  
  if (reverse) {
    ctl = 1
  }
  else {
    ctl = 0
  }

  years <- min(format(dat$Fecha, format = "%Y")):max(format(dat$Fecha, format = "%Y"))
  
  out <- tibble(Year = years)
  
  for (var in variables) {
    integrity <- NULL
    for (year in years) {
      colname <- colnames(dat)[var]
      yearly <- dat[format(dat$Fecha, format = "%Y") == year,]
      obs <- nrow(yearly)
      missing <- sum(is.na(yearly[[var]]))
      integrity <- c(integrity, abs(ctl-(missing/obs)))
    }
    out <- add_column(out, newcol = integrity)
    names(out)[which(names(out) == "newcol")] <- colname
  }
  return(out)
}
  