context("coord_* functions")

df <- sample_data_1
df5 <- sample_data_5

test_that("coord_* passing lat/long vars works", {
  skip_on_cran()

  # 1 name input
  lon_name <- "decimalLongitude"
  names(df)[2] <- lon_name
  bb <- suppressMessages(dframe(df) %>% coord_incomplete(lon = lon_name))

  expect_is(bb, "data.frame")
  expect_is(bb, "tbl_df")
  expect_equal(names(df)[2], lon_name)
  expect_equal(names(bb)[2], "decimalLongitude")

  # both names input
  lon_name <- "x"
  lat_name <- "y"
  names(df)[2] <- lon_name
  names(df)[3] <- lat_name
  bb <- suppressMessages(dframe(df) %>% coord_incomplete(lat_name, lon_name))

  expect_is(bb, "data.frame")
  expect_is(bb, "tbl_df")
  expect_equal(names(df)[2], lon_name)
  expect_equal(names(df)[3], lat_name)
  expect_equal(names(bb)[2], "x")
  expect_equal(names(bb)[3], "y")
})

test_that("coord_imprecise works", {
  expect_equal(NROW(df5), 39)

  ## remove records that don't have decimals at all
  df5_imp <- dframe(df5) %>% coord_imprecise(which = "has_dec")
  expect_equal(NROW(df5_imp), 33)
  expect_is(attr(df5_imp, "coord_imprecise"), "tbl_df")
  expect_equal(NROW(attr(df5_imp, "coord_imprecise")), 6)
})