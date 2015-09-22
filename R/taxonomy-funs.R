#' Taxonomy based cleaning
#'
#' @name taxonomy
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

#' @export
#' @rdname taxonomy
tax_ <- function(x, drop = TRUE) {
  incomp <- x[!complete.cases(x$latitude, x$longitude), ]
  if (NROW(incomp) == 0) incomp <- NA
  if (drop) x <- x[complete.cases(x$latitude, x$longitude), ]
  structure(x, coord_incomplete = incomp)
}
