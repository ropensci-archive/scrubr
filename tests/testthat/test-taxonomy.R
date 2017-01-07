context("taxonomy functions")

test_that("taxonomy functions work", {
  skip_on_cran()

  res <- readRDS("taxdata1.rds")
  df <- dframe(res) %>% tax_no_epithet(name = "name")

  expect_is(res, "data.frame")
  expect_is(df, "tbl_df")
  #expect_equal(attr(df, "name_var"), "name")
  expect_is(attr(df, "tax_no_epithet"), "tbl_df")
  expect_equal(NROW(attr(df, "tax_no_epithet")), 9)
})
