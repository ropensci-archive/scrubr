#' Coordinate based cleaning
#'
#' @name coords
#' @param x (data.frame) A data.frame
#' @param lat,lon (character) Latitude and longitude column to use. See Details.
#' @param field (character) Name of field in input data.frame x with country
#' names
#' @param country (character) A single country name
#' @param which (character) one of "has_dec", "no_zeros", or "both" (default)
#' @param drop (logical) Drop bad data points or not. Either way, we parse out
#' bad data points as an attribute you can access. Default: `TRUE`
#' @param ignore.na (logical) To consider NA values as a bad point or not.
#' Default: `FALSE`
#' @param coorduncertainityLimit (numeric) numeric threshold for the
#' coordinateUncertainityInMeters variable. Default: 30000
#' @return Returns a data.frame, with attributes
#' @details
#' Explanation of the functions:
#'
#' - coord_impossible - Impossible coordinates
#' - coord_incomplete - Incomplete coordinates
#' - coord_imprecise - Imprecise coordinates
#' - coord_pol_centroids - Points at political centroids
#' - coord_unlikely - Unlikely coordinates
#' - coord_within - Filter points within user input
#' political boundaries
#' - coord_uncertain - Uncertain occurrances of measured through
#' coordinateUncertaintyInMeters default limit= 30000
#'
#' If either lat or lon (or both) given, we assign the given column name
#' to be standardized names of "latitude", and "longitude". If not given, we
#' attempt to guess what the lat and lon column names are and assign the
#' same standardized names. Assigning the same standardized names makes
#' downstream processing easier so that we're dealing with consistent column
#' names. On returning the data, we return the original names.
#'
#' For `coord_within`, we use `countriesLow` dataset from the
#' \pkg{rworldmap} package to get country borders.
#'
#' @section coord_pol_centroids:
#' Right now, this function only deals with city centroids, using the
#' [maps::world.cities] dataset of more than 40,000 cities.
#' We'll work on adding country centroids, and perhaps others (e.g.,
#' counties, states, provinces, parks, etc.).
#'
#' @examples
#' df <- sample_data_1
#'
#' # Remove impossible coordinates
#' NROW(df)
#' df[1, "latitude"] <- 170
#' df <- dframe(df) %>% coord_impossible()
#' NROW(df)
#' attr(df, "coord_impossible")
#'
#' # Remove incomplete cases
#' NROW(df)
#' df_inc <- dframe(df) %>% coord_incomplete()
#' NROW(df_inc)
#' attr(df_inc, "coord_incomplete")
#'
#'
#' # Remove imprecise cases
#' df <- sample_data_5
#' NROW(df)
#' ## remove records that don't have decimals at all
#' df_imp <- dframe(df) %>% coord_imprecise(which = "has_dec")
#' NROW(df_imp)
#' attr(df_imp, "coord_imprecise")
#' ## remove records that have all zeros
#' df_imp <- dframe(df) %>% coord_imprecise(which = "no_zeros")
#' NROW(df_imp)
#' attr(df_imp, "coord_imprecise")
#' ## remove both records that don't have decimals at all and those that
#' ## have all zeros
#' df_imp <- dframe(df) %>% coord_imprecise(which = "both")
#' NROW(df_imp)
#' attr(df_imp, "coord_imprecise")
#'
#'
#' # Remove unlikely points
#' NROW(df)
#' df_unlikely <- dframe(df) %>% coord_unlikely()
#' NROW(df_unlikely)
#' attr(df_unlikely, "coord_unlikely")
#'
#' # Remove points not within correct political borders
#' if (requireNamespace("rgbif", quietly = TRUE) && interactive()) {
#'    library("rgbif")
#'    wkt <- 'POLYGON((30.1 10.1,40 40,20 40,10 20,30.1 10.1))'
#'    res <- rgbif::occ_data(geometry = wkt, limit=300)$data
#' } else {
#'    res <- sample_data_4
#' }
#'
#' ## By specific country name
#' if (
#'   interactive() &&
#'   requireNamespace("sf", quietly=TRUE) && 
#'   requireNamespace("s2", quietly=TRUE) && 
#'   requireNamespace("rworldmap", quietly=TRUE)
#' ) {
#' NROW(res)
#' df_within <- dframe(res) %>% coord_within(country = "Israel")
#' NROW(df_within)
#' attr(df_within, "coord_within")
#'
#' ## By a field in your data - makes sure your points occur in one
#' ## of those countries
#' NROW(res)
#' df_within <- dframe(res) %>% coord_within(field = "country")
#' NROW(df_within)
#' head(df_within)
#' attr(df_within, "coord_within")
#' }
#'
#' # Remove those very near political centroids
#' ## not ready yet
#' # NROW(df)
#' # df_polcent <- dframe(df) %>% coord_pol_centroids()
#' # NROW(df_polcent)
#' # attr(df_polcent, "coord_polcent")
#'
#' ## lat/long column names can vary
#' df <- sample_data_1
#' head(df)
#' names(df)[2:3] <- c('mylon', 'mylat')
#' head(df)
#' df[1, "mylat"] <- 170
#' dframe(df) %>% coord_impossible(lat = "mylat", lon = "mylon")
#'
#' df <- sample_data_6
#'
#' # Remove uncertain occurances
#'
#' NROW(df)
#' df1<-df %>% coord_uncertain()
#' NROW(df1)
#' attr(df, "coord_uncertain")
#'
#' NROW(df)
#' df2<-df %>% coord_uncertain(coorduncertainityLimit = 20000)
#' NROW(df2)
#'
#' NROW(df)
#' df3<-df %>% coord_uncertain(coorduncertainityLimit = 20000,ignore.na=TRUE)
#' NROW(df3)

