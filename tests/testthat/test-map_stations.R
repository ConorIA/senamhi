library("testthat")
library("senamhiR")
df <- station_search("Lima")

context("Test `map_stations()`")

## test a map of one station
test_that("map_stations() can map a single station", {
  map <- map_stations("000401")
  expect_that(attr(map$x, "leafletData"), is_a("tbl_df"))
  expect_output(str(attr(map$x, "leafletData")), "1 obs")
  expect_output(str(attr(map$x, "leafletData")), "14 variables")
})

## test a map of one station padded with zeros
test_that("map_stations() can pad a StationID", {
  map <- map_stations(401)
  expect_that(attr(map$x, "leafletData"), is_a("tbl_df"))
  expect_output(str(attr(map$x, "leafletData")), "1 obs")
  expect_output(str(attr(map$x, "leafletData")), "14 variables")
})

## test a map of one searched stations
test_that("map_stations() can map a station search result", {
  map <- map_stations(df)
  expect_identical(attr(map$x, "leafletData"), df)
})

## test a map with satellite data
test_that("map_stations() can map sentinel satellite data", {
  map <- map_stations(df, type = "sentinel")
  expect_identical(attr(map$x, "leafletData"), df)
})


## test a map with a wrong type
test_that("map_stations() warns if map type is unrecognized", {
  expect_warning(map_stations(df, type = "foo"), "Unrecognized map type. Defaulting to osm.", fixed = TRUE)
})


## map_stations should fail if we ask for an invalid station
test_that("map_stations() fails if passed an invalid target", {
  expect_error(map_stations("foo"), "One or more requested stations invalid.", fixed = TRUE)
})
