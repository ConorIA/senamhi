library("testthat")
library("senamhiR")

context("Test `senamhiR()`")

## test senamhiR download
test_that("senamhiR can download data", {
  out <- senamhiR("000401")
  expect_identical(names(out)[11], "Prec19 (mm)")
  expect_that(out, is_a("tbl_df"))
  expect_output(str(out), "13 variables")
})

## test senamhiR download by year
test_that("senamhiR can filter by year", {
  out <- senamhiR("000401", 1998:2000)
  expect_identical(names(out)[11], "Prec19 (mm)")
  expect_that(out, is_a("tbl_df"))
  expect_output(str(out), "1096 obs")
  expect_output(str(out), "13 variables")
})

## test senamhiR can pad with zeroes
test_that("senamhiR can pad with zeroes", {
  out <- senamhiR(401)
  expect_identical(names(out)[11], "Prec19 (mm)")
  expect_that(out, is_a("tbl_df"))
  expect_output(str(out), "13 variables")
})

## test senamhiR can collapse multiple stations
test_that("senamhiR can collapse stations with similar names", {
  out <- senamhiR(c(401, 280, "472D23BE"), year = 2001, collapse = TRUE)
  expect_that(out, is_a("list"))
  expect_equal(lengths(out), c(14,11))
  expect_output(str(out), "List of 2")
})

## should fail when no correct station is given
test_that("senamhiR() fails when an incorrect station is requested", {
  expect_error(senamhiR("foo"), "One or more requested stations invalid.", fixed=TRUE)
})
