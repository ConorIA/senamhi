##' @title Basic data quality control
##' 
##' @description A helper function to perform minimal quality control on the data. 
##' For now, this script only performs action on the three main temperature variables.
##' 
##' @param dat an R object of type data.frame passed form the export_data script
##'
##' @return an R object of type data.frame.
##' 
##' @importFrom tibble add_column
##' @importFrom utils sd
##' 
##' @export
##'
##' @author Conor I. Anderson
##' 
##' FIXME: Clean this code up!

qc <- function(dat) {
  
  if (inherits(dat, "character") & !inherits(dat, "data.frame")) {
    if (length(dat) > 1L) {
      stop("Sorry, for now this script can only process one station at a time.")
    } else {
      dat <- try(read_data(dat))
    }
  }
  
  # Try to detect decimal place shifts. 
  
  observations <- rep(NA, nrow(dat))
  
  maxshifts <- which(dat$`Tmax (C)` > 50 | dat$`Tmax (C)` < -50)
  minshifts <- which(dat$`Tmin (C)` > 50 | dat$`Tmin (C)` < -50)
  maxshiftsc <- as.character(dat$`Tmax (C)`[maxshifts])
  minshiftsc <- as.character(dat$`Tmin (C)`[minshifts])
  
  if (length(maxshifts) > 0) {
    for (i in 1:length(maxshifts)) {
      # First, let's see where this is happening.
      context <- dat[max(c(0, maxshifts[i]-30)):min(c(maxshifts[i]+30),nrow(dat)),]
      row <- which(context$Fecha == dat$Fecha[maxshifts[i]])
      existingobs <- if (!is.na(observations[maxshifts[i]])) paste(observations[maxshifts[i]], "/ ") else ""
      if (!grepl("\\.", maxshiftsc[i])) {
        # If this looks like a decimal error, let's salvage the data
        tdiff <- abs(mean(context$`Tmax (C)`[-row], na.rm = TRUE)-(context$`Tmax (C)`[row]/10))
        if (length(tdiff) == 0) tdiff <- NA
        sdiff <- sd(context$`Tmax (C)`[-row], na.rm = TRUE)
        prop <- if (!is.na(sdiff) & !is.na(tdiff)) (tdiff / sdiff) else NA
        if (!is.na(prop) && prop < 1.5) {
          observations[maxshifts[i]] <- paste0(existingobs, "Tmax dps: ", dat$`Tmax (C)`[maxshifts[i]], " -> ", dat$`Tmax (C)`[maxshifts[i]]/10, " (", round(prop, 2), ")")
          dat$`Tmax (C)`[maxshifts[i]] <- dat$`Tmax (C)`[maxshifts[i]]/10
        } else {
          # Changed value not within two standard deviations.
          observations[maxshifts[i]] <- paste0(existingobs, "Tmax err: ", dat$`Tmax (C)`[maxshifts[i]], " -> NA (", round(prop, 2), ")")
          dat$`Tmax (C)`[maxshifts[i]] <- NA
        }
      } else {
        # We aren't sure that this is a decimal place shift!
        observations[maxshifts[i]] <- paste0(existingobs, "Tmax err: ", dat$`Tmax (C)`[maxshifts[i]], " -> NA")
        dat$`Tmax (C)`[maxshifts[i]] <- NA
      }
    }
  }
  
  if (length(minshifts) > 0) {
    for (i in 1:length(minshifts)) {
      context <- dat[max(c(0, minshifts[i]-30)):min(c(minshifts[i]+30),nrow(dat)),]
      row <- which(context$Fecha == dat$Fecha[minshifts[i]])
      existingobs <- if (!is.na(observations[minshifts[i]])) paste(observations[minshifts[i]], "/ ") else ""
      if (!grepl("\\.", minshiftsc[i])) {
        # If this looks like a decimal error, let's salvage the data
        tdiff <- abs(mean(context$`Tmin (C)`[-row], na.rm = TRUE)-(context$`Tmin (C)`[row]/10))
        if (length(tdiff) == 0) tdiff <- NA
        sdiff <- sd(context$`Tmin (C)`[-row], na.rm = TRUE)
        prop <- if (!is.na(sdiff) & !is.na(tdiff)) (tdiff / sdiff) else NA
        if (!is.na(prop) && prop < 1.5) {
          observations[minshifts[i]] <- paste0(existingobs, "Tmin dps: ", dat$`Tmin (C)`[minshifts[i]], " -> ", dat$`Tmin (C)`[minshifts[i]]/10, " (", round(prop, 2), ")")
          dat$`Tmin (C)`[minshifts[i]] <- dat$`Tmin (C)`[minshifts[i]]/10
        } else {
          # Changed value not within two standard deviations.
          observations[minshifts[i]] <- paste0(existingobs, "Tmin err: ", dat$`Tmin (C)`[minshifts[i]], " -> NA (", round(prop, 2), ")")
          dat$`Tmin (C)`[minshifts[i]] <- NA
        }
      } else {
        # We aren't sure that this is a decimal place shift!
        observations[minshifts[i]] <- paste0(existingobs, "Tmin err: ", dat$`Tmin (C)`[minshifts[i]], " -> NA")
        dat$`Tmin (C)`[minshifts[i]] <- NA
      }
    }
  }
  # Try to detect Tmin < Tmax (for now, we'll throw away these days)
  
  minmaxerr <- which(dat$`Tmax (C)` < dat$`Tmin (C)`)
  if (length(minmaxerr) > 0) {
    for (i in 1:length(minmaxerr)) {
      # First, let's see where this is happening.
      context <- dat[max(c(0, minmaxerr[i]-30)):min(c(minmaxerr[i]+30),nrow(dat)),]
      row <- which(context$Fecha == dat$Fecha[minmaxerr[i]])
      # Is the difference from the mean within 1.5 standard deviations?
      # Let's start with Tmin
      tdiff <- abs(mean(context$`Tmax (C)`[-row], na.rm = TRUE)-context$`Tmax (C)`[row])
      if (length(tdiff) == 0) tdiff <- NA
      sdiff <- sd(context$`Tmax (C)`[-row], na.rm = TRUE)
      prop <- if (!is.na(sdiff) & !is.na(tdiff)) (tdiff / sdiff) else NA
      if (!is.na(prop) && prop > 1.5) {
        existingobs <- if (!is.na(observations[minmaxerr[i]])) paste(observations[minmaxerr[i]], "/ ") else ""
        # Let's see if it is a decimal place error (fairly conservative)
        tdiff <- abs(mean(context$`Tmax (C)`[-row], na.rm = TRUE)-(context$`Tmax (C)`[row]*10))
        if (length(tdiff) == 0) tdiff <- NA
        prop <- if (!is.na(sdiff) & !is.na(tdiff)) (tdiff / sdiff) else NA
        if (!is.na(prop) && prop < 1.5) {
          observations[minmaxerr[i]] <- paste0(existingobs, "Tmax dps: ", context$`Tmax (C)`[row], " -> ", 10 * context$`Tmax (C)`[row], " (", round(prop, 2), ")")
          dat$`Tmax (C)`[minmaxerr[i]] <- 10 * dat$`Tmax (C)`[minmaxerr[i]]
        } else {
          observations[minmaxerr[i]] <- paste0(existingobs, "Tmax err: ", context$`Tmax (C)`[row], " -> NA (", round(prop, 2), ")")
          dat$`Tmax (C)`[minmaxerr[i]] <- NA
        }
      }
      
      # Repeat the same for Tmin
      
      # Let's move on to Tmin
      tdiff <- abs(mean(context$`Tmin (C)`[-row], na.rm = TRUE)-context$`Tmin (C)`[row])
      if (length(tdiff) == 0) tdiff <- NA
      sdiff <- sd(context$`Tmin (C)`[-row], na.rm = TRUE)
      prop <- if (!is.na(sdiff) & !is.na(tdiff)) (tdiff / sdiff) else NA
      if (!is.na(prop) && prop > 1.5) {
        existingobs <- if (!is.na(observations[minmaxerr[i]])) paste(observations[minmaxerr[i]], "/ ") else ""
        # Let's see if it is a decimal place error (fairly conservative)
        tdiff <- abs(mean(context$`Tmin (C)`[-row], na.rm = TRUE)-(context$`Tmin (C)`[row]*10))
        if (length(tdiff) == 0) tdiff <- NA
        prop <- if (!is.na(sdiff) & !is.na(tdiff)) (tdiff / sdiff) else NA
        if (!is.na(prop) && prop < 1.5) {
          observations[minmaxerr[i]] <- paste0(existingobs, "Tmin dps: ", context$`Tmin (C)`[row], " -> ", 10 * context$`Tmin (C)`[row], " (", round(prop, 2), ")")
          dat$`Tmin (C)`[minmaxerr[i]] <- 10 * dat$`Tmin (C)`[minmaxerr[i]]
        } else {
          observations[minmaxerr[i]] <- paste0(existingobs, "Tmin err: ", context$`Tmin (C)`[row], " -> NA (", round(prop, 2), ")")
          dat$`Tmin (C)`[minmaxerr[i]] <- NA
        }
      }
    }
  }
  
  # Recalculate Tmean and add observations
  
  dat$`Tmean (C)` <- round((dat$`Tmax (C)`+dat$`Tmin (C)`)/2,1)
  dat <- add_column(dat, Observations = observations)
  
  return(dat)
}
