#' Date based cleaning
#'
#' @name date
#' @param x (data.frame) A data.frame
#' @param format (character) Date format. See \code{\link{as.Date}}
#' @param date_column (character) Name of the date column
#' @param drop (logical) Drop bad data points or not. Either way, we parse
#' out bade data points as an attribute you can access. Default: \code{TRUE}
#' @return Returns a data.frame, with attributes
#' @details
#' \itemize{
#'  \item date_standardize - Converts dates to a specific format
#'  \item date_missing - Drops records that do not have dates, either via being
#'  NA or being a zero length character string
#'  \item date_create - Create a date field from
#' }
#' @examples
#' df <- sample_data_1
#' # Standardize dates
#' clean_df(df) %>% date_standardize()
#' clean_df(df) %>% date_standardize("%Y/%m/%d")
#' clean_df(df) %>% date_standardize("%d%b%Y")
#' clean_df(df) %>% date_standardize("%Y")
#' clean_df(df) %>% date_standardize("%y")
#'
#' # drop records without dates
#' NROW(df)
#' NROW(clean_df(df) %>% date_missing())
#'
#' # Create date field from other fields
#' df <- sample_data_2
#' ## NSE
#' clean_df(df) %>% date_create(year, month, day)
#' ## SE
#' date_create_(clean_df(df), "year", "month", "day")

#' @export
#' @rdname date
date_standardize <- function(x, format = "%Y-%m-%d", date_column = "date", ...) {
  x$date <- format(x[[date_column]], format = format, ...)
  x
}

#' @export
#' @rdname date
date_missing <- function(x, date_column = "date", drop = TRUE, ...) {
  miss <- x[is.na(x[[date_column]]), ]
  zero <- x[nchar(x[[date_column]]) == 0, ]
  all <- rbind(miss, zero)
  if (NROW(all) == 0) all <- NA
  if (drop) {
    x <- x[!is.na(x[[date_column]]), ]
    x <- x[nchar(x[[date_column]]) != 0, ]
  }
  structure(x, date_missing = all)
}


#' @export
#' @rdname date
date_create <- function(x, ...) {
  date_create_(x, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname date
date_create_ <- function(x, ..., .dots, format = "%Y-%m-%d", date_column = "date") {
  tmp <- lazyeval::all_dots(.dots, ...)
  cols <- vapply(tmp, function(x) deparse(x$expr), "", USE.NAMES = FALSE)
  x_cols <- x[, cols]
  x$date <- format(apply(x_cols, 1, paste0, collapse = "-"), format = format)
  names(x)[names(x) %in% "date"] <- date_column
  x
}
