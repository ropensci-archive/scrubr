#' Deduplicate records
#'
#' @export
#' @param x (data.frame) A data.frame, tibble, or data.table
#' @param how (character) How to deal with duplicates. The default of
#' "one" keeps one record of each group of duplicates, and drops the
#' others, putting them into the `dups` attribute. "all" drops all
#' duplicates, in case e.g., you don't want to deal with any records that are
#' duplicated, as e.g., it may be hard to tell which one to remove.
#' @param tolerance (numeric) Score (0 to 1) at which to determine a match.
#' You'll want to inspect outputs closely to tweak this value based on your
#' data, as results can vary.
#' @return Returns a data.frame, optionally with attributes
#' @examples
#' df <- sample_data_1
#' smalldf <- df[1:20, ]
#' smalldf <- rbind(smalldf, smalldf[10,])
#' smalldf[21, "key"] <- 1088954555
#' NROW(smalldf)
#' dp <- dframe(smalldf) %>% dedup()
#' NROW(dp)
#' attr(dp, "dups")
#'
#' # Another example - more than one set of duplicates
#' df <- sample_data_1
#' twodups <- df[1:10, ]
#' twodups <- rbind(twodups, twodups[c(9, 10), ])
#' rownames(twodups) <- NULL
#' NROW(twodups)
#' dp <- dframe(twodups) %>% dedup()
#' NROW(dp)
#' attr(dp, "dups")

dedup <- function(x, how = "one", tolerance = 0.9) {
  values <- NULL
  strs <- apply(x, 1, function(z) gsub("\\s", "", paste0(z, collapse = ",")))
  mat <- qlcMatrix::sim.strings(strs)
  mat <- matrix2df(mat)
  mat <- data.table(mat)
  mat <- mat[!duplicated(mat)]
  res <- mat[values > tolerance]

  out <- vector(mode = "list", length(strs))
  for (i in seq_len(NROW(res))) {
    out[[i]] <- x[strs %fin% c(res[i,]$one, res[i,]$two), ]
  }

  how <- match.arg(how, c("one", "all"))
  switch(
    how,
    one = {
      x <- x[!strs %fin% unique(c(res$one, res$two)), ]
      for (i in seq_along(out)) {
        x <- rbindlist(list(x, out[[i]][1,]))
      }
      outdups <- vector(mode = "list", length(out))
      for (i in seq_along(out)) {
        outdups[[i]] <- out[[i]][-1, ]
      }
      df <- rbindlist(outdups)
    },
    all = {
      x <- x[!strs %fin% unique(c(res$one, res$two)), ]
      df <- rbindlist(out)
    }
  )

  if (any(duplicated(x))) x <- x[!duplicated(x)]
  if (any(duplicated(df))) df <- df[!duplicated(df)]
  row.names(df) <- NULL
  row.names(x) <- NULL
  structure(tibble::as_tibble(x), dups = tibble::as_tibble(df))
}

matrix2df <- function(x) {
  x <- Matrix::as.matrix(x)
  x[!lower.tri(x)] <- NA_real_  
  df <- data.table(
    one = rownames(x)[row(x)],
    two = colnames(x)[col(x)],
    values = c(x), stringsAsFactors = FALSE
  )
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
# strs <- apply(smalldf, 1, function(x) gsub("\\s", "",
#  paste0(x, collapse = ",")))
# ff <- sim.strings(strs)
# ff
#
#
# smalldf <- rbind(smalldf, smalldf[10,])
# smalldf[21, "key"] <- 1088954555
# strs <- apply(smalldf, 1, function(x) gsub("\\s", "", paste0(x,
#  collapse = ",")))
# ff <- sim.strings(strs)
# ff
