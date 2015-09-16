###### code adapted from the leaflet package - source at github.com/rstudio/leaflet
guess_latlon <- function(x, lat=NULL, lon=NULL) {
  nms <- names(x)
  if (is.null(lat) && is.null(lon)) {
    lats <- nms[grep("^(lat|latitude)$", nms, ignore.case = TRUE)]
    lngs <- nms[grep("^(lon|lng|long|longitude)$", nms, ignore.case = TRUE)]

    if (length(lats) == 1 && length(lngs) == 1) {
      if (length(nms) > 2) {
        message("Assuming '", lngs, "' and '", lats,
                "' are longitude and latitude, respectively")
      }
      # return(list(lon = lngs, lat = lats))
      names(x)[names(x) %in% lats] <- "latitude"
      names(x)[names(x) %in% lngs] <- "longitude"
      x
    } else {
      stop("Couldn't infer longitude/latitude columns, please specify with 'lat'/'lon' parameters", call. = FALSE)
    }
  } else {
    # return(list(lon = lon, lat = lat))
    x
  }
}
