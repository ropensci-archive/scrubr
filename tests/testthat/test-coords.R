context("coord_* functions")

df <- sample_data_1
df5 <- sample_data_5
df6<-sample_data_6
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


test_that("coord_uncertain works", {
  expect_equal(NROW(df6), 50)

  ## remove records with uncertain elements
  df6_imp <- dframe(df6) %>% coord_uncertain()
  expect_equal(NROW(df6_imp), 38)
  expect_is(attr(df6_imp, "coord_uncertain"), "tbl_df")
  expect_equal(NROW(attr(df6_imp, "coord_uncertain")), 12)
  ### coordinateUncertaintyInMeters column doesnt exist
  expect_null(attr(df,"coord_uncertain"))

})

test_that("coord_incomplete works", {
  expect_equal(NROW(df), 1500)

  ## remove records with incomplete elements
  df_imp <- dframe(df) %>% coord_incomplete()
  expect_equal(NROW(df_imp), 1306)
  expect_is(attr(df_imp, "coord_incomplete"), "tbl_df")
  expect_equal(NROW(attr(df_imp, "coord_incomplete")), 194)

})

test_that("coord_unlikely works", {
  expect_equal(NROW(df), 1500)

  ## remove records with unlikely elements
  df_imp <- dframe(df) %>% coord_unlikely()
  expect_equal(NROW(df_imp), 1488)
  expect_is(attr(df_imp, "coord_unlikely"), "tbl_df")
  expect_equal(NROW(attr(df_imp, "coord_unlikely")), 12)

})

test_that("coord_within works", {
  skip_if_not_installed("sf")

  zz <- sample_data_4
  df_within <- suppressMessages(coord_within(dframe(zz), country = "Israel"))

  expect_gt(NROW(zz), NROW(df_within))
  expect_is(attr(df_within, "coord_within"), "tbl_df")
  expect_gt(NROW(df_within), NROW(attr(df_within, "coord_within")))
})
