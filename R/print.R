#' @export
print.clean_df <- function(x, ..., n = 10){
  cat("<clean dataset>", sep = "\n")
  cat(sprintf("Size: %s X %s\n", NROW(x), NCOL(x)), sep = "\n")
  trunc_mat_(x, n = n)
}