#' @export
#' @rdname coords
coord_incomplete <- function(x, lat = NULL, lon = NULL, drop = TRUE) {
  x <- do_coords(x, lat, lon)
  incomp <- x[!complete.cases(x$latitude, x$longitude), ]
  if (NROW(incomp) == 0) incomp <- NA
  if (drop) {
    x <- add_atts(x[complete.cases(x$latitude, x$longitude), ], get_atts(x))
  }
  row.names(incomp) <- NULL
  row.names(x) <- NULL
  structure(reassign(x), coord_incomplete = incomp)
}

get_atts <- function(x) {
  attributes(x)[names(attributes(x)) %in%
                  c('lat_var', 'lon_var', 'lat_var_orig', 'lon_var_orig')]
}

add_atts <- function(x, atts) {
  for (i in seq_along(atts)) {
    attr(x, names(atts)[i]) <- atts[[i]]
  }
  return(x)
}

#' @export
#' @rdname coords
coord_imprecise <- function(x, which = "both", lat = NULL, lon = NULL,
  drop = TRUE) {

  x <- do_coords(x, lat, lon)
  switch(
    which,
    has_dec = {
      incomp <- x[!grepl("[0-9]+\\.[0-9]+", x$longitude) | !grepl("[0-9]+\\.[0-9]+", x$latitude), ]
    },
    no_zeros = {
      incomp <- x[grepl("[0-9]+\\.[0]+$", x$longitude) | grepl("[0-9]+\\.[0]+$", x$latitude), ]
    },
    both = {
      incomp1 <- x[!grepl("[0-9]+\\.[0-9]+", x$longitude) | !grepl("[0-9]+\\.[0-9]+", x$latitude), ]
      incomp2 <- x[grepl("[0-9]+\\.[0]+$", x$longitude) | grepl("[0-9]+\\.[0]+$", x$latitude), ]
      incomp <- rbind(incomp1, incomp2)
      incomp <- incomp[!duplicated(incomp), ]
    }
  )

  if (NROW(incomp) == 0) incomp <- NA
  if (drop) {
    switch(
      which,
      has_dec = {
        x <- x[grepl("[0-9]+\\.[0-9]+", x$longitude), ]
        x <- x[grepl("[0-9]+\\.[0-9]+", x$latitude), ]
      },
      no_zeros = {
        x <- x[!grepl("[0-9]+\\.[0]+$", x$longitude), ]
        x <- x[!grepl("[0-9]+\\.[0]+$", x$latitude), ]
      },
      both = {
        x <- x[grepl("[0-9]+\\.[0-9]+", x$longitude), ]
        x <- x[grepl("[0-9]+\\.[0-9]+", x$latitude), ]
        x <- x[!grepl("[0-9]+\\.[0]+$", x$longitude), ]
        x <- x[!grepl("[0-9]+\\.[0]+$", x$latitude), ]
      }
    )
  }
  row.names(incomp) <- NULL
  row.names(x) <- NULL
  structure(reassign(x), coord_imprecise = incomp)
}

#' @export
#' @rdname coords
coord_impossible <- function(x, lat = NULL, lon = NULL, drop = TRUE) {
  x <- do_coords(x, lat, lon)
  no_nas <- x[complete.cases(x$latitude, x$longitude), ]
  np <- na.omit(no_nas[!abs(no_nas$latitude) <= 90 |
    !abs(no_nas$longitude) <= 180, ])
  if (NROW(np) == 0) np <- NA
  if (drop) {
    # x <- x[abs(x$latitude) <= 90 | abs(x$longitude) <= 180, ]
    x <- x[abs(x$latitude) <= 90, ]
    x <- x[abs(x$longitude) <= 180, ]
  }
  row.names(np) <- NULL
  row.names(x) <- NULL
  structure(reassign(x), coord_impossible = np)
}

