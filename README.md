scrubr
======



[![Build Status](https://travis-ci.org/ropensci/scrubr.svg?branch=master)](https://travis-ci.org/ropensci/scrubr)
[![cran checks](https://cranchecks.info/badges/worst/scrubr)](https://cranchecks.info/pkgs/scrubr)
[![codecov.io](https://codecov.io/github/ropensci/scrubr/coverage.svg?branch=master)](https://codecov.io/github/ropensci/scrubr?branch=master)
[![rstudio mirror downloads](https://cranlogs.r-pkg.org/badges/grand-total/scrubr?color=ff69b4)](https://github.com/metacran/cranlogs.app)
[![cran version](https://www.r-pkg.org/badges/version/scrubr)](https://cran.r-project.org/package=scrubr)

__Clean Biological Occurrence Records__

Clean using the following use cases (checkmarks indicate fxns exist - not necessarily complete):

- [x] Impossible lat/long values: e.g., latitude 75
- [x] Incomplete cases: one or the other of lat/long missing
- [x] Unlikely lat/long values: e.g., points at 0,0
- [x] Deduplication: try to identify duplicates, esp. when pulling data from multiple sources, e.g., can try to use occurrence IDs, if provided
- [x] Date based cleaning
* [x] Outside political boundary: User input to check for points in the wrong country, or points outside of a known country
* [x] Taxonomic name based cleaning: via `taxize` (one method so far)
* Political centroids: unlikely that occurrences fall exactly on these points, more likely a
default position (Draft function started, but not exported, and commented out). see [issue #6](https://github.com/ropensci/scrubr/issues/6)
* Herbaria/Museums: many specimens may have location of the collection they are housed in, see [issue #20](https://github.com/ropensci/scrubr/issues/20)
* Habitat type filtering: e.g., fish should not be on land; marine fish should not be in fresh water
* Check for contextually wrong values: That is, if 99 out of 100 lat/long coordinates are within the continental US, but 1 is in China, then perhaps something is wrong with that one point
* Collector/recorder names: see [issue #19](https://github.com/ropensci/scrubr/issues/19)
* ...

A note about examples: We think that using a piping workflow with `%>%` makes code easier to
build up, and easier to understand. However, in some examples we provide examples without the pipe
to demonstrate traditional usage.

## Install

Stable CRAN version


```r
install.packages("scrubr")
```

Development version


```r
devtools::install_github("ropensci/scrubr")
```


```r
library("scrubr")
```

## Coordinate based cleaning


```r
data("sampledata1")
```

Remove impossible coordinates (using sample data included in the pkg)


```r
# coord_impossible(dframe(sample_data_1)) # w/o pipe
dframe(sample_data_1) %>% coord_impossible()
#> # A tibble: 1,500 x 5
#>    name             longitude latitude date                       key
#>  * <chr>                <dbl>    <dbl> <dttm>                   <int>
#>  1 Ursus americanus     -79.7     38.4 2015-01-14 16:36:45 1065590124
#>  2 Ursus americanus     -82.4     35.7 2015-01-13 00:25:39 1065588899
#>  3 Ursus americanus     -99.1     23.7 2015-02-20 23:00:00 1098894889
#>  4 Ursus americanus     -72.8     43.9 2015-02-13 16:16:41 1065611122
#>  5 Ursus americanus     -72.3     43.9 2015-03-01 20:20:45 1088908315
#>  6 Ursus americanus    -109.      32.7 2015-03-29 17:06:54 1088932238
#>  7 Ursus americanus    -109.      32.7 2015-03-29 17:12:50 1088932273
#>  8 Ursus americanus    -124.      40.1 2015-03-28 23:00:00 1132403409
#>  9 Ursus americanus     -78.3     36.9 2015-03-20 21:11:24 1088923534
#> 10 Ursus americanus     -76.8     35.5 2015-04-05 23:00:00 1088954559
#> # … with 1,490 more rows
```

Remove incomplete coordinates


```r
# coord_incomplete(dframe(sample_data_1)) # w/o pipe
dframe(sample_data_1) %>% coord_incomplete()
#> # A tibble: 1,306 x 5
#>    name             longitude latitude date                       key
#>  * <chr>                <dbl>    <dbl> <dttm>                   <int>
#>  1 Ursus americanus     -79.7     38.4 2015-01-14 16:36:45 1065590124
#>  2 Ursus americanus     -82.4     35.7 2015-01-13 00:25:39 1065588899
#>  3 Ursus americanus     -99.1     23.7 2015-02-20 23:00:00 1098894889
#>  4 Ursus americanus     -72.8     43.9 2015-02-13 16:16:41 1065611122
#>  5 Ursus americanus     -72.3     43.9 2015-03-01 20:20:45 1088908315
#>  6 Ursus americanus    -109.      32.7 2015-03-29 17:06:54 1088932238
#>  7 Ursus americanus    -109.      32.7 2015-03-29 17:12:50 1088932273
#>  8 Ursus americanus    -124.      40.1 2015-03-28 23:00:00 1132403409
#>  9 Ursus americanus     -78.3     36.9 2015-03-20 21:11:24 1088923534
#> 10 Ursus americanus     -76.8     35.5 2015-04-05 23:00:00 1088954559
#> # … with 1,296 more rows
```

Remove unlikely coordinates (e.g., those at 0,0)


```r
# coord_unlikely(dframe(sample_data_1)) # w/o pipe
dframe(sample_data_1) %>% coord_unlikely()
#> # A tibble: 1,488 x 5
#>    name             longitude latitude date                       key
#>  * <chr>                <dbl>    <dbl> <dttm>                   <int>
#>  1 Ursus americanus     -79.7     38.4 2015-01-14 16:36:45 1065590124
#>  2 Ursus americanus     -82.4     35.7 2015-01-13 00:25:39 1065588899
#>  3 Ursus americanus     -99.1     23.7 2015-02-20 23:00:00 1098894889
#>  4 Ursus americanus     -72.8     43.9 2015-02-13 16:16:41 1065611122
#>  5 Ursus americanus     -72.3     43.9 2015-03-01 20:20:45 1088908315
#>  6 Ursus americanus    -109.      32.7 2015-03-29 17:06:54 1088932238
#>  7 Ursus americanus    -109.      32.7 2015-03-29 17:12:50 1088932273
#>  8 Ursus americanus    -124.      40.1 2015-03-28 23:00:00 1132403409
#>  9 Ursus americanus     -78.3     36.9 2015-03-20 21:11:24 1088923534
#> 10 Ursus americanus     -76.8     35.5 2015-04-05 23:00:00 1088954559
#> # … with 1,478 more rows
```

Do all three


```r
dframe(sample_data_1) %>%
  coord_impossible() %>%
  coord_incomplete() %>%
  coord_unlikely()
#> # A tibble: 1,294 x 5
#>    name             longitude latitude date                       key
#>  * <chr>                <dbl>    <dbl> <dttm>                   <int>
#>  1 Ursus americanus     -79.7     38.4 2015-01-14 16:36:45 1065590124
#>  2 Ursus americanus     -82.4     35.7 2015-01-13 00:25:39 1065588899
#>  3 Ursus americanus     -99.1     23.7 2015-02-20 23:00:00 1098894889
#>  4 Ursus americanus     -72.8     43.9 2015-02-13 16:16:41 1065611122
#>  5 Ursus americanus     -72.3     43.9 2015-03-01 20:20:45 1088908315
#>  6 Ursus americanus    -109.      32.7 2015-03-29 17:06:54 1088932238
#>  7 Ursus americanus    -109.      32.7 2015-03-29 17:12:50 1088932273
#>  8 Ursus americanus    -124.      40.1 2015-03-28 23:00:00 1132403409
#>  9 Ursus americanus     -78.3     36.9 2015-03-20 21:11:24 1088923534
#> 10 Ursus americanus     -76.8     35.5 2015-04-05 23:00:00 1088954559
#> # … with 1,284 more rows
```

Don't drop bad data


```r
dframe(sample_data_1) %>% coord_incomplete(drop = TRUE) %>% NROW
#> [1] 1306
dframe(sample_data_1) %>% coord_incomplete(drop = FALSE) %>% NROW
#> [1] 1500
```


## Deduplicate


```r
smalldf <- sample_data_1[1:20, ]
# create a duplicate record
smalldf <- rbind(smalldf, smalldf[10,])
row.names(smalldf) <- NULL
# make it slightly different
smalldf[21, "key"] <- 1088954555
NROW(smalldf)
#> [1] 21
dp <- dframe(smalldf) %>% dedup()
NROW(dp)
#> [1] 20
attr(dp, "dups")
#> # A tibble: 1 x 5
#>   name             longitude latitude date                       key
#>   <chr>                <dbl>    <dbl> <dttm>                   <dbl>
#> 1 Ursus americanus     -76.8     35.5 2015-04-05 23:00:00 1088954555
```

## Dates

Standardize/convert dates


```r
df <- sample_data_1
# date_standardize(dframe(df), "%d%b%Y") # w/o pipe
dframe(df) %>% date_standardize("%d%b%Y")
#> # A tibble: 1,500 x 5
#>    name             longitude latitude date             key
#>    <chr>                <dbl>    <dbl> <chr>          <int>
#>  1 Ursus americanus     -79.7     38.4 14Jan2015 1065590124
#>  2 Ursus americanus     -82.4     35.7 13Jan2015 1065588899
#>  3 Ursus americanus     -99.1     23.7 20Feb2015 1098894889
#>  4 Ursus americanus     -72.8     43.9 13Feb2015 1065611122
#>  5 Ursus americanus     -72.3     43.9 01Mar2015 1088908315
#>  6 Ursus americanus    -109.      32.7 29Mar2015 1088932238
#>  7 Ursus americanus    -109.      32.7 29Mar2015 1088932273
#>  8 Ursus americanus    -124.      40.1 28Mar2015 1132403409
#>  9 Ursus americanus     -78.3     36.9 20Mar2015 1088923534
#> 10 Ursus americanus     -76.8     35.5 05Apr2015 1088954559
#> # … with 1,490 more rows
```

Drop records without dates


```r
NROW(df)
#> [1] 1500
NROW(dframe(df) %>% date_missing())
#> [1] 1498
```

Create date field from other fields


```r
dframe(sample_data_2) %>% date_create(year, month, day)
#> # A tibble: 1,500 x 8
#>    name             longitude latitude        key year  month day   date      
#>    <chr>                <dbl>    <dbl>      <int> <chr> <chr> <chr> <chr>     
#>  1 Ursus americanus     -79.7     38.4 1065590124 2015  01    14    2015-01-14
#>  2 Ursus americanus     -82.4     35.7 1065588899 2015  01    13    2015-01-13
#>  3 Ursus americanus     -99.1     23.7 1098894889 2015  02    20    2015-02-20
#>  4 Ursus americanus     -72.8     43.9 1065611122 2015  02    13    2015-02-13
#>  5 Ursus americanus     -72.3     43.9 1088908315 2015  03    01    2015-03-01
#>  6 Ursus americanus    -109.      32.7 1088932238 2015  03    29    2015-03-29
#>  7 Ursus americanus    -109.      32.7 1088932273 2015  03    29    2015-03-29
#>  8 Ursus americanus    -124.      40.1 1132403409 2015  03    28    2015-03-28
#>  9 Ursus americanus     -78.3     36.9 1088923534 2015  03    20    2015-03-20
#> 10 Ursus americanus     -76.8     35.5 1088954559 2015  04    05    2015-04-05
#> # … with 1,490 more rows
```

## Ecoregion

Filter by FAO areas


```r
wkt <- 'POLYGON((72.2 38.5,-173.6 38.5,-173.6 -41.5,72.2 -41.5,72.2 38.5))'
manta_ray <- rgbif::name_backbone("Mobula alfredi")$usageKey
res <- rgbif::occ_data(manta_ray, geometry = wkt, limit=300, hasCoordinate = TRUE)
dat <- sf::st_as_sf(res$data, coords = c("decimalLongitude", "decimalLatitude"))
dat <- sf::st_set_crs(dat, 4326)
mapview::mapview(dat)
tmp <- ecoregion(dframe(res$data), dataset = "fao", ecoregion = "OCEAN:Indian")
tmp <- tmp[!is.na(tmp$decimalLongitude), ]
tmp2 <- sf::st_as_sf(tmp, coords = c("decimalLongitude", "decimalLatitude"))
tmp2 <- sf::st_set_crs(tmp2, 4326)
mapview::mapview(tmp2)
```

## Meta

* Please [report any issues or bugs](https://github.com/ropensci/scrubr/issues).
* License: MIT
* Get citation information for `scrubr` in R doing `citation(package = 'scrubr')`
* Please note that this project is released with a [Contributor Code of Conduct][coc]. By participating in this project you agree to abide by its terms.

[![ropensci_footer](https://ropensci.org/public_images/github_footer.png)](https://ropensci.org)

[coc]: https://github.com/ropensci/scrubr/blob/master/CODE_OF_CONDUCT.md
