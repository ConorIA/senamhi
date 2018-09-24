##' @title Perform a quick audit for missing values at a given Senamhi station
##'
##' @description Returns a tibble with the percentage or number of missing values at a station for a given year or year-month and variables.
##'
##' @param station character; a station id number to process or a \code{tbl_df} containing the data to process
##' @param variables numeric or character; by default, all variables will be included. Pass a numeric vector to specify columns to include, or pass a character vector to try to match column names
##' @param by character; whether values should be reported annually (\code{by = "year"}), monthly (\code{by = "month"}, or as an overall (default).
##' @param report character; whether values should be reported as percentage missing (\code{report = "pct"}) or as number of missing values (\code{report = "n"})
##' @param reverse Boolean; if \code{TRUE}, will show percentage present instead of percentage missing (only applies if \code{report = "pct"})
##'
##' @importFrom tibble tibble add_column
##' @importFrom zoo as.yearmon
##'
##' @export
##'
##' @author Conor I. Anderson
##'
##' @examples
##'
##' \dontrun{quick_audit("000401", "Tmax", reverse = TRUE)}
##' \dontrun{quick_audit("000401", 2:10, by = "month", report = "n")}
##'

quick_audit <- function(station, variables, by = NULL, report = "pct", reverse = FALSE) {
  
  if (inherits(station, "tbl_df")) {
    dat <- station
  } else {
    if (inherits(station, "character")) {
      dat <- download_data(station)
    } else {
      stop("I can't figure out what data you've given me.")
    }
  }
  
  if (!is.null(by) && (by != "month" && by != "year")) {
    warning("By was neither \"month\" nor \"year\". Defaulting to overall total.")
    by <- NULL
  }
  
  if (missing(variables)) {
    variables <- min(which(!(names(dat) %in% c("StationID", "Fecha")))):ncol(dat)
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
    metric = "present"
  } else {
    ctl = 0
    metric = "NA"
  }
  
  years <- min(format(dat$Fecha, format = "%Y")):max(format(dat$Fecha, format = "%Y"))
  
  if (is.null(by)) {
    timestep <- 1
    out <- tibble(Report = "Total")
  } else {
    if (by == "month") {
      months <- min(format(dat$Fecha, format = "%m")):max(format(dat$Fecha, format = "%m"))
      yearmons <- apply(expand.grid(sprintf("%02d", months), years), 1, function(x) paste(x[2], x[1], sep = "-"))
      out <- tibble(`Year-month` = yearmons)
      timestep <- yearmons
    } else {
      out <- tibble(Year = years)
      timestep <- years
    }
  }
  
  for (var in variables) {
    integrity <- missingvec <- consecNAvec <- NULL
    for (t in timestep) {
      colname <- colnames(dat)[var]
      if (is.null(by)) {
        timely <- dat  
      } else {
        if (by == "month") {
          timely <- dat[format(dat$Fecha, format = "%Y-%m") == t,]
        } else {
          timely <- dat[format(dat$Fecha, format = "%Y") == t,]
        }
      }
      obs <- nrow(timely)
      missing <- sum(is.na(timely[[var]]))
      if (report == "pct") {
        integrity <- c(integrity, as.numeric(abs(ctl-(missing/obs))*100))
      } else {
        missingvec <- c(missingvec, as.integer(missing))
        consecNA <- rle(is.na(timely[[var]]))
        consecNA <- max(consecNA$lengths[consecNA$values], 0)
        consecNAvec <- c(consecNAvec, as.integer(consecNA))
      }
    }
    if (report == "pct") {
      out <- add_column(out, integ = integrity)
      names(out)[which(names(out) == "integ")] <- paste(colname, "pct", metric)
    } else {
      out <- add_column(out, consec = consecNAvec, rand = missingvec)
      names(out)[which(names(out) == "consec")] <- paste(colname, "consec NA")
      names(out)[which(names(out) == "rand")] <- paste(colname, "tot NA")
    }
    
  }
  if (is.null(by)) {
    out <- out[,-1]
  } else if (by == "month") {
    out$`Year-month` <- as.yearmon(out$`Year-month`)
    out <- add_column(out, Year = format(out$`Year-month`, format = "%Y"), Month = format(out$`Year-month`, format = "%m"), .before = 1)
  }
  
  return(out)
}
