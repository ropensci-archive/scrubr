context("taxonomy functions")

test_that("taxonomy functions work", {
  skip_on_cran()

  library("rgbif")
  res <- occ_data(limit = 100)$data
  df <- dframe(res) %>% tax_no_epithet(name = "name")
  attr(df, "name_var")
  attr(df, "tax_no_epithet")

  expect_is(res, "data.frame")
  expect_is(df, "dframe")
  expect_equal(attr(df, "name_var"), "name")
  expect_is(attr(df, "tax_no_epithet"), "dframe")
  expect_equal(NROW(attr(df, "tax_no_epithet")), 1)
})
