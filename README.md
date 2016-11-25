SenamhiR
========
A collection of functions to obtain Peruvian climate data in R.
The package attempts to provide a mostly automated solution for the bulk download and compilation of data.
It is important to note that the info on the Senamhi website has not undergone quality control.

#### Build Status

- Travis: [![Build Status](https://travis-ci.org/ConorIA/senamhiR.svg?branch=master)](https://travis-ci.org/ConorIA/senamhiR)
- Appveyor: [![Build status](https://ci.appveyor.com/api/projects/status/8731y41f53b8me78?svg=true)](https://ci.appveyor.com/project/ConorIA/senamhir)
- Gitlab: [![build status](https://gitlab.com/ConorIA/senamhi/badges/master/build.svg)](https://gitlab.com/ConorIA/senamhi/commits/master)


To use
------
``` {r, eval = FALSE}
install.packages("devtools")
devtools::install_github("ConorIA/senamhiR", ref = "stable") # to install the stable version
devtools::install_github("ConorIA/senamhiR", ref = "unstable") # to install the unstable version
```

Included functions
------------------
* `senamhiR()` ... A wrapper for the two following functions
    * `downloadData()` ... Downloads data in HTML tables for a specific station and range of dates
    * `writeCSV()` ... Generates a .csv file for use in R from the downloaded data
* `stationSearch()` ... A function to search the stations in catalogue.rda by various criteria
* `stationExplorerGUI()` ... a Shiny app to explore the catalogue of stations

Example for downloading an entire region
------
``` {r, eval = FALSE}
## Identify all stations in the Tacna Region
search <- stationSearch(region = "Tacna")
stations <- search$StationID
## Download and compile data from all station (using a period of 2000-2015 if automatic detection fails)
senamhiR(3, stations, fallback = c(2000,2015))
```
