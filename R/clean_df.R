#' Compact data.frame
#'
#' @export
#' @param x Input data.frame
#' @examples
#' dframe(sample_data_1)
#' dframe(mtcars)
#' dframe(iris)
dframe <- function(x) {
  UseMethod("dframe")
}

#' @export
dframe.default <- function(x) {
  stop("no 'dframe' method for ", class(x), call. = FALSE)
}

#' @export
dframe.data.frame <- function(x) {
  tibble::as_data_frame(x)
  # as_data_frame(x)
}

#' @export
dframe.dframe <- function(x) x
