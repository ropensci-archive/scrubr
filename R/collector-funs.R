#' Collector based cleaning
#'
#' @name collectors
#' @keywords internal
#' @param x (data.frame) A data.frame
#' @param collector (character) Collector field to use. See Details.
#' @param drop (logical) Drop bad data points or not. Either way, we parse
#' out bade data points as an attribute you can access. Default: \code{TRUE}
#'
#' @return Returns a data.frame, with attributes
#'
#' @details
#' Explanation of the functions:
#'
#' \itemize{
#'  \item coll_clean - Standardize collector names
#' }
#'
#' @examples
#' df <- data.frame(
#'   coll = c('K.F.P. Martius', 'C. F. P. Martius', 'C. F. P. von Martius'),
#'   species = 'Poa annua',
#'   lat = 1:3,
#'   lon = 4:6,
#'   stringsAsFactors = FALSE
#' )
#'
#' # Standardize names
#' NROW(df)
#' df <- dframe(df) %>% coll_clean()
#' NROW(df)
#' attr(df, "coll_clean")

#' @rdname collectors
coll_clean <- function(x, collector = NULL) {
  x <- do_collectors(x, collector)
  x <- stand_collectors(x)
  if (NROW(x) == 0) x <- NA
  row.names(x) <- NULL
  structure(reassign(x), coll_clean = incomp)
}
