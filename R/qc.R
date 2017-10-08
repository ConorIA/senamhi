##' @title Basic data quality control
##' 
##' @description A helper function to perform minimal quality control on the data. 
##' For now, this script only performs action on the three main temperature variables.
##' 
##' @param dat an R object of type data.frame passed form the export_data script
##'
##' @return an R object of type data.frame.
##' 
##' @importFrom dplyr select filter
##' @importFrom tibble add_column
##' @importFrom stats sd
##' 
##' @export
##'
##' @author Conor I. Anderson
##' 

qc <- function(dat) {
  
  if (inherits(dat, "character") & !inherits(dat, "data.frame")) {
    if (length(dat) > 1L) {
      stop("Sorry, for now this script can only process one station at a time.")
    } else {
      dat <- try(read_data(dat))
    }
  }
  
  if (grepl("Observations", colnames(dat)[15])) {
    observations <- select(dat, 15) %>% unlist
  } else {
    observations <- rep(NA, nrow(dat))
  }
  
  # Try to detect decimal place shifts. 
  maxshifts <- which(dat$`Tmax (C)` > 50 | dat$`Tmax (C)` < -50)
  minshifts <- which(dat$`Tmin (C)` > 50 | dat$`Tmin (C)` < -50)
  
  if (length(maxshifts) > 0) {
    for (i in 1:length(maxshifts)) {
      bad_table <- select(dat, Fecha, var = `Tmax (C)`)
      fixes <- .fix_bad_data(bad_table, maxshifts[i], "Tmax", "dps")
      dat$`Tmax (C)`[maxshifts[i]] <- unlist(fixes[1])
      existingobs <- if (!is.na(observations[maxshifts[i]]) && observations[maxshifts[i]] != '') paste(observations[maxshifts[i]], ifelse((unlist(fixes[2]) != ''), "/ ", "")) else ""
      observations[maxshifts[i]] <- paste0(existingobs, unlist(fixes[2]))
    }
  }
  
  if (length(minshifts) > 0) {
    for (i in 1:length(maxshifts)) {
      bad_table <- select(dat, Fecha, var = `Tmin (C)`)
      fixes <- .fix_bad_data(bad_table, minshifts[i], "Tmin", "dps")
      dat$`Tmin (C)`[minshifts[i]] <- unlist(fixes[1])
      existingobs <- if (!is.na(observations[minshifts[i]]) && observations[minshifts[i]] != '') paste(observations[minshifts[i]], ifelse((unlist(fixes[2]) != ''), "/ ", "")) else ""
      observations[minshifts[i]] <- paste0(existingobs, unlist(fixes[2]))
    }
  }
  
  # Try to detect Tmin < Tmax (for now, we'll throw away these days)
  minmaxerr <- which(dat$`Tmax (C)` < dat$`Tmin (C)`)
  if (length(minmaxerr) > 0) {
    for (i in 1:length(minmaxerr)) {
      
      # First check Tmax
      bad_table <- select(dat, Fecha, var = `Tmax (C)`)
      fixes <- .fix_bad_data(bad_table, minmaxerr[i], "Tmax", "mme")
      dat$`Tmax (C)`[minmaxerr[i]] <- unlist(fixes[1])
      existingobs <- if (!is.na(observations[minmaxerr[i]]) && observations[minmaxerr[i]] != '') paste(observations[minmaxerr[i]], ifelse((unlist(fixes[2]) != ''), "/ ", "")) else ""
      observations[minmaxerr[i]] <- paste0(existingobs, unlist(fixes[2]))
      
      # Repeat the same for Tmin
      bad_table <- select(dat, Fecha, var = `Tmin (C)`)
      fixes <- .fix_bad_data(bad_table, minmaxerr[i], "Tmin", "mme")
      dat$`Tmin (C)`[minmaxerr[i]] <- unlist(fixes[1])
      existingobs <- if (!is.na(observations[minmaxerr[i]]) && observations[minmaxerr[i]] != '') paste(observations[minmaxerr[i]], ifelse((unlist(fixes[2]) != ''), "/ ", "")) else ""
      observations[minmaxerr[i]] <- paste0(existingobs, unlist(fixes[2]))
    }
  }
  
  # Recalculate Tmean and add observations
  dat$`Tmean (C)` <- round((dat$`Tmax (C)` + dat$`Tmin (C)`)/2,1)
  observations[is.na(observations)] <- ''
  dat <- add_column(dat, Observations = observations)
  
  dat
}
