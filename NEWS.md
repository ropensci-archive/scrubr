scrubr 0.3.0
============

### NEW FEATURES

* gains function `fix_names()`, ported over from the `spocc` package; a helper function to change taxonomic names in a data.frame to make plotting simpler (#29)
* gains new function `eco_region()` to filter data by ecoregions; also exported are `regions_fao()` and `regions_meow()` that fetch the data used in `eco_region()` so the user can better figure out what variables to use (#30)
* gains new function `coord_imprecise()` to clean imprecise coordinates (#18)
* gains new function `coord_uncertain()` to clean uncertain occurrences, as determined through the `coordinateUncertaintyInMeters` variable reported in Darwin Core records
* now importing `data.table`, `fastmatch`, `crul`, `jsonlite`, `tibble`, `curl` and `hoardr` (`sf` and `mapview` in Suggests)

### MINOR IMPROVEMENTS

* `coord_within()` now uses `sf` instead of `sp` (#31)
* using tibble now for compact, easier to handle, data.frame's (#21)

### BUG FIXES

* fix to `dedup()` to remove duplicate entries (#27)


scrubr 0.1.1
============

### MINOR IMPROVEMENTS

* Fixed examples to be conditional on presence of `rgbif` (#17)
* Fix `as.matrix()` to use `Matrix::as.matrix()`


scrubr 0.1.0
============

### NEW FEATURES

* Releasd to CRAN.
