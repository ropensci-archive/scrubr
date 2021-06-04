skip_on_cran()
skip_if_not_installed("rgbif")

test_that("eco_region: Marine Ecoregions of the World", {
  ## prepare data for test
  # wkt <- 'POLYGON((-119.8 12.2, -105.1 11.5, -106.1 21.6, -119.8 20.9, -119.8 12.2))'
  # er1 <- rgbif::occ_data(geometry = wkt, limit=300)$data
  # saveRDS(er1, "tests/testthat/er1.rds", version = 2)
  er1 <- readRDS("er1.rds")

  meow <- regions_meow()
  mtp <- meow[meow$ECOREGION == "Mexican Tropical Pacific",]
  
  tmp <- eco_region(dframe(er1), dataset = "meow",
     region = "ECOREGION:Mexican Tropical Pacific")

  for (i in c("tbl", "data.frame")) expect_is(er1, i)
  for (i in c("tbl", "data.frame")) expect_is(tmp, i)
  # check that points are inside of Mexican Tropical Pacific
  tmpsf <- sf::st_as_sf(tmp, coords = c("decimalLongitude", "decimalLatitude"))
  tmpsf <- sf::st_set_crs(tmpsf, 4326)
  z <- sf::st_within(tmpsf, mtp, sparse = FALSE)
  expect_true(all(z))
})

# test_that("eco_region: Food and Agriculture Organization", {
#   ## FIXME - this needs fixing, broken

#   ## prepare data for test
#   # wkt <- 'POLYGON((72.2 38.5,-173.6 38.5,-173.6 -41.5,72.2 -41.5,72.2 38.5))'
#   # manta_ray <- rgbif::name_backbone("Mobula alfredi")$usageKey
#   # er2 <- rgbif::occ_data(manta_ray, geometry = wkt, limit=300,
#   #   hasCoordinate = TRUE)$data
#   # saveRDS(er2, "tests/testthat/er2.rds", version = 2)
#   er2 <- readRDS("er2.rds")

#   fao <- regions_fao()
#   indocean <- fao[fao$OCEAN == "Indian",]
  
#   tmp <- eco_region(dframe(er2), dataset = "fao", region = "OCEAN:Indian")

#   for (i in c("tbl", "data.frame")) expect_is(er2, i)
#   for (i in c("tbl", "data.frame")) expect_is(tmp, i)
#   # check that points are inside of Indian Ocean
#   tmpsf <- sf::st_as_sf(tmp, coords = c("decimalLongitude", "decimalLatitude"))
#   tmpsf <- sf::st_set_crs(tmpsf, 4326)
#   z <- sf::st_within(tmpsf, indocean, sparse = FALSE)
#   # not a great test, because there's sub-ocean's, only some points fall
#   # in the various Indian ocean polygons
#   expect_true(any(z))
# })
