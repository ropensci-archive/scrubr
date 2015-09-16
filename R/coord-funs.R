#' Coordinate based cleaning
#'
#' @name coords
#' @param x (data.frame) A data.frame
#' @param drop (logical) Drop bad data points or not. Either way, we parse
#' out bade data points as an attribute you can access. Default: \code{TRUE}
#' @return Returns a data.frame, with attributes
#' @examples
#' df <- sample_data_1
#'
#' # Remove impossible coordinates
#' NROW(df)
#' df <- clean_df(df) %>% coord_impossible()
#' NROW(df)
#' attr(df, "coord_impossible")
#'
#' # Remove incomplete cases
#' NROW(df)
#' df_inc <- clean_df(df) %>% coord_incomplete()
#' NROW(df_inc)
#' attr(df_inc, "coord_incomplete")
#'
#' # Remove unlikely points
#' NROW(df)
#' df_unlikely <- clean_df(df) %>% coord_unlikely()
#' NROW(df_unlikely)
#' attr(df_unlikely, "coord_unlikely")

#' @export
#' @rdname coords
coord_incomplete <- function(x, drop = TRUE) {
  incomp <- x[!complete.cases(x$latitude, x$longitude), ]
  if (NROW(incomp) == 0) incomp <- NA
  if (drop) x <- x[complete.cases(x$latitude, x$longitude), ]
  structure(x, coord_incomplete = incomp)
}

#' @export
#' @rdname coords
coord_impossible <- function(x, drop = TRUE) {
  np <- na.omit(x[!abs(x$latitude) <= 90 | !abs(x$longitude) <= 180, ])
  if (NROW(np) == 0) np <- NA
  if (drop) x <- x[abs(x$latitude) <= 90 | abs(x$longitude) <= 180, ]
  structure(x, coord_impossible = np)
}

#' @export
#' @rdname coords
coord_unlikely <- function(x, drop = TRUE) {
  # FIXME: using 0,0 for now, what else is there?
  unl <- na.omit(x[x$latitude == 0 & x$longitude == 0, ])
  if (NROW(unl) == 0) unl <- NA
  if (drop) x <- x[!x$latitude == 0 & !x$longitude == 0, ]
  structure(x, coord_unlikely = unl)
}


