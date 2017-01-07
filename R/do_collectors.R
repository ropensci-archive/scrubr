# assign consitent collector variable to be able to act on data inputs
# more easily - and save original column names to rename data on return

do_collectors <- function(x, collector) {
  x <- guess_collector(x, collector)
  if (is.null(attr(x, "coll_var_orig"))) attr(x, "coll_var_orig") <- collector
  return(x)
}