#' @export
#' @rdname coords
coord_unlikely <- function(x, lat = NULL, lon = NULL, drop = TRUE) {
  x <- do_coords(x, lat, lon)
  # FIXME: using 0,0 for now, what else is there?
  unl <- na.omit(x[x$latitude == 0 & x$longitude == 0, ])
  if (NROW(unl) == 0) unl <- NA
  if (drop) x <- x[!x$latitude == 0 & !x$longitude == 0, ]
  row.names(unl) <- NULL
  row.names(x) <- NULL
  structure(reassign(x), coord_unlikely = unl)
}

#' @export
#' @rdname coords
coord_within <- function(x, field = NULL, country = NULL,
                         lat = NULL, lon = NULL, drop = TRUE) {
  rmap <- check4pkg("rworldmap")
  if (rmap) {
    pkgenv <- new.env()
    data("countriesLow", package = "rworldmap", envir = pkgenv)
  }
  check4pkg("sf")

  x <- do_coords(x, lat, lon)
  if (!is.null(field)) {
    if (!field %in% names(x)) stop("field not in input data.frame",
      call. = FALSE)
  }

  z <- sf::st_as_sf(x, coords = c("longitude", "latitude"))
  z <- sf::st_set_crs(z, "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
  refctrys <- as.character(get("countriesLow", envir = pkgenv)@data$SOVEREIGNT)

  if (is.null(field)) {
    ctry <- get("countriesLow", envir = pkgenv)[refctrys == country, ]
  } else {
    uniqctrys <- na.omit(unique(x[field][[1]]))
    if (!all(uniqctrys %in% unique(refctrys))) {
      notmatch <- uniqctrys[!uniqctrys %in% unique(refctrys)]
      warning("Some countries do not match reference country dataset:\n ",
        notmatch)
    }
    ctry <- get("countriesLow", envir = pkgenv)[refctrys %in% uniqctrys, ]
  }

  ctry <- as(ctry, "sf")
  bb <- sf::st_join(z, ctry, join = sf::st_within)
  wth <- tibble::as_tibble(x[is.na(bb$ADMIN), ])

  if (drop) {
    x <- tibble::as_tibble(x[!is.na(bb$ADMIN), ])
  }
  if (NROW(wth) == 0) wth <- NA
  row.names(wth) <- NULL
  row.names(x) <- NULL
  structure(reassign(x), coord_within = wth)
}

#' @export
#' @rdname coords
coord_pol_centroids <- function(x, lat = NULL, lon = NULL, drop = TRUE) {
  stop("not ready yet", call. = FALSE)
  # x <- do_coords(x, lat, lon)

  # check4pkg("maps")
  # check4pkg("sp")
  # class(x) <- "data.frame"
  # x <- na.omit(x)
  # coordinates(x) <- ~longitude + latitude
  # citys <- make_cities()
  # polcent <- sp::over(x, gBuffer(citys[1,], width = 0.1))
  # # polcent <- sp::over(x, gBuffer(SpatialPoints(citys), width = 0.1))
  #
  # out <- list()
  # for (i in seq_len(NROW(citys))) {
  # # for (i in 1:seq) {
  #   tmp <- sp::over(x, gBuffer(citys[i,], width = 0.1))
  #   zz <- tmp[!is.na(tmp)]
  #   out[[i]] <- if (length(zz) > 0) {
  #     x[zz,]
  #   } else {
  #     NULL
  #   }
  # }
  # in_cent <- ct(out)
  #
  # if (NROW(polcent) == 0) polcent <- NA
  # if (drop) x <- x[!x$latitude == 0 & !x$longitude == 0, ]
  # row.names(polcent) <- NULL
  # row.names(x) <- NULL
  # structure(x, coord_polcent = polcent)
}

# make_cities <- function() {
#   wc <- world.cities
#   coordinates(wc) <- ~long + lat
#   wc
# }

#' @export
#' @rdname coords
coord_uncertain <- function(x, coorduncertainityLimit = 30000, drop = TRUE,
  ignore.na = FALSE){

  if(!("coordinateuncertaintyinmeters"  %in%  tolower(names(x)))){
    stop(" 'coordinateuncertainityInMeters' variable is missing",
      call. = FALSE)
  }
  names(x)[grep("coordinateuncertaintyinmeters",
    tolower(names(x)))] <- "coordinateuncertaintyinmeters"
  if(ignore.na) x <- x[!is.na(x$coordinateuncertaintyinmeters), ]
  uncertain_indices <-
    which(x$coordinateuncertaintyinmeters > coorduncertainityLimit)
  uncertain <- x[uncertain_indices, ]
  if (NROW(uncertain) == 0) uncertain <- NA
  if(drop){
    certain_indices <- setdiff(seq_len(NROW(x)), uncertain_indices)
    x <- x[certain_indices, ]
  }
  row.names(uncertain) <- NULL
  row.names(x) <- NULL
  structure(x, coord_uncertain=uncertain)
}
