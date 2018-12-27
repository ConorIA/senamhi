##' @title Basic data quality control
##' 
##' @description A helper function to perform minimal quality control on the data. 
##' For now, this script only performs action on the three main temperature variables.
##' 
##' @param dat a \code{tbl_df} generated form the \code{senamhiR} package
##'
##' @return a \code{tbl_df}
##' 
##' @importFrom dplyr filter select starts_with
##' @importFrom tibble add_column
##' @importFrom rlang .data
##' @importFrom stats sd
##' 
##' @export
##'
##' @author Conor I. Anderson
##' 

qc <- function(dat) {
  
  attrs_to_append <- append(attributes(dat)[4:length(attributes(dat)) - 2], list(`QC Date` = Sys.Date()))
  
  if (inherits(dat, "character") & !inherits(dat, "data.frame")) {
    if (length(dat) > 1L) {
      stop("Sorry, for now this script can only process one station at a time.")
    } else {
      dat <- download_data(dat)
    }
  }
  
  if (length(unique(format(dat$Fecha, format = "%Y"))) == 1) {
    stop("You've passed a one-year table. We need (many) additional years of data for context.")
  }
  
  if (grepl("Observations", colnames(dat)[15])) {
    observations <- select(dat, 15) %>% unlist()
  } else {
    observations <- rep(NA, nrow(dat))
  }
  
  if (attr(dat, "Configuration") != "H") {
  
    # Try to detect decimal place shifts. 
    maxshifts <- which(dat$`Tmax (C)` > 50 | dat$`Tmax (C)` < -50)
    minshifts <- which(dat$`Tmin (C)` > 50 | dat$`Tmin (C)` < -50)
    
    if (length(maxshifts) > 0) {
      for (i in 1:length(maxshifts)) {
        bad_table <- select(dat, .data$Fecha, var = "Tmax (C)")
        fixes <- .fix_bad_data(bad_table, maxshifts[i], "Tmax", "dps")
        dat$`Tmax (C)`[maxshifts[i]] <- unlist(fixes[1])
        existingobs <- if (!is.na(observations[maxshifts[i]]) && observations[maxshifts[i]] != '') paste(observations[maxshifts[i]], ifelse((unlist(fixes[2]) != ''), "/ ", "")) else ""
        observations[maxshifts[i]] <- paste0(existingobs, unlist(fixes[2]))
      }
    }
    
    if (length(minshifts) > 0) {
      for (i in 1:length(minshifts)) {
        bad_table <- select(dat, .data$Fecha, var = "Tmin (C)")
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
        bad_table <- select(dat, .data$Fecha, var = "Tmax (C)")
        fixes <- .fix_bad_data(bad_table, minmaxerr[i], "Tmax", "mme")
        dat$`Tmax (C)`[minmaxerr[i]] <- unlist(fixes[1])
        existingobs <- if (!is.na(observations[minmaxerr[i]]) && observations[minmaxerr[i]] != '') paste(observations[minmaxerr[i]], ifelse((unlist(fixes[2]) != ''), "/ ", "")) else ""
        observations[minmaxerr[i]] <- paste0(existingobs, unlist(fixes[2]))
        
        # Repeat the same for Tmin
        bad_table <- select(dat, .data$Fecha, var = "Tmin (C)")
        fixes <- .fix_bad_data(bad_table, minmaxerr[i], "Tmin", "mme")
        dat$`Tmin (C)`[minmaxerr[i]] <- unlist(fixes[1])
        existingobs <- if (!is.na(observations[minmaxerr[i]]) && observations[minmaxerr[i]] != '') paste(observations[minmaxerr[i]], ifelse((unlist(fixes[2]) != ''), "/ ", "")) else ""
        observations[minmaxerr[i]] <- paste0(existingobs, unlist(fixes[2]))
      }
    }
    
    # Recalculate Tmean and add observations
    dat$`Tmean (C)` <- round((dat$`Tmax (C)` + dat$`Tmin (C)`)/2,1)
    
  } else {
    
    # Try to find bad river levels
    levels <- select(dat, starts_with("Nivel"))
    ranges <- apply(levels, 1, function(x) {max(x) - min(x)})
    while (max(ranges, na.rm = TRUE) > 10 * mean(ranges, na.rm = TRUE)) {
      index <- which.max(ranges)
      slice <- index + -2:2
      current_tab <- data.matrix(levels[slice,])
      std_tab <- (current_tab - mean(current_tab))/sd(current_tab)
      if (sum(std_tab > 1 | std_tab < -1) == 1) {
        if (sum(std_tab > 1) == 1) {
          bad_val <- which.max(std_tab)
          coords <- which(levels[slice,] == current_tab[bad_val], arr.ind = TRUE)
          ul <- mean(current_tab[-bad_val]) + 1.5 * sd(current_tab[-bad_val])
          ll <- mean(current_tab[-bad_val]) - 1.5 * sd(current_tab[-bad_val])
          if (current_tab[bad_val] / 10 <= ul & current_tab[bad_val] / 10 >= ll) {
            observations[index] <- paste("Level dps:", current_tab[bad_val], "->", current_tab[bad_val] / 10)
            levels[slice,][coords[1], coords[2]] <- current_tab[bad_val] / 10
          } else {
            observations[index] <- paste("Level err:", current_tab[bad_val], "-> NA")
            levels[slice,][coords[1], coords[2]] <- NA
          }
        } else {
          bad_val <- which.min(std_tab)
          coords <- which(levels[slice,] == current_tab[bad_val], arr.ind = TRUE)
          ul <- mean(current_tab[-bad_val]) + 1.5 * sd(current_tab[-bad_val])
          ll <- mean(current_tab[-bad_val]) - 1.5 * sd(current_tab[-bad_val])
          if (current_tab[bad_val] * 10 <= ul & current_tab[bad_val] * 10 >= ll) {
            observations[index] <- paste("Level dps:", current_tab[bad_val], "->", current_tab[bad_val] *10)
            levels[slice,][coords[1], coords[2]]  <- current_tab[bad_val] * 10
          } else {
            observations[index] <- paste("Level err:", current_tab[bad_val], "-> NA")
            levels[slice,][coords[1], coords[2]] <- NA
          }
      }
      ranges[index] <- apply(levels[index,], 1, function(x) {max(x) - min(x)})
      } else {
        break
      }
    }
    # Replace all of the old data
    dat[,grep("Nivel", names(dat))] <- levels
  }
  
  # Add observations column to data
  observations[is.na(observations)] <- ''
  dat <- add_column(dat, Observations = observations)
  
  attributes(dat) <- append(attributes(dat), attrs_to_append)
  rownames(dat) <- NULL
    
  dat
}
