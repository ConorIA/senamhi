library("testthat")
library("senamhiR")
indat <- senamhiR(c("000280", "230715", "47270400"))

context("Test `qc()`")

## test qc corrections
test_that("qc can fix temperature errors", {
  out <- qc(indat[[1]])
  expect_identical(names(out)[15], "Observations")
  expect_that(out, is_a("tbl_df"))
  expect_output(str(out), "15 variables")
  expect_equal(out$`Tmin (C)`[19660], 23.2)
  expect_identical(out$Observations[19558], "Tmin err: 221.2 -> NA")
})

test_that("qc can fix CON level errors", {
  out <- qc(indat[[2]])
  expect_identical(names(out)[7], "Observations")
  expect_that(out, is_a("tbl_df"))
  expect_output(str(out), "7 variables")
  expect_identical(out$Observations[3262], "Level err: 1.83 -> NA")
})

test_that("qc can fix SUT level errors", {
  out <- qc(indat[[3]])
  expect_identical(names(out)[11], "Observations")
  expect_that(out, is_a("tbl_df"))
  expect_output(str(out), "11 variables")
  expect_identical(out$Observations[1255], "Level err: -123.51 -> NA")
})

## should fail if not enough context
test_that("qc fails if the data set is just one year", {
  expect_error(qc(indat[[1]][format(indat[[1]]$Fecha, format = "%Y") == 2013,]), "You've passed a one-year table. We need (many) additional years of data for context.", fixed=TRUE)
})
