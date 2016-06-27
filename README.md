SenamhiR
========
A collection of functions to obtain Peruvian climate data in R.
The package attempts to provide a mostly automated solution for the bulk download and compilation of data.
It is important to note that the info on the Senamhi website has not undergone quality control.

#### Build Status
[![Build Status](https://travis-ci.org/ConorIA/senamhiR.svg?branch=master)](https://travis-ci.org/ConorIA/senamhiR) [![Build status](https://ci.appveyor.com/api/projects/status/8731y41f53b8me78?svg=true)](https://ci.appveyor.com/project/ConorIA/senamhir)

To use
------
``` {r, eval = FALSE}
install.packages("devtools")
devtools::install_github("ConorIA/senamhiR")
```

Included functions
------------------
* senamhiR() ... A wrapper for most of the funtions below
* downloadData() ... Downloads data in HTML tables for a specific station and range of dates
* downloadAction() ... A helper to download files in the various functions
* writeCSV() ... Generates a .csv file for use in R from the downloaded data
* guessPeriod() ... Attempts to determine the availability of data for a given station
* guessConfig() ... Attempts to determine station class and type
* generateCatalogue() ... Generates a catalogue of stations from the Senamhi Google Maps (this information is included in sysdata.rda)
* stationExplorerGUI() ... a Shiny app to explore the catalogue of stations
* sortFiles() ... sorts files into folders by region. Useful if downloading in bulk

Example for downloading an entire region
------
``` {r, eval = FALSE}
## Identify all stations in the Tacna Region
index <- catalogue$Region == "TACNA"
stations <- catalogue$StationID[index]
## Download and compile data from all station (using a period of 2000-2015 if automatic detection fails)
senamhiR(3, stations, fallback = c(2000,2015))
## Sort those files into a folder called "TACNA"
sortFiles(stations)
```
