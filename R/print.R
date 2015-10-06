#' @export
print.clean_df <- function(x, ..., n = 10) {
  cat("<clean dataset>", sep = "\n")
  cat(sprintf("Size: %s X %s", NROW(x), NCOL(x)), sep = "\n")
  cat(sprintf("Lat/Lon vars: %s/%s", attr(x, "lat_var"), attr(x, "lon_var")), sep = "\n")
  cat(sprintf("Name var: %s\n", attr(x, "name_var")), sep = "\n")
  trunc_mat_(x, n = n)
}
