context("clean_df")

df <- sample_data_1

test_that("clean_df basic use without lat/long vars works", {
  skip_on_cran()

  aa <- suppressMessages(clean_df(df))

  expect_is(aa, "data.frame")
  expect_is(aa, "clean_df")
})

test_that("clean_df fails well", {
  skip_on_cran()

  expect_error(clean_df(),
               "argument \"x\" is missing")
  expect_error(clean_df("things"),
               "x must be a data.frame")
})
