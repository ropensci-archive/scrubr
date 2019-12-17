#' Filter points within ecoregions
#'
#' @export
#' @param x (data.frame) A data.frame
#' @param dataset (character) the dataset to use. one of: "meow" (Marine
#' Ecoregions of the World), "fao" (). See Details.
#' @param ecoregion (character) the ecoregion name. See Details.
#' @param lat,lon (character) Latitude and longitude column to use. See Details.
#' @param drop (logical) Drop bad data points or not. Either way, we parse out
#' bad data points as an attribute you can access. Default: `TRUE`
#' @param ignore.na (logical) To consider NA values as a bad point or not.
#' Default: `FALSE`
#' @return Returns a data.frame, with attributes
#' @details see `scrubr_cache` for managing the cache of data
#' @section Datasets: and ecoregions:
#'
#' - meow: https://opendata.arcgis.com/datasets/ed2be4cf8b7a451f84fd093c2e7660e3_0.geojson
#' - fao:http://www.fao.org/geonetwork/srv/en/main.home?uuid=ac02a460-da52-11dc-9d70-0017f293bd28
#' http://www.fao.org/figis/geoserver/area/ows?service=WFS&request=GetFeature&version=1.0.0&typeName=area:FAO_AREAS&outputFormat=SHAPE-ZIP
#' http://www.fao.org/figis/geoserver/area/ows?service=WFS&request=GetFeature&version=1.0.0&typeName=area:FAO_AREAS&outputFormat=application/json
#'
#' @section Ecoregions:
#'
#' - meow: 
#' - fao: asdfasdf
#'
#' @examples
#' ## Marine Ecoregions of the World
#' wkt <- 'POLYGON((-119.8 12.2, -105.1 11.5, -106.1 21.6, -119.8 20.9, -119.8 12.2))'
#' res <- rgbif::occ_data(geometry = wkt, limit=300)$data
#' res2 <- sf::st_as_sf(res, coords = c("decimalLongitude", "decimalLatitude"))
#' res2 <- sf::st_set_crs(res2, 4326)
#' mapview::mapview(res2)
#' tmp <- ecoregion(dframe(res), dataset = "meow",
#'    ecoregion = "ECOREGION:Mexican Tropical Pacific")
#' tmp2 <- sf::st_as_sf(tmp, coords = c("decimalLongitude", "decimalLatitude"))
#' tmp2 <- sf::st_set_crs(tmp2, 4326)
#' mapview::mapview(tmp2)
#' 
#' ## FAO
#' wkt <- 'POLYGON((72.2 38.5,-173.6 38.5,-173.6 -41.5,72.2 -41.5,72.2 38.5))'
#' manta_ray <- rgbif::name_backbone("Mobula alfredi")$usageKey
#' res <- rgbif::occ_data(manta_ray, geometry = wkt, limit=300, hasCoordinate = TRUE)
#' dat <- sf::st_as_sf(res$data, coords = c("decimalLongitude", "decimalLatitude"))
#' dat <- sf::st_set_crs(dat, 4326)
#' mapview::mapview(dat)
#' tmp <- ecoregion(dframe(res$data), dataset = "fao", ecoregion = "OCEAN:Indian")
#' library(dplyr)
#' tmp <- filter(tmp, !is.na(decimalLongitude))
#' tmp2 <- sf::st_as_sf(tmp, coords = c("decimalLongitude", "decimalLatitude"))
#' tmp2 <- sf::st_set_crs(tmp2, 4326)
#' mapview::mapview(tmp2)
ecoregion <- function(x, dataset = "meow", ecoregion,
  lat = NULL, lon = NULL, drop = TRUE) {

  check4pkg("sf")
  assert(dataset, "character")
  stopifnot(dataset %in% c("meow", "fao"))
  assert(ecoregion, "character")
  stopifnot(grepl(":", ecoregion))
  scrubr_cache$mkdir()

  x <- do_coords(x, lat, lon)
  z <- sf::st_as_sf(x, coords = c("longitude", "latitude"))
  z <- sf::st_set_crs(z, 4326)

  ref_sf <- switch(dataset, meow = do_meow(), fao = do_fao())
  er_split <- strsplit(ecoregion, ":")[[1]]
  ref_target <- ref_sf[ref_sf[[er_split[1]]] %in% er_split[2], ]

  bb <- sf::st_join(z, ref_target, join = sf::st_within)
  wth <- tibble::as_tibble(x[is.na(bb$FID), ])

  if (drop) {
    x <- tibble::as_tibble(x[!is.na(bb$FID), ])
  }
  if (NROW(wth) == 0) wth <- NA
  row.names(wth) <- NULL
  row.names(x) <- NULL
  structure(reassign(x), coord_ecoregion = wth,
    dataset = dataset, ecoregion = ecoregion)
}

do_meow <- function() {
  path <- file.path(scrubr_cache$cache_path_get(), "meow.geojson")
  if (file.exists(path)) {
    message("meow.geojson exists in the cache")
  } else {
    meow_url <- "https://opendata.arcgis.com/datasets/ed2be4cf8b7a451f84fd093c2e7660e3_0.geojson"
    curl::curl_download(meow_url, path)
  }
  sf::read_sf(path)
}
# w <- do_meow()
# mapview::mapview(w)

do_fao <- function() {
  path <- file.path(scrubr_cache$cache_path_get(), "fao.geojson")
  if (file.exists(path)) {
    message("fao.geojson exists in the cache")
  } else {
    fao_url <- "http://www.fao.org/figis/geoserver/area/ows?service=WFS&request=GetFeature&version=1.0.0&typeName=area:FAO_AREAS&outputFormat=application/json"
    curl::curl_download(fao_url, path)
  }
  sf::read_sf(path)
}
# z <- do_fao()
# mapview::mapview(z)
