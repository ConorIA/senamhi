##' @title HTML file trimmer
##' 
##' @description A helper function to trim HTML files for years with missing data.
##'
##' @param station character; the StationID of the station to process.
##' @param localcatalogue character; optional character string to specify catalogue object to update.
##' @param interactive boolean; whether user should be prompted about deletions and catalogue updates.
##' 
##' @keywords internal
##'
##' @author Conor I. Anderson

.trim_HTML <- function(station, localcatalogue, interactive = TRUE) {
  
  oldwd <- getwd()
  
  if (missing(localcatalogue)) {
    if (file.exists("local_catalogue.rda")) {
      load("local_catalogue.rda")
    } else {
      localcatalogue <- as_tibble(catalogue)
    }
  }
  
  cat_index <- which(localcatalogue$StationID == station)
  newwd <- file.path(oldwd, localcatalogue$Region[cat_index], "HTML", paste(station, "-", localcatalogue$Station[cat_index]))
  
  if (!dir.exists(newwd)) {
    warning("Directory doesn't exist")
    return()
  }
  
  setwd(newwd)
  
  files <- dir()
  
  first_index <- min(which(file.size(files) > 3037))

  if (first_index == Inf) {
    print("Uhh ohh, it looks like there is no good data here.")
    if (interactive == TRUE) {
      go <- readline(prompt = "Should we blow the station away? (y/N)")
      if (go == "y" | go == "Y") {
        setwd(oldwd)
        unlink(newwd, recursive = TRUE)
        }
      go <- readline(prompt = "Should we update the local catalogue? (y/N)")
      if (go == "y" | go == "Y") localcatalogue$`Data Start`[cat_index] <- "NONE"; localcatalogue$`Data End`[cat_index] <- "NONE" 
    } else {
      setwd(oldwd)
      unlink(newwd, recursive = TRUE)
      localcatalogue$`Data Start`[cat_index] <- "NONE"; localcatalogue$`Data End`[cat_index] <- "NONE" 
      save(localcatalogue, file = file.path(oldwd, "local_catalogue.rda"), compress = "xz", compression_level = 9)
    }
    return()
  }
  
  first_year <- substring(files[first_index], 1, 4)
  
  while (first_index == 1 || sum(file.size(files)[1:12] > 3037) > 6) {
    print(paste("Looks like", first_year, "contains data! Let's try for an extra year"))
    setwd(oldwd)
    senamhiR(1, station, year = (as.numeric(first_year)-1))
    setwd(newwd)
    files <- dir()
    first_index <- min(which(file.size(files) > 3037))
    first_year <- substring(files[first_index], 1, 4)
  }
  
  last_index <-max(which(file.size(files) > 3037))
  last_year <- substring(files[last_index], 1, 4)
  while ((last_index == length(files) || sum(file.size(files)[(length(files)-11):length(files)] > 3037) > 6) && last_year != as.integer(format(Sys.Date(), format = "%Y")) - 1) {
    print(paste("Looks like", last_year, "contains data! Let's try for an extra year"))
    setwd(oldwd)
    senamhiR(1, station, year = (as.numeric(last_year) + 1))
    setwd(newwd)
    files <- dir()
    last_index <- max(which(file.size(files) > 3037))
    last_year <- substring(files[last_index], 1, 4)
  }
  print(paste0("We have data from ", first_year, " to ", last_year, "."))
  if (substring(files[1], 1, 4) == first_year && substring(files[length(files)], 1, 4) == last_year) {
    print("There are no files to trim!")
    if (is.na(localcatalogue$`Data Start`[cat_index]) || localcatalogue$`Data Start`[cat_index] != first_year || is.na(localcatalogue$`Data End`[cat_index]) || localcatalogue$`Data End`[cat_index] != last_year) {
      if (interactive == TRUE) {
        go <- readline(prompt = "Should we update the local catalogue? (y/N)")
        if (go == "y" | go == "Y") {
          localcatalogue$`Data Start`[cat_index] <- first_year; localcatalogue$`Data End`[cat_index] <- last_year
          save(localcatalogue, file = file.path(oldwd, "local_catalogue.rda"), compress = "xz", compression_level = 9)
        }
      } else {
        localcatalogue$`Data Start`[cat_index] <- first_year; localcatalogue$`Data End`[cat_index] <- last_year
        save(localcatalogue, file = file.path(oldwd, "local_catalogue.rda"), compress = "xz", compression_level = 9)
      }
    }
  } else {
    files_year <- substring(files, 1, 4)
    if (interactive == TRUE) {
      print("We are going to blow away the following files.")
      print(data.frame(File = files[files_year < first_year | files_year > last_year], Size = file.size(files[files_year < first_year | files_year > last_year])))
      go <- readline(prompt = "Should we go ahead? (y/N)")
      if (go == "y" | go == "Y") unlink(files[files_year < first_year | files_year > last_year])
      go <- readline(prompt = "Should we update the local catalogue? (y/N)")
      if (go == "y" | go == "Y") {
        localcatalogue$`Data Start`[cat_index] <- first_year; localcatalogue$`Data End`[cat_index] <- last_year
        save(localcatalogue, file = file.path(oldwd, "local_catalogue.rda"), compress = "xz", compression_level = 9)
      }
    } else {
      unlink(files[files_year < first_year | files_year > last_year])
      localcatalogue$`Data Start`[cat_index] <- first_year; localcatalogue$`Data End`[cat_index] <- last_year
      save(localcatalogue, file = file.path(oldwd, "local_catalogue.rda"), compress = "xz", compression_level = 9)
    }
  }
  setwd(oldwd)
}