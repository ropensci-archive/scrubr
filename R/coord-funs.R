#' Coordinate based cleaning
#'
#' @name coords
#' @param x A data.frame
#' @return Returns a data.frame, with attributes
#' @examples \dontrun{
#' df <- sample_data_1
#'
#' # Make a `clean_df` object
#' clean_df(df)
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
#' }

#' @export
#' @rdname coords
coord_incomplete <- function(x) {
  incomp <- x[!complete.cases(x$latitude, x$longitude), ]
  if (NROW(incomp) == 0) incomp <- NA
  x <- x[complete.cases(x$latitude, x$longitude), ]
  structure(x, coord_incomplete = incomp)
}

#' @export
#' @rdname coords
coord_impossible <- function(x) {
  np <- na.omit(x[!abs(x$latitude) <= 90 | !abs(x$longitude) <= 180, ])
  if (NROW(np) == 0) np <- NA
  structure(x, coord_impossible = np)
}
