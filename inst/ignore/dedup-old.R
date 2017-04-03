dedup_old <- function(x, how = "one", tolerance = 0.9) {
  strs <- apply(x, 1, function(x) gsub("\\s", "", paste0(x, collapse = ",")))
  mat <- sim.strings(strs)
  mat <- matrix2df_old(mat)
  mat <- mat[!duplicated(mat), ]
  res <- mat[mat$values > tolerance, ]
  out <- list()
  for (i in seq_len(NROW(res))) {
    out[[i]] <- x[strs %in% c(res[i,]$one, res[i,]$two), ]
  }

  how <- match.arg(how, c("one", "all"))
  switch(how,
         one = {
           x <- x[!strs %in% unique(c(res$one, res$two)), ]
           for (i in seq_along(out)) {
             x <- rbind(x, out[[i]][1,])
           }
           outdups <- list()
           for (i in seq_along(out)) {
             outdups[[i]] <- out[[i]][-1, ]
           }
           df <- do.call("rbind.data.frame", outdups)
         },
         all = {
           x <- x[!strs %in% unique(c(res$one, res$two)), ]
           df <- do.call("rbind.data.frame", out)
         }
  )

  row.names(df) <- NULL
  row.names(x) <- NULL
  structure(x, dups = df)
}

matrix2df_old <- function(x) {
  x <- Matrix::as.matrix(x)
  x[!lower.tri(x)] <- NA
  df <- data.frame(one = rownames(x)[row(x)],
                   two = colnames(x)[col(x)],
                   values = c(x), stringsAsFactors = FALSE)
  na.omit(df)
}