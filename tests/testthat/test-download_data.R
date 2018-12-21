library("testthat")
library("senamhiR")

context("Test `download_data()`")

## test senamhiR download (H, CON)
test_that("download_data() can download data", {
  out <- download_data("230715")
  expect_identical(names(out)[6], "Caudal (m^3/s)")
  expect_that(out, is_a("tbl_df"))
  expect_output(str(out), "6 variables")
})

## test senamhiR download by year (H, SUT)
test_that("download_data() can filter by year", {
  out <- senamhiR("472D23BE", 2001:2010)
  expect_identical(names(out)[7], "Presion (mb)")
  expect_that(out, is_a("tbl_df"))
  expect_output(str(out), "3652 obs")
  expect_output(str(out), "9 variables")
})

## test senamhiR download M, DAV
test_that("download_data() can download DAV stations", {
  out <- senamhiR("113129", 2001:2005)
  expect_identical(names(out)[5], "Humedad (%)")
  expect_that(out, is_a("tbl_df"))
  expect_output(str(out), "1826 obs")
  expect_output(str(out), "9 variables")
})

## test senamhiR can pad with zeroes
test_that("download_data() can pad with zeroes", {
  out <- senamhiR(401)
  expect_identical(names(out)[11], "Prec19 (mm)")
  expect_that(out, is_a("tbl_df"))
  expect_output(str(out), "13 variables")
})

## should fail when no correct station is given
test_that("download_data() fails when an incorrect station is requested", {
  expect_error(download_data("foo"), "Internal Server Error (HTTP 500).", fixed=TRUE) #FIXME
})
