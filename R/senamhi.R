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
## Version 1.0 Requires the "curl" and "XML" libraries

senamhi <-
  function(tasks,
           station,
           type,
           MorH,
           startYear,
           endYear,
           startMonth,
           endMonth) {

    if (missing(tasks)) {
      print("Please choose the series of command you wish to run.")
      tasks <-
        readline(prompt = "1) Download Data, 2) Compile CSV of Downloaded Data, 3) Both: ")
    }
    if (missing(station))
      station <- readline(prompt = "Enter station number: ")
    if (missing(type))
      type <- readline(prompt = "Enter Type CON or SUT: ")
    if (missing(MorH))
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

    if (tasks == 1) {
      senamhiDownload(station,
                   type,
                   MorH,
                   startYear,
                   endYear,
                   startMonth,
                   endMonth)
    } else {
      if (tasks == 2) {
        senamhiWriteCSV(station, MorH, startYear, endYear, startMonth, endMonth)
      } else {
        if (tasks == 3) {
          senamhiDownload(station,
                       type,
                       MorH,
                       startYear,
                       endYear,
                       startMonth,
                       endMonth)
          senamhiWriteCSV(station, MorH, startYear, endYear, startMonth, endMonth)
        } else
          print("Please choose an option between 1 and 3")
      }
    }
  }
