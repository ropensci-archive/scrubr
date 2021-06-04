#' Filter points within ecoregions
#'
#' @export
#' @param x (data.frame) A data.frame
#' @param dataset (character) the dataset to use. one of: "meow" (Marine
#' Ecoregions of the World), "fao" (). See Details.
#' @param region (character) one or more region names. has the form `a:b` where
#' `a` is a variable name (column in the sf object) and `b` is the value you want
#' to filter to within that variable. See Details.
#' @param lat,lon (character) name of the latitude and longitude column to use
#' @param drop (logical) Drop bad data points or not. Either way, we parse out
#' bad data points as an attribute you can access. Default: `TRUE`
#' #param ignore.na (logical) To consider NA values as a bad point or not.
#' Default: `FALSE`
#' @return Returns a data.frame, with attributes
#' @details see `scrubr_cache` for managing the cache of data
#' @section dataset options:
#'
#' - Marine Ecoregions of the World (meow):
#'   - data from: https://opendata.arcgis.com/datasets/ed2be4cf8b7a451f84fd093c2e7660e3_0.geojson
#' - Food and Agriculture Organization (fao):
#'   - data from: http://www.fao.org/geonetwork/srv/en/main.home?uuid=ac02a460-da52-11dc-9d70-0017f293bd28
#'
#' @section region options:
#'
#' - within meow:
#'   - ECOREGION: many options, see `regions_meow()`
#'   - ECO_CODE: many options, see `regions_meow()`
#'   - and you can use others as well; run `regions_meow()` to get the data used
#'     within `eco_region()` and see what variables/columns can be used
#' - within fao:
#'   - OCEAN: Atlantic, Pacific, Indian, Arctic
#'   - SUBOCEAN: 1 through 11 (inclusive)
#'   - F_AREA (fishing area): 18, 21, 27, 31, 34, 37, 41, 47, 48, 51, 57, 58,
#'     61, 67, 71, 77, 81, 87, 88
#'   - and you can use others as well; run `regions_fao()` to get the data used
#'     within `eco_region()` and see what variables/columns can be used
#'
#' @examples \dontrun{
#' if (requireNamespace("mapview") && requireNamespace("sf") && interactive()) {
#' ## Marine Ecoregions of the World
#' wkt <- 'POLYGON((-119.8 12.2, -105.1 11.5, -106.1 21.6, -119.8 20.9, -119.8 12.2))'
#' res <- rgbif::occ_data(geometry = wkt, limit=300)$data
#' res2 <- sf::st_as_sf(res, coords = c("decimalLongitude", "decimalLatitude"))
#' res2 <- sf::st_set_crs(res2, 4326)
#' mapview::mapview(res2)
#' tmp <- eco_region(dframe(res), dataset = "meow",
#'    region = "ECOREGION:Mexican Tropical Pacific")
#' tmp2 <- sf::st_as_sf(tmp, coords = c("decimalLongitude", "decimalLatitude"))
#' tmp2 <- sf::st_set_crs(tmp2, 4326)
#' mapview::mapview(tmp2)
#' ## filter many regions at once
#' out <- eco_region(dframe(res), dataset = "meow",
#'    region = c("ECOREGION:Mexican Tropical Pacific", "ECOREGION:Seychelles"))
#' out
#' out2 <- sf::st_as_sf(out, coords = c("decimalLongitude", "decimalLatitude"))
#' out2 <- sf::st_set_crs(out2, 4326)
#' mapview::mapview(out2)
#'
#' ## FAO
#' ## FIXME - this needs fixing, broken
#' wkt <- 'POLYGON((72.2 38.5,-173.6 38.5,-173.6 -41.5,72.2 -41.5,72.2 38.5))'
#' manta_ray <- rgbif::name_backbone("Mobula alfredi")$usageKey
#' res <- rgbif::occ_data(manta_ray, geometry = wkt, limit=300, hasCoordinate = TRUE)
#' dat <- sf::st_as_sf(res$data, coords = c("decimalLongitude", "decimalLatitude"))
#' dat <- sf::st_set_crs(dat, 4326)
#' mapview::mapview(dat)
#' tmp <- eco_region(dframe(res$data), dataset = "fao", region = "OCEAN:Indian")
#' tmp <- tmp[!is.na(tmp$decimalLongitude), ]
#' tmp2 <- sf::st_as_sf(tmp, coords = c("decimalLongitude", "decimalLatitude"))
#' tmp2 <- sf::st_set_crs(tmp2, 4326)
#' mapview::mapview(tmp2)
#' }}
eco_region <- function(x, dataset = "meow", region,
  lat = NULL, lon = NULL, drop = TRUE) {

  check4pkg("sf")
  assert(dataset, "character")
  stopifnot(dataset %in% c("meow", "fao"))
  assert(region, "character")
  stopifnot(all(grepl(":", region)))
  scrubr_cache$mkdir()

  x <- do_coords(x, lat, lon)
  z <- sf::st_as_sf(x, coords = c("longitude", "latitude"))
  z <- sf::st_set_crs(z, "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")

  ref_sf <- switch(dataset, meow = regions_meow(), fao = regions_fao())
  er_split <- lapply(region, function(w) strsplit(w, ":")[[1]])
  tmp <- c()
  for (i in seq_along(er_split)) {
    tmp[[i]] <- ref_sf[ref_sf[[ er_split[[i]][1] ]] %in% er_split[[i]][2], ]
  }
  ref_target <- do.call(rbind, tmp)

  bb <- sf::st_join(z, ref_target, join = sf::st_within)
  bb_is_na <- bb[is.na(bb$FID), ]
  wth <- tibble::as_tibble(x[x$key %in% bb_is_na$key, ])

  if (drop) {
    bb_not_na <- bb[!is.na(bb$FID), ]
    x <- tibble::as_tibble(x[x$key %in% bb_not_na$key, ])
  }
  if (NROW(wth) == 0) wth <- NA
  row.names(wth) <- NULL
  row.names(x) <- NULL
  structure(reassign(x), coord_ecoregion = wth,
    dataset = dataset, region = region)
}

#' @export
#' @rdname eco_region
regions_meow <- function() {
  path <- file.path(scrubr_cache$cache_path_get(), "meow.geojson")
  if (file.exists(path)) {
    message("meow.geojson exists in the cache")
  } else {
    meow_url <- "https://opendata.arcgis.com/datasets/ed2be4cf8b7a451f84fd093c2e7660e3_0.geojson"
    curl::curl_download(meow_url, path)
  }
  sf::read_sf(path)
}

#' @export
#' @rdname eco_region
regions_fao <- function() {
  path <- file.path(scrubr_cache$cache_path_get(), "fao.geojson")
  if (file.exists(path)) {
    message("fao.geojson exists in the cache")
  } else {
    fao_url <- "http://www.fao.org/figis/geoserver/area/ows?service=WFS&request=GetFeature&version=1.0.0&typeName=area:FAO_AREAS&outputFormat=application/json"
    curl::curl_download(fao_url, path)
  }
  while(!file.exists(path)) Sys.sleep(0.5)
  sf::read_sf(path)
}

# http://www.fao.org/figis/geoserver/area/ows?service=WFS&request=GetFeature&version=1.0.0&typeName=area:FAO_AREAS&outputFormat=SHAPE-ZIP
# http://www.fao.org/figis/geoserver/area/ows?service=WFS&request=GetFeature&version=1.0.0&typeName=area:FAO_AREAS&outputFormat=application/json
