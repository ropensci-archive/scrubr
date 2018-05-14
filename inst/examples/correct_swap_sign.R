library(sp)
library(raster)
library(XML)
library(lattice)
library(grid)
library(foreign)
library(maptools)
library(rgbif)    
library(dismo)
library(rgdal)
library(utils)
library(foreach)
library(doParallel)
library(doSNOW)
library(rgeos)
library(devtools)
install.packages(c("XMLSchema", "SSOAP"), 
                   repos = c("http://packages.ropensci.org", 
                             "http://cran.rstudio.com"))
devtools::install_github("ropensci/taxizesoap")
library(taxizesoap)

#' Loading data from the gbif database
#' @param species_name Specify the name of the species in order to download the
#'   data from the gbif database
#' @param start Specify the start index to begin the download with
#' @param limit Specify the number of occurrences to download (max: 200.000)
initData <- function(species_name, start = 0, limit = 200) {
  occ <- occ_search(scientificName = species_name, limit = limit,
                    hasCoordinate = TRUE, start = start)
  return (occ)
}

#' Get the species properties from the worms database to check marine species
#' with failing location check
#' @param species_name Name of the species to get the properties for
#' @return speciesOpts - habitat properties of the named species
getSpeciesOpts <- function(species_name) {
  # query the worms database for habitat
  worms <- worms_records(scientific=species_name)
  # setup a list with species properties
  speciesOpts <- list()
  if (NROW(worms) == 0 && NCOL(worms) == 0) {
    speciesOpts$isMarine <- 0
  } else {
    speciesOpts$isMarine <- max(worms$isMarine, na.rm = TRUE)
  }
  return (speciesOpts)
}
#' Download spatial data from natural earth and unzip it
initLocation <- function() {
  # load all countries of the world
  countries_name <- "countries.zip"
  if (!file.exists("countries.zip")) {
    download.file(url = paste("http://www.naturalearthdata.com/http//",
                              "www.naturalearthdata.com/download/50m/cultural/",
                              "ne_50m_admin_0_countries.zip", sep = ""),
                  destfile = countries_name)
    unzip(countries_name)
  }
}

#' Read the shape file utilizing the rgdal package
#' Returns a data frame containing country info
openShape <- function() {
  # ogrDrivers()
  # open vector file (esri-shapeformat)
  countries <- try(readOGR(dsn="ne_50m_admin_0_countries.shp"))
  return (countries)
}



#' Checks if lat, long locations concurs with country codes. Checks lat, long
#' if lat, long lies within country shape
#' @param current_occ_chunk One data chunk from gbif containing occurences
#' @param countries Dataset of all countries in the world provided by
#'   natural earth.
#' @return check_result: Boolean values indicating if the locations of the

checkLocation <- function(current_occ_chunk, countries, species_opts) {

  # create empty result container
  # by default the points and the countries do not match
  check_result <- logical(NROW(current_occ_chunk$data))

  # access location parameter from current original occurence
  lat <- current_occ_chunk$data$decimalLatitude
  long <- current_occ_chunk$data$decimalLongitude
  countryCode <- current_occ_chunk$data$countryCode

  # create spatial point from lat, long
  current_occ_points <- SpatialPointsDataFrame(cbind(long, lat),
                                               data = current_occ_chunk$data)
  # reproject points and countries to global metric projection
  # using pseudo transmercator projection
  proj4string(current_occ_points) <- proj4string(countries)
  current_occ_points_3857 <- spTransform(current_occ_points,
                                         CRS("+init=epsg:3857"))
  countries_3857 <- spTransform(countries, CRS("+init=epsg:3857"))

  # Use buffer arround the countries to match also the points which are
  # inaccurate and lie at the coast side
  # positive buffer for terrestial species which are located in the sea
  # negative buffer for marine species which are located on land
  if (species_opts$isMarine == 0) {
    country_buffer_3857 <- gBuffer(countries_3857, width = 10000, byid = TRUE)
  } else if (species_opts$isMarine == 1) {
    country_buffer_3857 <- gBuffer(countries_3857, width = -10000, byid = TRUE)
  }
  # Check all points from a chunk against all countries
  intersectingPolygons <- over(current_occ_points_3857, country_buffer_3857)

  # Marine check
  nonIntersectingPoints_idx <- which(is.na(intersectingPolygons$type))
  intersectingPoints_idx <- which(!is.na(intersectingPolygons$type))

  # not intersecting points
  if (species_opts$isMarine == 1) { # Marine species only live in the sea
    check_result[nonIntersectingPoints_idx] <- TRUE
    check_result[intersectingPoints_idx] <- FALSE
  } else { # Terrestial species only live on land
    check_result[nonIntersectingPoints_idx] <- FALSE
    check_result[intersectingPoints_idx] <- TRUE

    # get indexes from country codes which are not NA
    valid_CountryCodes_idx <- which(!is.na(countryCode))
    # get indexes from polygon iso codes which are not NA
    valid_PolygonIsoCodes_idx <- which(!is.na(intersectingPolygons$iso_a2))
    # combine the two indices to get all valid intersections
    valid_idx <- intersect(valid_CountryCodes_idx, valid_PolygonIsoCodes_idx)
    # check iso and country codes for valid indices
    check_result[valid_idx] <- countryCode[valid_idx] ==
      intersectingPolygons[valid_idx,]$iso_a2
  }
  return (check_result)
}




