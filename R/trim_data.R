##' @title Data trimmer
##' 
##' @description A helper function to trim CSV files with multiple years of missing data.
##'
##' @param dat an R object of type data.frame passed form the export_data script
##'
##' @return an R object of type data.frame.
##' 
##' @keywords internal
##'
##' @author Conor I. Anderson

.trim_data <- function(dat) {
  
  tests <- as.data.frame(!is.na(dat[, 5:ncol(dat)]))
  
  firstYear <- 9999
  lastYear <- 0
  for (i in 1:ncol(tests)) {
    tsts <- which(tests[, i] == TRUE)
    if (length(tsts) > 0) {
      if (tsts[1] < firstYear) 
        firstYear <- tsts[1]
      if (tsts[length(tsts)] > lastYear) 
        lastYear <- tsts[length(tsts)]
    }
  }
  
  if (firstYear == 9999 & lastYear == 0) {
    print(paste0("No good data to export."))
    stop("No data to export.")
  }
  
  firstYear <- format(dat$Fecha[firstYear], format = "%Y")
  lastYear <- format(dat$Fecha[lastYear], format = "%Y")
  print(paste0("Data from ", firstYear, " to ", lastYear, "."))
  
  firstYear <- min(grep(firstYear, format(dat$Fecha, format = "%Y")))
  lastYear <- max(grep(lastYear, format(dat$Fecha, format = "%Y")))
  
  if (firstYear > 1 | lastYear < nrow(dat)) {
    print("Trimming data.")
    dat <- subset(dat[firstYear:lastYear, ])
  } else {
    print("Nothing to trim!")
  }
  return(dat)
}
