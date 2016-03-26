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
## This script batch downloads HTML climate data from the Peruvian Meterological
## Service. Run this script BEFORE senamhiWriteCSV.R
##
## Version 1.0
## Requires the "curl" library

senamhiDownload <-
  function(station,
           type = "z",
           MorH = "z",
           startYear,
           endYear,
           startMonth,
           endMonth) {
    if ("curl" %in% rownames(installed.packages()) == FALSE) {
      print("Installing the curl package")
      install.packages("curl")
    }
    require(curl)

    ## Ask user to input variables
    if (missing(station))
      station <- readline(prompt = "Enter station number: ")
    while (!(type == "CON" |
             type == "SUT"))
      type <- readline(prompt = "Enter Type CON or SUT: ")
    while (!(MorH == "M" |
             MorH == "H"))
      MorH <- readline(prompt = "Enter Field M or H: ")
    if (missing(startYear))
      startYear <-
        as.integer(readline(prompt = "Enter start year: "))
    if (missing(endYear))
      endYear <- as.integer(readline(prompt = "Enter end year: "))
    if (missing(startMonth))
      startMonth <-
        as.integer(readline(prompt = "Enter start month: "))
    if (missing(endMonth))
      endMonth <- as.integer(readline(prompt = "Enter end month: "))

    #GenDates
    years <- seq(startYear, endYear)
    months <- seq(startMonth, endMonth)
    months <- sprintf("%02d", months)
    dates <- apply(expand.grid(months, years), 1, function(x)
      paste(x[2], x[1], sep = ""))

    ##genURLs
    urlList <- paste(
      "http://www.senamhi.gob.pe/include_mapas/_dat_esta_tipo02.php?estaciones=",
      station,
      "&tipo=",
      type,
      "&CBOFiltro=",
      dates,
      "&t_e=",
      MorH,
      sep = ""
    )

    if (!dir.exists(as.character(station)))
      dir.create(as.character(station))
    for (i in 1:length(urlList)) {
      curl_download(urlList[i], paste(station, "/", dates[i], ".html", sep = ""))
    }
  }