#' Tries to correct the locations by swapping the sign of lat, long, latlong &
#' checks if the lat long of the point concurs the country shape with the
#' country code
#' @param current_occ_chunk One chunk of several gbif occurence
#' @param countries Dataset of all countries in the world provided by
#'   natural earth.
#' @return current_occ_chunk_corrected: Corrected or unchanged but flagged
#'   occurences
correctSign <- function(current_occ_chunk, countries, species_opts) {
  # prepare temporal correction for each check
  corrected_current_occ_chunk_lat <- current_occ_chunk
  corrected_current_occ_chunk_long <- current_occ_chunk
  corrected_current_occ_chunk_latlong <- current_occ_chunk

  # access original location parameter from current occurence
  lat <- current_occ_chunk$data$decimalLatitude
  long <- current_occ_chunk$data$decimalLongitude

  # apply correction
  # swapped lat
  corrected_current_occ_chunk_lat$data$decimalLatitude <- -1 * lat
  # swapped long
  corrected_current_occ_chunk_long$data$decimalLongitude <- -1 * long
  # swapped lat and long
  corrected_current_occ_chunk_latlong$data$decimalLatitude <- -1 * lat
  corrected_current_occ_chunk_latlong$data$decimalLongitude <- -1 * long

  # recheck location for each modification
  isCorrectedLocationLatCorrect <- checkLocation(
    current_occ_chunk = corrected_current_occ_chunk_lat, countries = countries,
    species_opts = species_opts)
  isCorrectedLocationLongCorrect <- checkLocation(
    current_occ_chunk = corrected_current_occ_chunk_long, countries = countries,
    species_opts = species_opts)
  isCorrectedLocationLatLongCorrect <- checkLocation(
    current_occ_chunk = corrected_current_occ_chunk_latlong,
    countries = countries, species_opts = species_opts)
  current_occ_chunk_corrected <- current_occ_chunk

  # indices of corrected occurences for each modification
  lat_correct_idx <- which(isCorrectedLocationLatCorrect)
  long_correct_idx <- which(isCorrectedLocationLongCorrect)
  latlong_correct_idx <- which(isCorrectedLocationLatLongCorrect)

  # adopt corrected and checked modification to the original data and flag
  # modification for each type of modification.
  # set initial correction flag to incorrect data (3) - change modification flag
  # if modification is adopted (2)
  current_occ_chunk_corrected$data$correction_flag <- 3
  if (length(lat_correct_idx) > 0) { # adopt lat modification
    current_occ_chunk_corrected$data[lat_correct_idx,] <-
      corrected_current_occ_chunk_lat$data[lat_correct_idx,]
    current_occ_chunk_corrected$data[lat_correct_idx,]$correction_flag <- 2
  } else if (length(long_correct_idx) > 0) { # adopt long modification
    current_occ_chunk_corrected$data[long_correct_idx,] <-
      corrected_current_occ_chunk_long$data[long_correct_idx,]
    current_occ_chunk_corrected$data[long_correct_idx,]$correction_flag <- 2
  } else if (length(latlong_correct_idx) > 0) { # adopt latlong modification
    current_occ_chunk_corrected$data[latlong_correct_idx,] <-
      corrected_current_occ_chunk_latlong$data[latlong_correct_idx,]
    current_occ_chunk_corrected$data[latlong_correct_idx,]$correction_flag <- 2
  }
  return (current_occ_chunk_corrected)
}




