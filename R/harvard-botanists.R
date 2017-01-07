#' Harvard botanist index functions
#'
#' @keywords internal
#' @examples \dontrun{
#' bot_search(name = "Asa Gray")
#' bot_search(name = "A. Gray")
#' bot_search(remarks = "harvard")
#' bot_search(name = "Gray", fuzzy = TRUE)
#' bot_search()
#' bot_search()
#'
#' ## FIXME - this leads to a JSON parsing error because they give
#' ##   bad JSON in some results, including this example
#' # bot_search(country = "China")
#' }
bot_search <- function(name = NULL, individual = FALSE, start = NULL,
  fuzzy = FALSE, remarks = NULL, speciality = NULL, country = NULL,
  is_collector = FALSE, is_author = FALSE, team = FALSE,
  error = stop, ...) {

  cli <- crul::HttpClient$new(url = hbi_base())
  args <- ct(list(
    name = name, json = "y", individual = logt(individual), start = start,
    soundslike = if (fuzzy) "true" else NULL, remarks = remarks,
    speciality = speciality, country = country, is_collector = logt(is_collector),
    is_author = logt(is_author), team = logt(team)
  ))
  res <- cli$get(query = args, ...)
  res$raise_for_status()
  if ((err <- grepl("no matching result", res$parse("UTF-8"), ignore.case = TRUE))) {
    error("(404) no matching results found", call. = FALSE)
  }
  if (err && as.character(substitute(error)) != "stop") return(NULL)
  tibble::as_data_frame(
    jsonlite::fromJSON(res$parse("UTF-8"))$botanists
  )
}

hbi_base <- function() 'http://kiki.huh.harvard.edu/databases/botanist_search.php'

logt <- function(x) if (x) "on" else NULL

clean_dirty_json <- function(x) {
  tmp <- gregexpr("\"\"[A-Za-z0-9]+\"\"", x)[[1]]
  if (tmp == -1) {
    x
  } else {
    substring(x, tmp, (tmp + attr(tmp, "match.length")) - 1)
  }
}

# http://kiki.huh.harvard.edu/databases/botanist_search.php?name=Asa+Gray&individual=on&json=y
# http://kiki.huh.harvard.edu/databases/botanist_search.php?start=1&name=Gray&id=&soundslike=true&remarks=&specialty=&country=&is_collector=on

stand_collectors <- function(x) {
  nms <- unique(x$collector)
  res <- ct(lapply(nms, bot_search))
}
