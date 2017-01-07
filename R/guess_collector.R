guess_collector <- function(x, collector = NULL) {
  nms <- names(x)

  if (!is.null(attr(x, "coll_var_orig"))) collector <- attr(x, "coll_var_orig")

  if (is.null(collector)) {
    colls <- nms[grep(sprintf("^(%s)$", paste0(coll_options, collapse = "|")),
                      nms, ignore.case = TRUE)]

    if (length(colls) == 1) {
      if (length(nms) > 2) {
        message("Assuming '", colls, "' is collector")
      }
      names(x)[names(x) %in% colls] <- coll_var <-  "collector"
    } else {
      stop("Couldn't infer collector column, please specify w/ 'collector' parameter",
           call. = FALSE)
    }
  } else {
    if (!any(names(x) %in% collector)) {
      stop("'", collector, "' not found in your data", call. = FALSE)
    }
    names(x)[names(x) %in% collector] <- coll_var <- "collector"
  }

  structure(x, coll_var = coll_var)
}

coll_options <- c("recordedBy", "collector", "coll")