#' Checks if point with lat & long would concure in country shape with country
#' code if lat and long are swapped;
#' switched lat/long cannot exceed the dimension of valid lat/long numbers
#' @param current_occ_chunk One data chunk from gbif containing occurences
#' @param countries Dataset of all countries in the world provided by
#'   natural earth.
#' @return current_occ_chunk_corrected: Corrected or unchanged but flagged
#'   occurences
correctSwap <- function(current_occ_chunk, countries, species_opts) {

  corrected_current_occ_chunk_swapped <- current_occ_chunk

  # access original location parameter from current occurence
  lat <- current_occ_chunk$data$decimalLatitude
  long <- current_occ_chunk$data$decimalLongitude

  # swap lat long only if swap does not exceed bounding box of
  # coordinate system.
  valid_lat_idx <- which(long <= 90 && long >= -90)

  # actual swap
  corrected_current_occ_chunk_swapped$data$decimalLatitude[valid_lat_idx] <-
    long[valid_lat_idx]
  corrected_current_occ_chunk_swapped$data$decimalLongitude[valid_lat_idx] <-
    lat[valid_lat_idx]

  # recheck location
  isCorrectedLocationSwapCorrect <- checkLocation(
    current_occ_chunk = corrected_current_occ_chunk_swapped,
    countries = countries, species_opts = species_opts)

  current_occ_chunk_corrected <- current_occ_chunk

  # get indices of corrected and checked data
  swap_correct_idx <- which(isCorrectedLocationSwapCorrect)

  # adopt corrected and checked data to original chunk
  if (length(swap_correct_idx) > 0) {
    current_occ_chunk_corrected$data[swap_correct_idx,] <-
      corrected_current_occ_chunk_swapped$data[swap_correct_idx,]
    current_occ_chunk_corrected$data[swap_correct_idx,]$correction_flag <- 2
  }
  return (current_occ_chunk_corrected)
}

#'Helper function for calling and examples
helper<-function(fun,species_name,limit){
   
   # Load shape file
  initLocation()
  countries <- openShape()
  
  # Load species properties from worms
  species_opts <- getSpeciesOpts(species_name)
  

  
  
  current_occ_chunk <- initData(
    species_name = species_name,
    
    limit = limit)
 
  current_occ_chunk_corrected <- current_occ_chunk
  current_occ_chunk_corrected$data$correction_flag <- 1
  
  current_occ_chunk_corrected1 <- current_occ_chunk_corrected
  
  isLocationCorrect <- checkLocation(
    current_occ_chunk = current_occ_chunk_corrected, countries = countries,
    species_opts = species_opts)
  # get the indices of the incorrect records which have to be corrected
  locationIncorrect_idx <- which(!isLocationCorrect)
  # apply different modification or correction modi
  length(locationIncorrect_idx)
  if (length(locationIncorrect_idx) > 0) 
  {
    correctedLocations <- fun(
      current_occ_chunk = current_occ_chunk_corrected, countries = countries,
      species_opts = species_opts)
    
    current_occ_chunk_corrected1$data[locationIncorrect_idx,] <-
      correctedLocations$data[locationIncorrect_idx,]
    
    
  }
  
  return(current_occ_chunk_corrected1)
 }
 

#'Examples,"Delphinus delphis"-Short-beaked common dolphin,example for both swap and sign functions
 x1<-helper(correctSwap,"Delphinus delphis",200)
 x2<-helper(correctSign,"Delphinus delphis",200)


