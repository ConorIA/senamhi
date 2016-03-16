Senamhi Script
==============
A collection of functions to obtain Peruvian climate data in R.
More details forthcoming.

To use
------
1. install.packages("devtools")
2. library(devtools)
3. install_github(repo = "senamhi", username = "ConorIA")
4. library(senamhi)

Included functions
------------------
* senamhi() ... Runs both funtions below
* senamhiDownload() ... Downloads data in HTML tables for a specific station and range of dates
* senamhiWriteCSV() ... Generates a .csv file for use in R from the downloaded data
