SenamhiR
========
A collection of functions to obtain Peruvian climate data in R.
The package attempts to provide a mostly automated solution for the bulk download and compilation of data.
It is important to note that the info on the Senamhi website has not undergone quality control.

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
