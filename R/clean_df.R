#' Clean data.frame
#'
#' @export
#' @param x Input data.frame
#' @param lat,lon (character) Latitude and longitude column to use. See Details.
#'
#' @details If either lat or lon (or both) given, we assign the given column name
#' to be standardized names of "latitude", and "longitude". If not given, we attempt
#' to guess what the lat and lon column names are and assign the same standardized
#' names. Assign the same standardized names makes downstream processing easier
#' so that we're dealing with consistent column names. FIXME: we could put back
#' original names I suppose, on returning from any functions.
#'
#' @examples
#' df <- sample_data_1
#'
#' # Make a `clean_df` object
#' clean_df(df)
clean_df <- function(x, lat = NULL, lon = NULL) {
  if (!is.data.frame(x)) stop("x must be a data.frame", call. = FALSE)
  x <- guess_latlon(x, lat, lon)
  as_data_frame(x)
}

as_data_frame <- function(x) {
  stopifnot(is.list(x))
  if (length(x) == 0) {
    x <- list()
    class(x) <- c("tbl_df", "tbl", "data.frame")
    attr(x, "row.names") <- .set_row_names(0)
    return(x)
  }
  names_x <- names2(x)
  if (any(is.na(names_x) | names_x == "")) {
    stop("All columns must be named", call. = FALSE)
  }
  ok <- vapply(x, is_1d, logical(1))
  if (any(!ok)) {
    stop("data_frames can only contain 1d atomic vectors and lists",
         call. = FALSE)
  }
  n <- unique(vapply(x, NROW, integer(1)))
  if (length(n) != 1) {
    stop("Columns are not all same length", call. = FALSE)
  }
  class(x) <- c("clean_df", "tbl_df", "tbl", "data.frame")
  attr(x, "row.names") <- .set_row_names(n)
  x
}

names2 <- function(x) {
  names(x) %||% rep("", length(x))
}

is_1d <- function(x) {
  ((is.atomic(x) && !is.null(x)) || is.list(x)) && length(dim(x)) <= 1
}

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}
