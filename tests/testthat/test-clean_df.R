context("clean_df")

df <- sample_data_1

test_that("clean_df basic use without lat/long vars works", {
  skip_on_cran()

  aa <- suppressMessages(clean_df(df))

  expect_is(aa, "data.frame")
  expect_is(aa, "clean_df")
})

test_that("clean_df passing lat/long vars works", {
  skip_on_cran()

  # 1 name input
  lon_name <- "decimalLongitude"
  names(df)[2] <- lon_name
  bb <- suppressMessages(clean_df(df, lon = lon_name))

  expect_is(bb, "data.frame")
  expect_is(bb, "clean_df")
  expect_equal(names(df)[2], lon_name)
  expect_equal(names(bb)[2], "longitude")

  # both names input
  lon_name <- "x"
  lat_name <- "y"
  names(df)[2] <- lon_name
  names(df)[3] <- lat_name
  bb <- suppressMessages(clean_df(df, lat_name, lon_name))

  expect_is(bb, "data.frame")
  expect_is(bb, "clean_df")
  expect_equal(names(df)[2], lon_name)
  expect_equal(names(df)[3], lat_name)
  expect_equal(names(bb)[2], "longitude")
  expect_equal(names(bb)[3], "latitude")
})

test_that("clean_df fails well", {
  skip_on_cran()

  expect_error(clean_df(),
               "argument \"x\" is missing")
  expect_error(clean_df("things"),
               "x must be a data.frame")
  expect_error(clean_df(df, lat = 5),
               "'5' not found in your data")
})
