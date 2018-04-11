library("testthat")
library("senamhiR")
indat <- senamhiR("000280")

context("Test `qc()`")

##FIXME, make more interesting tests
## test qc corrections
test_that("qc can fix errors", {
  out <- qc(indat)
  expect_identical(names(out)[15], "Observations")
  expect_that(out, is_a("tbl_df"))
  expect_output(str(out), "15 variables")
  expect_equal(out$`Tmin (C)`[19660], 23.2)
  expect_identical(out$Observations[19660], "Tmin dps: 232 -> 23.2 (1.03)")
})

## should fail if not enough context
test_that("qc fails if the data set is just one year", {
  expect_error(qc(indat[format(indat$Fecha, format = "%Y") == 2013,]), "You've passed a one-year table. We need (many) additional years of data for context.", fixed=TRUE)
})
