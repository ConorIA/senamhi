library("testthat")
library("senamhiR")

context("Test `senamhiR()`")

## test senamhiR download
test_that("senamhiR can download data", {
  out <- senamhiR("000401")
  expect_identical(names(out)[12], "Prec19 (mm)")
  expect_that(out, is_a("tbl_df"))
  expect_output(str(out), "6940 obs")
  expect_output(str(out), "14 variables")
})

## test senamhiR download by year
test_that("senamhiR can filter by year", {
  out <- senamhiR("000401", 1998:2000)
  expect_identical(names(out)[12], "Prec19 (mm)")
  expect_that(out, is_a("tbl_df"))
  expect_output(str(out), "1096 obs")
  expect_output(str(out), "14 variables")
})

## should fail when no correct station is given
test_that("senamhiR() fails when an incorrect station is requested", {
  expect_error(senamhiR("foo"), "The station requested is not a valid station.", fixed=TRUE)
})
