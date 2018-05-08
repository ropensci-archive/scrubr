context("dedup functions")

test_that("dedup works correctly", {
  df <- sample_data_1
  smalldf <- df[1:20, ]
  smalldf <- rbind(smalldf, smalldf[10,])
  smalldf[21, "key"] <- 1088954555
  dp <- dframe(smalldf) %>% dedup()
  dups <- attr(dp, "dups")

  expect_is(df, "data.frame")
  expect_is(smalldf, "data.frame")
  expect_is(dp, "tbl_df")
  expect_is(dups, "tbl_df")
  expect_lt(NROW(dp), NROW(smalldf))
  expect_equal(NROW(dups), 1)
  expect_named(attributes(dp), c('names', 'row.names', '.internal.selfref',
                                 'class', 'dups'))
})

test_that("dedup works correctly with number heavy dups", {
  testdf <- mtcars
  testdf <- rbind(testdf, testdf[31:32,])
  row.names(testdf) <- NULL

  dp <- dframe(testdf) %>% dedup(tolerance = 0.95)
  dups <- attr(dp, "dups")

  expect_is(testdf, "data.frame")
  expect_is(dp, "tbl_df")
  expect_is(dups, "tbl_df")
  expect_lt(NROW(dp), NROW(testdf))
  expect_equal(NROW(dups), 2)
  expect_named(attributes(dp), c('names', 'row.names', '.internal.selfref',
                                 'class', 'dups'))
})

test_that("dedup works correctly with iris dups", {
  testdf <- iris
  testdf <- rbind(testdf, testdf[145:150,])

  dp <- dframe(testdf) %>% dedup(tolerance = 0.99)
  dups <- attr(dp, "dups")

  expect_is(testdf, "data.frame")
  expect_is(dp, "tbl_df")
  expect_is(dups, "tbl_df")
  expect_lt(NROW(dp), NROW(testdf))
  expect_equal(NROW(dups), 8)
  expect_named(attributes(dp), c('names', 'row.names', '.internal.selfref',
                                 'class', 'dups'))
})

test_that("dedup works with how=all", {
  df <- sample_data_1
  smalldf <- df[1:20, ]
  smalldf <- rbind(smalldf, smalldf[10,])
  smalldf[21, "key"] <- 1088954555
  dp <- dframe(smalldf) %>% dedup(how = "all")
  dups <- attr(dp, "dups")

  expect_is(df, "data.frame")
  expect_is(smalldf, "data.frame")
  expect_is(dp, "tbl_df")
  expect_is(dups, "tbl_df")
  expect_lt(NROW(dp), NROW(smalldf))
  expect_equal(NROW(dups), 2)
  expect_named(attributes(dp), c('names', 'row.names', 'class', 'dups'))
})
