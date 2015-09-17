#' Deduplicate records
#'
#' @export
#' @importFrom qlcMatrix sim.strings
#' @param x (data.frame) A data.frame
#' @param drop (logical) Drop bad data points or not. Either way, we parse
#' out bade data points as an attribute you can access. Default: \code{TRUE}
#' @param tolerance (numeric) Score (0 to 1) at which to determine a match. You'll
#' want to inspect outputs closely to tweak this value based on your data, as
#' results can vary.
#' @return Returns a data.frame, with attributes
#' @examples
#' df <- sample_data_1
#' smalldf <- df[1:20, ]
#' smalldf <- rbind(smalldf, smalldf[10,])
#' smalldf[21, "key"] <- 1088954555
#' NROW(smalldf)
#' dp <- clean_df(smalldf) %>% dedup()
#' NROW(dp)
#' attr(dp, "dups")
#'
#' # Another example
#' "xxx"
dedup <- function(x, drop = TRUE, tolerance = 0.9) {
  strs <- apply(x, 1, function(x) gsub("\\s", "", paste0(x, collapse = ",")))
  mat <- sim.strings(strs)
  mat <- matrix2df(mat)
  # mat <- drop_dups(mat)
  res <- mat[mat$values > tolerance, ]
  out <- list()
  for (i in seq_len(NROW(res))) {
    out[[i]] <- x[strs %in% c(res$one, res$two), ]
  }
  df <- do.call("rbind.data.frame", out)
  row.names(df) <- NULL

  if (drop) {
    for (i in seq_len(NROW(res))) {
      x <- x[!strs %in% c(res$one, res$two), ]
    }
  }
  structure(x, dups = df)
}

matrix2df <- function(x) {
  x <- as.matrix(x)
  x[!lower.tri(x)] <- NA
  df <- data.frame(one = rownames(x)[row(x)],
             two = colnames(x)[col(x)],
             values = c(x), stringsAsFactors = FALSE)
  na.omit(df)
}

# drop_dups <- function(x) {
#   # drop 1 to 1
#   x <- x[!apply(x, 1, function(y) {
#     y['one'] == y['two']
#   }), ]
#   # drop flipped names
#   out <- list()
#   uniqnms <- unique(c(x$one, x$two))
#   for (i in seq_along(uniqnms)) {
#     one <- x[x$one == uniqnms[i], ]
#     two <- x[x$two == uniqnms[i], ]
#     two <- data.frame(one = two$two, two = two$one,
#                       values = two$values, stringsAsFactors = FALSE)
#     one_two <- rbind(one, two)
#     out[[i]] <- one_two[!duplicated(one_two), ]
#   }
#   df <- do.call("rbind.data.frame", out)
#   row.names(df) <- NULL
#   df
# }

# df <- sample_data_1
# smalldf <- df[1:20, ]
# smalldf <- rbind(smalldf, smalldf[10,])
# smalldf <- rbind(smalldf, smalldf[10,])
# strs <- apply(smalldf, 1, function(x) gsub("\\s", "", paste0(x, collapse = ",")))
# ff <- sim.strings(strs)
# ff
#
#
# smalldf <- rbind(smalldf, smalldf[10,])
# smalldf[21, "key"] <- 1088954555
# strs <- apply(smalldf, 1, function(x) gsub("\\s", "", paste0(x, collapse = ",")))
# ff <- sim.strings(strs)
# ff