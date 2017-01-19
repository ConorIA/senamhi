senamhiR
========
A collection of functions to obtain Peruvian climate data in R.
The package attempts to provide a mostly automated solution for the bulk download and compilation of data.
It is important to note that the info on the Senamhi website has not undergone quality control.

**Build Status:** [![build status](https://gitlab.com/ConorIA/senamhiR/badges/master/build.svg)](https://gitlab.com/ConorIA/senamhiR/commits/master) [![Build status](https://ci.appveyor.com/api/projects/status/60kbu1b7wkf7akqn?svg=true)](https://ci.appveyor.com/project/ConorIA/senamhir-bxb45)

To use
------
``` {r, eval = FALSE}
source("https://raw.githubusercontent.com/r-pkgs/remotes/master/install-github.R")$value("r-pkgs/remotes")
remotes::install_git("https://gitlab.com/ConorIA/senamhiR.git")
```

Included functions
------------------
* `senamhiR()` ... A wrapper for the two following functions
    * `download_data()` ... Downloads data in HTML tables for a specific station and range of dates
    * `write_data()` ... Compiles a `.csv` file from the HTML files
    * `read_data()` ... Reads the data contained in the `.csv` file for use in R 
* `station_search()` ... A function to search the stations in catalogue.rda by various criteria
* `station_explorer()` ... a Shiny app to explore the catalogue of stations
* `map_stations()` ... produce a map of a given list of stations

Example for downloading an entire region
------
``` {r, eval = FALSE}
## Identify all stations in the Tacna Region
search <- station_search(region = "Tacna")
## Download and compile data from all station (using a period of 2000-2015 if automatic detection fails)
senamhiR(3, search$StationID, fallback = 2000:2015)
```

#### Senamhi terms of use

Senamhi's [terms of use](http://www.senamhi.gob.pe/?p=0613) ([Google translation](https://translate.google.com/translate?hl=en&sl=auto&tl=en&u=http%3A%2F%2Fwww.senamhi.gob.pe%2F%3Fp%3D0613)) allow for the free and public access to information on their website. Likewise, the data may be used in for-profit and non-profit applications. However, Senamhi stipulates that any use of the data must be accompanied by a disclaimer that Senamhi is the proprietor of the information. The following disclaimer is recommended (official text in Spanish):

- **Official Spanish:** _Información recopilada y trabajada por el Servicio Nacional de Meteorología e Hidrología del Perú. El uso que se le da a esta información es de mi (nuestra) entera responsabilidad._
- **English translation:** This information was compiled and maintained by Peru's National Meteorology and Hydrology Service (Senamhi). The use of this data is of my (our) sole responsibility.
