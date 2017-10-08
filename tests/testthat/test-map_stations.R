library("testthat")
library("senamhiR")
df <- station_search("Lima")

context("Test `map_stations()`")

## test a map of one station
test_that("map_stations() can map a single station", {
  map_stations("000401")
})

## test a map of one searched stations
test_that("map_stations() can map a station search result", {
  map_stations(df)
})
