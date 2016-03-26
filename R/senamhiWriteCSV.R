## Copyright (C) 2016 Conor Anderson <conor.anderson@utoronto.ca>
##
## This program is free software: you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation, either version 2 or (at your option) version 3 of the License.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
## FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program.  If not, see <http://www.gnu.org/licenses/>.
##
## This script reads downloaded HTML climate data from the Peruvian
## Meterological Service and exports to a CSV file. First you MUST run the
## downladData.R script that accompanies this one; they should never be
## distributed seperately.
##
## Version 1.0
## Requires the "XML" library

senamhiWriteCSV <- function(station,
                            MorH = "z",
                            startYear,
                            endYear,
                            startMonth,
                            endMonth,
                            append = FALSE,
                            custom = FALSE) {

  if ("XML" %in% rownames(installed.packages()) == FALSE) {
    print("Installing the XML package")
    install.packages("XML")
  }
  require(XML)

  # This snippet of code from Stack Overflow user Grzegorz Szpetkowski at
  # http://stackoverflow.com/questions/6243088/find-out-the-number-of-days-of-a-month-in-r

  numberOfDays <- function(date) {
    m <- format(date, format = "%m")
    while (format(date, format = "%m") == m) {
      date <- date + 1
    }
    return(as.integer(format(date - 1, format = "%d")))
  }
  ##--------------------------------------------------------------------------------------

  data <- data.frame()

  if (missing(station))
    station <- readline(prompt = "Enter station number: ")
  while (!(MorH == "M" | MorH == "H"))
    MorH <- readline(prompt = "Enter Field M or H: ")
  if (missing(startYear))
    startYear <- as.integer(readline(prompt = "Enter start year: "))
  if (missing(endYear))
    endYear <- as.integer(readline(prompt = "Enter end year: "))
  if (missing(startMonth))
    startMonth <-
    as.integer(readline(prompt = "Enter start month: "))
  if (missing(endMonth))
    endMonth <- as.integer(readline(prompt = "Enter end month: "))

  #GenFileList
  years <- seq(startYear, endYear)
  months <- seq(startMonth, endMonth)
  months <- sprintf("%02d", months)
  files <-
    apply(expand.grid(months, years), 1, function(x)
      paste(x[2], x[1], sep = ""))
  files <-
    paste(as.character(station), "/", files, ".html", sep = "")

  #GenDates
  datelist <-
    apply(expand.grid(months, years), 1, function(x)
      paste(x[2], x[1], sep = "-"))
  datelist <- paste(datelist, "01", sep = "-")

  ## Code to handle custom column headers (for inactive stations, for example)
  ## Use the argument "custom = TRUE" to activate this functionality

  if (custom == TRUE) {
    colnames <- NULL
    print("Please enter custom column names. Leave blank to stop.")
    c = 1
    while (c > 0) {
      colname <- readline(prompt = (paste("Column ", c, ": ", sep = "")))
      if (colname != "") {
        colnames <- c(colnames, colname)
        c <- c + 1
      } else
        c = 0
    }
  } else {
    if (MorH == "H") {
      colnames <-
        c("Fecha",
          "Nivel06",
          "Nivel10",
          "Nivel14",
          "Nivel18",
          "Caudal")
    } else {
      colnames <-
        c(
          "Fecha",
          "Tmax",
          "Tmin",
          "TBS07",
          "TBS13",
          "TBS19",
          "TBH07",
          "TBH13",
          "TBH19",
          "Prec07",
          "Prec19",
          "DirViento",
          "VelViento"
        )
    }
  }

  i = 1
  for (i in 1:length(files)) {
    date <- as.Date(datelist[i], format = "%Y-%m-%d")
    datecolumn <- seq(date, by = 1, length.out = numberOfDays(date))
    table <- readHTMLTable(files[i])
    table <- as.data.frame(table[1])
    if (nrow(table) > 1) {
      table <- subset(table[2:length(table[, 1]), 2:length(table)])
      table <- cbind(datecolumn, table)
    } else {
      table <-
        matrix("NA",
               nrow = length(datecolumn),
               ncol = (length(colnames) - 1))
      table <- cbind(datecolumn, as.data.frame(table))
    }
    names(table) <- names(data)
    data <- rbind(data, table)
    ++i
  }

  names(data) <- (colnames)

  if (append == TRUE) {
    write.table(
      data,
      paste(as.character(station), ".csv", sep = ""),
      append = TRUE,
      sep = ",",
      col.names = FALSE,
      row.names = FALSE
    )
  } else {
    write.table(
      data,
      paste(as.character(station), ".csv", sep = ""),
      sep = ",",
      row.names = FALSE
    )
  }
}
