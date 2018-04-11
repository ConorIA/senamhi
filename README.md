# senamhiR: A collection of functions to obtain Peruvian climate data in R

[![build status](https://gitlab.com/ConorIA/senamhiR/badges/master/build.svg)](https://gitlab.com/ConorIA/senamhiR/commits/master) [![Build status](https://ci.appveyor.com/api/projects/status/60kbu1b7wkf7akqn?svg=true)](https://ci.appveyor.com/project/ConorIA/senamhir-bxb45) [![codecov](https://codecov.io/gl/ConorIA/senamhiR/branch/master/graph/badge.svg)](https://codecov.io/gl/ConorIA/senamhiR)

The package provides an automated solution for the acquisition of archived Peruvian climate and hydrology data directly within R. The data was compiled from the Senamhi website, and contains all of the data that was available as of April 10, 2018. This data was originally converted from HTML, and is stored in a MySQL database in tibble format.

It is important to note that the info on the Senamhi website has not undergone quality control, however, this package includes a helper function to perform the most common quality control operations for the temperature variables. More functions will be added in the future.

## Installing

This package is under active development, and is not available from the official Comprehensive R Archive Network (CRAN). To make installation easier, I have written a script that will install the `git2r` and `remotes` packages (if necessary), and then install `senamhiR` and all dependencies. Use the following command to run this script:

```r
source("https://gitlab.com/ConorIA/senamhiR/raw/master/install_senamhiR.R")
```
_Note: It is always a good idea to review code before you run it. Click the URL in the above command to see the commands that we will run to install._

Once the packages have installed, load `senamhiR` by:

```r
library(senamhiR)
```

## Basic workflow

The functions contained in the `senamhiR` functions allow for the discovery and visualization of meteorological and hydrological stations, and the acquisition of daily climate data from these stations.

### `station_search()`

To search for a station by name, use the `station_search()` function. For instance, to search for a station with the word 'Santa' in the station name, use the following code:


```r
station_search("Santa")
```

```
## # A tibble: 42 x 14
##    Station           StationID Type  Configuration `Data Start` `Data End`
##    <chr>             <chr>     <fct> <fct>         <chr>        <chr>     
##  1 SANTA MARIA DE N… 000256    CON   M             1951         2017      
##  2 SANTA             000433    CON   M             1964         1986      
##  3 SANTA RITA        000829    CON   M             1977         1992      
##  4 SANTA ELENA       000834    CON   M             1963         1973      
##  5 SANTA ISABEL DE … 158201    CON   M             1964         1982      
##  6 SANTA CRUZ DE HO… 113248    SUT   M             2015         2016      
##  7 SANTA CRUZ        000351    CON   M             1963         2018      
##  8 SANTA CATALINA D… 153200    CON   M             1963         1983      
##  9 HACIENDA SANTA I… 000766    CON   M             1954         1955      
## 10 SANTAROSA LLIHUA  151505    CON   M             1980         1998      
## # ... with 32 more rows, and 8 more variables: `Period (Yr)` <dbl>,
## #   `Station Status` <fct>, Latitude <dbl>, Longitude <dbl>, Region <chr>,
## #   Province <chr>, District <chr>, Downloaded <chr>
```

Note that the `tibble` object (a special sort of `data.frame`) won't print more than the first 10 rows by default. To see all of the results, you can wrap the command in `View()` so that it becomes `View(find_station("Santa"))`.

Note that you can also use wildcards as supported by the `glob2rx()` from the `utils` package by passing the argument `glob = TRUE`, as in the following example.


```r
station_search("San*", glob = TRUE)
```

```
## # A tibble: 135 x 14
##    Station           StationID Type  Configuration `Data Start` `Data End`
##    <chr>             <chr>     <fct> <fct>         <chr>        <chr>     
##  1 SANTA MARIA DE N… 000256    CON   M             1951         2017      
##  2 SAN RAFAEL        152222    CON   M             1965         1966      
##  3 SAN LORENZO # 5   000430    CON   M             1966         1972      
##  4 SAN JACINTO DE N… 000424    CON   M             1956         1968      
##  5 SAN JACINTO       201901    CON   H             1947         1990      
##  6 SAN DIEGO         000420    CON   M             1960         1960      
##  7 SANTIAGO ANTUNEZ… 000426    CON   M             1998         2018      
##  8 SANTA             000433    CON   M             1964         1986      
##  9 SAN PEDRO         211404    CON   H             2009         2018      
## 10 SANTA RITA        000829    CON   M             1977         1992      
## # ... with 125 more rows, and 8 more variables: `Period (Yr)` <dbl>,
## #   `Station Status` <fct>, Latitude <dbl>, Longitude <dbl>, Region <chr>,
## #   Province <chr>, District <chr>, Downloaded <chr>
```

You can filter your search results by region, by station type, by a given baseline period, and by proximity to another station or a vector of coordinates. You can use any combination of these four filters in your search. The function is fully documented, so take a look at `?station_search`. Let's see some examples.

#### Find all stations in the San Martín Region

```r
station_search(region = "SAN MARTIN")
```

```
## # A tibble: 72 x 14
##    Station         StationID Type  Configuration `Data Start` `Data End`
##    <chr>           <chr>     <fct> <fct>         <chr>        <chr>     
##  1 MOYOBAMBA       000378    CON   M             1946         2017      
##  2 NARANJILLO      000219    CON   M             1975         2017      
##  3 NAVARRO         000386    CON   M             1964         2017      
##  4 NARANJILLO      4724851A  SUT   M1            2000         2018      
##  5 EL PORVENIR     4723013A  SUT   M1            2001         2018      
##  6 NUEVO LIMA      153312    CON   M             1963         2017      
##  7 SHEPTE          153301    CON   M             1963         1985      
##  8 TINGO DE PONAZA 153318    CON   M             1963         2005      
##  9 TINGO DE PONAZA 000297    CON   M             1998         2017      
## 10 PUEBLO LIBRE    152228    CON   M             1996         1998      
## # ... with 62 more rows, and 8 more variables: `Period (Yr)` <dbl>,
## #   `Station Status` <fct>, Latitude <dbl>, Longitude <dbl>, Region <chr>,
## #   Province <chr>, District <chr>, Downloaded <chr>
```
#### Find stations named "Santa", with data available between  1971 to 2000

```r
station_search("Santa", baseline = 1971:2000)
```

```
## # A tibble: 10 x 14
##    Station           StationID Type  Configuration `Data Start` `Data End`
##    <chr>             <chr>     <fct> <fct>         <chr>        <chr>     
##  1 SANTA MARIA DE N… 000256    CON   M             1951         2017      
##  2 SANTA CRUZ        000351    CON   M             1963         2018      
##  3 SANTA EULALIA     155213    CON   M             1963         2018      
##  4 SANTA CRUZ        155202    CON   M             1963         2018      
##  5 SANTA ROSA        000536    CON   M             1967         2006      
##  6 SANTA MARIA DE N… 152409    CON   M             1963         2018      
##  7 SANTA RITA DE CA… 152401    CON   M             1963         2018      
##  8 SANTA CLOTILDE    000177    CON   M             1963         2014      
##  9 SANTA CRUZ        152303    CON   M             1963         2008      
## 10 SANTA ROSA        000823    CON   M             1966         2017      
## # ... with 8 more variables: `Period (Yr)` <dbl>, `Station Status` <fct>,
## #   Latitude <dbl>, Longitude <dbl>, Region <chr>, Province <chr>,
## #   District <chr>, Downloaded <chr>
```
#### Find all stations between 0 and 100 km from Station No. 000401

```r
station_search(target = "000401", dist = 0:100)
```

```
## # A tibble: 57 x 15
##    Station     StationID Type  Configuration `Data Start` `Data End`
##    <chr>       <chr>     <fct> <fct>         <chr>        <chr>     
##  1 TARAPOTO    000401    CON   M             1998         2017      
##  2 CUNUMBUQUE  153311    CON   M             1963         2017      
##  3 CUMBAZA     221801    CON   H             1968         2017      
##  4 LAMAS       000383    CON   M             1963         2017      
##  5 SAN ANTONIO 153314    CON   M             1963         2017      
##  6 SHANAO      221802    CON   H             1965         2017      
##  7 SHANAO      153328    CON   M             2002         2017      
##  8 SHANAO      210006    SUT   H             2016         2018      
##  9 TABALOSOS   000322    CON   M             1963         2017      
## 10 EL PORVENIR 000310    CON   M             1964         2017      
## # ... with 47 more rows, and 9 more variables: `Period (Yr)` <dbl>,
## #   `Station Status` <fct>, Latitude <dbl>, Longitude <dbl>, Region <chr>,
## #   Province <chr>, District <chr>, Downloaded <chr>, Dist <dbl>
```
#### Find all stations that are within 50 km of Machu Picchu

```r
station_search(target = c(-13.163333, -72.545556), dist = 0:50)
```

```
## # A tibble: 19 x 15
##    Station        StationID Type  Configuration `Data Start` `Data End`
##    <chr>          <chr>     <fct> <fct>         <chr>        <chr>     
##  1 MACHU PICCHU   000679    CON   M             1964         2017      
##  2 HUYRO          000678    CON   M             1964         1981      
##  3 CHILCA         472A9204  SUT   H             2015         2018      
##  4 ECHARATE       000716    CON   M             1981         1982      
##  5 MARANURA       000676    CON   M             1970         1978      
##  6 OLLANTAYTAMBO  47295014  SUT   M             2011         2013      
##  7 QUILLABAMBA    4729B3E6  SUT   M1            2001         2018      
##  8 QUILLABAMBA    000606    CON   M             1964         2018      
##  9 OCOBAMBA       000681    CON   M             1964         1983      
## 10 MOLLEPATA      000680    CON   M             1963         1978      
## 11 CUNYAC         156224    CON   M             2002         2018      
## 12 ECHARATE       156300    CON   M             1963         1981      
## 13 PUENTE CUNYAC  230503    CON   H             1995         2018      
## 14 ZURITE         000682    CON   M             1964         1983      
## 15 CURAHUASI      000677    CON   M             1963         2017      
## 16 URUBAMBA       113131    DAV   M             2006         2008      
## 17 URUBAMBA       000683    CON   M             1963         2017      
## 18 ANTA ANCACHURO 000684    CON   M             1964         2017      
## 19 HUACHIBAMBA    156303    CON   M             1963         1978      
## # ... with 9 more variables: `Period (Yr)` <dbl>, `Station Status` <fct>,
## #   Latitude <dbl>, Longitude <dbl>, Region <chr>, Province <chr>,
## #   District <chr>, Downloaded <chr>, Dist <dbl>
```

### Acquire data: `senamhiR()`

Once you have found your station of interest, you can download the daily data using the eponymous `senamhiR()` function. The function takes two arguments, station and year. If year is left blank, the function will return all available archived data. 

If I wanted to download data for Requena (station no. 000280) from 1981 to 2010, I could use: 


```r
requ <- senamhiR("000280", 1981:2010)
```
_Note: Since the StationID numbers contain leading zeros, any station that is less than six characters long will be padded with zeroes. i.e. 280 becomes 000280._


```r
requ
```

```
## # A tibble: 10,957 x 13
##    Fecha      `Tmax (C)` `Tmin (C)` `TBS07 (C)` `TBS13 (C)` `TBS19 (C)`
##    <date>          <dbl>      <dbl>       <dbl>       <dbl>       <dbl>
##  1 1981-01-01       35.0       23.0        24.8        30.2        24.4
##  2 1981-01-02       34.0       22.2        24.2        30.0        25.6
##  3 1981-01-03       29.0       23.2        24.6        25.2        24.0
##  4 1981-01-04       30.2       22.0        24.6        28.0        25.0
##  5 1981-01-05       33.0       22.4        24.0        25.0        23.4
##  6 1981-01-06       35.2       23.0        25.0        30.8        27.8
##  7 1981-01-07       33.6       23.0        25.4        30.8        26.0
##  8 1981-01-08       37.4       22.8        25.4        35.0        24.0
##  9 1981-01-09       35.0       23.0        27.0        35.0        26.0
## 10 1981-01-10       35.6       22.4        24.8        34.4        28.0
## # ... with 10,947 more rows, and 7 more variables: `TBH07 (C)` <dbl>,
## #   `TBH13 (C)` <dbl>, `TBH19 (C)` <dbl>, `Prec07 (mm)` <dbl>, `Prec19
## #   (mm)` <dbl>, `Direccion del Viento` <chr>, `Velocidad del Viento
## #   (m/s)` <int>
```

Make sure to use the assignment operator (`<-`) to save the data into an R object, otherwise the data will just print out to the console, and won't get saved anywhere in the memory. 

## For easier station visualization

### `map_stations()`

Sometimes a long list of stations is hard to visualize spatially. The `map_stations()` function helps to overcome this. This function takes a list of stations and shows them on a map powered by the [Leaflet](http://leafletjs.com/) library. Like the previous function, the map function is even smart enough to take a search as its list of stations as per the example below.

#### Show a map of all stations that are between 30 and 50 km of Machu Picchu

```r
map_stations(station_search(target = c(-13.163333, -72.545556), dist = 30:50), zoom = 7)
```

## Quality control functions

There are two functions included to perform some basic quality control. 

### `quick_audit()`

The `quick_audit()` function will return a tibble listing the percentage or number of missing values for a station. For instance, the following command will return the percentage of missing values in our 30-year Requena dataset:


```r
quick_audit(requ, c("Tmax", "Tmin"))
```

```
## # A tibble: 30 x 3
##     Year `Tmax (C) pct NA` `Tmin (C) pct NA`
##    <int>             <dbl>             <dbl>
##  1  1981             8.49              8.49 
##  2  1982             0.                0.   
##  3  1983            41.9              41.9  
##  4  1984             8.20             17.2  
##  5  1985             0.274             7.67 
##  6  1986             0.822             0.822
##  7  1987            17.8              17.8  
##  8  1988             8.47              8.47 
##  9  1989             0.                0.   
## 10  1990             0.                0.   
## # ... with 20 more rows
```

Use `report = "n"` to show the _number_ of missing values. Use `by = "month"` to show missing data by month instead of year. For instance, the number of days for which Mean Temperature was missing at Tocache in 1980:


```r
toca <- senamhiR("000463", year = 1980)
quick_audit(toca, "Tmean", by = "month", report = "n")
```

```
## # A tibble: 12 x 5
##    Year  Month `Year-month`  `Tmean (C) consec NA` `Tmean (C) tot NA`
##    <chr> <chr> <S3: yearmon>                 <int>              <int>
##  1 1980  01    Jan 1980                          0                  0
##  2 1980  02    Feb 1980                          0                  0
##  3 1980  03    Mar 1980                          2                  3
##  4 1980  04    Apr 1980                          4                  4
##  5 1980  05    May 1980                          0                  0
##  6 1980  06    Jun 1980                          0                  0
##  7 1980  07    Jul 1980                          0                  0
##  8 1980  08    Aug 1980                          0                  0
##  9 1980  09    Sep 1980                          1                  1
## 10 1980  10    Oct 1980                          0                  0
## 11 1980  11    Nov 1980                          1                  1
## 12 1980  12    Dec 1980                          0                  0
```

### `qc()`

There is an incomplete and experimental function to perform automated quality control on climate data acquired thought this package. For instance: 


```r
requ_dirty <- senamhiR("000280") #1960 to 2018
requ_qc <- qc(requ_dirty)
requ_qc %>% filter(Observations != "") %>% select(Fecha, `Tmax (C)`, `Tmin (C)`, `Tmean (C)`, Observations)
```

```
## # A tibble: 5 x 5
##   Fecha      `Tmax (C)` `Tmin (C)` `Tmean (C)` Observations               
##   <date>          <dbl>      <dbl>       <dbl> <chr>                      
## 1 2013-02-27       34.0       22.2        28.1 "Tmax dps: 3.4 -> 34 (1.4)…
## 2 2013-05-08       31.4       20.8        26.1 Tmax dps: 314 -> 31.4 (0.2…
## 3 2013-07-18       30.8       NA          NA   Tmin err: 221.2 -> NA      
## 4 2013-10-28       33.4       23.2        28.3 Tmin dps: 232 -> 23.2 (1.0…
## 5 2013-12-24       30.0       23.6        26.8 "Tmax dps: 3 -> 30 (0.77) "
```

For now, the data has been tested for decimal place-errors with the following logic: 

##### Case 1: Missing decimal point
 
Any number above 100 °C or below -100 °C is tested: 

If the number appears to have missed a decimal place (e.g. 324 -> 32.4; 251 -> 25.1), we try to divide that number by 10. If the result is within 1.5 standard deviations of all values 30 days before and after the day in question, we keep the result, otherwise, we discard it.

If the number seems to be the result of some other typographical error (e.g. 221.2), we discard the data point. 

##### Case 2: _T_<sub>max</sub> < _T_<sub>min</sub>

In case 2, we perform the same tests for both _T_<sub>max</sub> and _T_<sub>min</sub>. If the number is within 1.5 standard deviations of all values 30 days before and after the day in question, we leave the number alone. (Note: this is often the case for _T_<sub>min</sub> but seldom the case for _T_<sub>max</sub>). If the number does not fall within 1.5 standard deviations, we perform an additional level of testing to check if the number is the result of a premature decimal point (e.g. 3.4 -> 34.0; 3 -> 30.0). In this case, we try to multiply the number by 10. If this new result is within 1.5 standard deviations of all values 30 days before and after the day in question, we keep the result, otherwise, we discard it.

_I have less confidence in this solution than I do for Case 1._

#### Cases that are currently missed:

 - Cases where _T_<sub>min</sub> is small because of a typo.
 - Cases where _T_<sub>max</sub> is small because of a typo, but not smaller than _T_<sub>min</sub>.
 
#### Cases where this function is plain wrong: 

 - When there are a number of similar errors within the 60-day period, bad data is sometimes considered okay. This is especially apparent at, for instance, Station 47287402.

#### Variables controlled for: 

 - _T_<sub>max</sub>
 - _T_<sub>min</sub>
 - _T_<sub>mean</sub>

__No other variables are currently tested; hydrological data is not tested. This data should not be considered "high quality", use of the data is your responsibility.__ Note that all values that are modified from their original values will be recorded in a new "Observations" column in the resultant tibble.

## Disclaimer

The package outlined in this document is published under the GNU General Public License, version 3 (GPL-3.0). The GPL is an open source, copyleft license that allows for the modification and redistribution of original works. Programs licensed under the GPL come with NO WARRANTY. In our case, a simple R package isn't likely to blow up your computer or kill your cat. Nonetheless, it is always a good idea to pay attention to what you are doing, to ensure that you have downloaded the correct data, and that everything looks ship-shape. 

## What to do if something doesn't work

If you run into an issue while you are using the package, you can email me and I can help you troubleshoot the issue. However, if the issue is related to the package code and not your own fault, you should contribute back to the open source community by reporting the issue. You can report any issues to me here on [GitLab](https://gitlab.com/ConorIA/senamhiR).

If that seems like a lot of work, just think about how much work it would have been to do all the work this package does for you, or how much time went in to writing these functions ... it is more than I'd like to admit!

## Senamhi terms of use

Senamhi's terms of use are _technically_ supposed to be [here](http://senamhi.gob.pe/?p=terminos_condiciones), but that link is currently redirecting to the Senamhi home page. I authored this package when the terms were still available online. At the time of development, the terms allowed for the free and public access to information on their website, in both for-profit and non-profit applications. However, Senamhi stipulated that any use of the data must be accompanied by a disclaimer that Senamhi is the proprietor of the information. The following text was recommended (official text in Spanish):

- **Official Spanish:** _Información recopilada y trabajada por el Servicio Nacional de Meteorología e Hidrología del Perú. El uso que se le da a esta información es de mi (nuestra) entera responsabilidad._
- **English translation:** This information was compiled and maintained by Peru's National Meteorology and Hydrology Service (Senamhi). The use of this data is of my (our) sole responsibility.

A message similar to the English message above is printed to the R console whenever the package is loaded. 
