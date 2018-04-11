library("testthat")
library("senamhiR")

context("Test `station_search()`")

## test finding a station by name with regex
test_that("station_search() can locate a station by name regex", {
  df <- station_search("Tara*", glob = TRUE)
  expect_that(df, is_a("tbl_df"))
  expect_output(str(df), "4 obs")
  expect_output(str(df), "14 variables")
})

## test finding a station by baseline
test_that("station_search() can locate a station by baseline", {
  df <- station_search(baseline = 1965:2015)
  expect_that(df, is_a("tbl_df"))
  expect_output(str(df), "363 obs")
  expect_output(str(df), "14 variables")
})

## test finding a station by region
test_that("station_search() can locate a station by region", {
  df <- station_search(region = "TACNA")
  expect_that(df, is_a("tbl_df"))
  expect_output(str(df), "56 obs")
  expect_output(str(df), "14 variables")
})

## test finding a station by distance from target
test_that("station_search() can locate a station by distance from target", {
  df <- station_search(target = 410, dist = 0:10)
  expect_that(df, is_a("tbl_df"))
  expect_output(str(df), "2 obs")
  expect_output(str(df), "15 variables")
})

## test finding a station by distance from coordinates
test_that("station_search() can locate a station by distance for coordinates", {
  df <- station_search(target = c(-6.50, -76.47), dist = 0:10)
  expect_that(df, is_a("tbl_df"))
  expect_output(str(df), "2 obs")
  expect_output(str(df), "15 variables")
})

## station_search should fail if we spell the region incorrectly
test_that("station_search() fails if passed an incorrect region name", {
  expect_error(station_search(region = "Saint Martin"), "No data found for that region. Did you spell it correctly?", fixed=TRUE)
})

## station_search should fail if we spell the region incorrectly
test_that("station_search() fails if passed an incorrect region name", {
  expect_error(station_search(config = "Q"), "No data found for that config. Did you pass \"m\" or \"h\"?", fixed=TRUE)
})

## station_search should fail if we ask for an invalid target
test_that("station_search() fails if passed an invalid target", {
  expect_error(station_search(target = "foo"), "Target station appears invalid.", fixed=TRUE)
})
