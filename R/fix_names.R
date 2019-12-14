#' Change taxonomic names to be the same for each taxon
#'
#' That is, this function attempts to take all the names that are synonyms,
#' for whatever reason (e.g., some names have authorities on them), and
#' collapses them to the same string - making data easier to deal with for
#' making maps, etc. OR - you can think of this as a tool for
#'
#' @export
#' @param x (data.frame) A data.frame. the target taxonomic name 
#' column should be 'name'
#' @param how One of a few different methods:
#'
#' - shortest - Takes the shortest name string that is likely to be the
#'  prettiest to display name, and replaces alll names with that one, better
#'  for maps, etc.
#' - supplied - If this method, supply a vector of names to replace the
#'  names with. 
#'
#' @param replace A data.frame of names to replace names in the occurrence
#' data.frames with. Only used if how="supplied". The data.frame should have
#' two columns: the first is the names to match in the input `x` data.frame, 
#' and the second column is the name to replace with. The column names don't
#' matter.
#' @return a data.frame
#'
#' @examples \dontrun{
#' df <- sample_data_7
#' 
#' # method: shortest
#' fix_names(df, how="shortest")$name
#' 
#' # method: supplied
#' (replace_df <- data.frame(
#'  one = unique(df$name), 
#'  two = c('P. contorta', 'P.c. var. contorta',
#'          'P.c. subsp bolanderi', 'P.c. var. murrayana'),
#'  stringsAsFactors = FALSE))
#' fix_names(df, how="supplied", replace = replace_df)$name
#' }
fix_names <- function(x, how = "shortest", replace = NULL) {
  assert(x, "data.frame")
  assert(how, "character")
  assert(replace, "data.frame")
  if (!how %in% fix_names_how)
    stop("'how' must be one of", paste0(fix_names_how, collapse = ", "))
  if (is.factor(x$name)) x$name <- as.character(x$name)
  if (how == "shortest") { # shortest
    uniqnames <- unique(x$name)
    lengths <- vapply(uniqnames, function(y) length(strsplit(y, " ")[[1]]),
                      numeric(1))
    shortest <- names(which.min(lengths))
    if (length(uniqnames) > 1) {
      x$name <- rep(shortest, NROW(x))
    } else {
      warning("shortest method: unique names not > 1; doing nothing")
    }
  } else { # supplied
    if (is.null(replace))
      stop("If how='supplied' you must provide a vector of names")
    uniqnames <- unique(x$name)
    if (!NROW(replace) == length(uniqnames))
      stop("The supplied name vector must be the same length as the length of names you originally queried in occ function")
    for (i in seq_len(NROW(replace))) {
      x$name[x$name == replace[i, 1]] <- replace[i, 2]
    }
  }
  return(x)
}

fix_names_how <- c("shortest", "supplied")
