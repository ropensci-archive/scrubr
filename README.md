scrubr
======



[![Build Status](https://travis-ci.org/ropenscilabs/scrubr.svg?branch=master)](https://travis-ci.org/ropenscilabs/scrubr)
[![codecov.io](http://codecov.io/github/ropenscilabs/scrubr/coverage.svg?branch=master)](http://codecov.io/github/ropenscilabs/scrubr?branch=master)
[![rstudio mirror downloads](http://cranlogs.r-pkg.org/badges/grand-total/scrubr?color=ff69b4)](https://github.com/metacran/cranlogs.app)
[![cran version](http://www.r-pkg.org/badges/version/scrubr)](https://cran.r-project.org/package=scrubr)

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
default position (Draft function started, but not exported, and commented out)
* Herbaria/Museums: many specimens may have location of the collection they are housed in
* Habitat type filtering: e.g., fish should not be on land; marine fish should not be in fresh water
* Check for contextually wrong values: That is, if 99 out of 100 lat/long coordinates are within the continental US, but 1 is in China, then perhaps something is wrong with that one point
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
devtools::install_github("ropenscilabs/scrubr")
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
#> <scrubr dframe>
#> Size: 1500 X 5
#> Lat/Lon vars: latitude/longitude
#>
#>                name  longitude latitude                date        key
#>               (chr)      (dbl)    (dbl)              (time)      (int)
#> 1  Ursus americanus  -79.68283 38.36662 2015-01-14 16:36:45 1065590124
#> 2  Ursus americanus  -82.42028 35.73304 2015-01-13 00:25:39 1065588899
#> 3  Ursus americanus  -99.09625 23.66893 2015-02-20 23:00:00 1098894889
#> 4  Ursus americanus  -72.77432 43.94883 2015-02-13 16:16:41 1065611122
#> 5  Ursus americanus  -72.34617 43.86464 2015-03-01 20:20:45 1088908315
#> 6  Ursus americanus -108.53674 32.65219 2015-03-29 17:06:54 1088932238
#> 7  Ursus americanus -108.53691 32.65237 2015-03-29 17:12:50 1088932273
#> 8  Ursus americanus -123.82900 40.13240 2015-03-28 23:00:00 1132403409
#> 9  Ursus americanus  -78.25027 36.93018 2015-03-20 21:11:24 1088923534
#> 10 Ursus americanus  -76.78671 35.53079 2015-04-05 23:00:00 1088954559
#> ..              ...        ...      ...                 ...        ...
```

Remove incomplete coordinates


```r
# coord_incomplete(dframe(sample_data_1)) # w/o pipe
dframe(sample_data_1) %>% coord_incomplete()
#> <scrubr dframe>
#> Size: 1306 X 5
#> Lat/Lon vars: latitude/longitude
#>
#>                name  longitude latitude                date        key
#>               (chr)      (dbl)    (dbl)              (time)      (int)
#> 1  Ursus americanus  -79.68283 38.36662 2015-01-14 16:36:45 1065590124
#> 2  Ursus americanus  -82.42028 35.73304 2015-01-13 00:25:39 1065588899
#> 3  Ursus americanus  -99.09625 23.66893 2015-02-20 23:00:00 1098894889
#> 4  Ursus americanus  -72.77432 43.94883 2015-02-13 16:16:41 1065611122
#> 5  Ursus americanus  -72.34617 43.86464 2015-03-01 20:20:45 1088908315
#> 6  Ursus americanus -108.53674 32.65219 2015-03-29 17:06:54 1088932238
#> 7  Ursus americanus -108.53691 32.65237 2015-03-29 17:12:50 1088932273
#> 8  Ursus americanus -123.82900 40.13240 2015-03-28 23:00:00 1132403409
#> 9  Ursus americanus  -78.25027 36.93018 2015-03-20 21:11:24 1088923534
#> 10 Ursus americanus  -76.78671 35.53079 2015-04-05 23:00:00 1088954559
#> ..              ...        ...      ...                 ...        ...
```

Remove unlikely coordinates (e.g., those at 0,0)


```r
# coord_unlikely(dframe(sample_data_1)) # w/o pipe
dframe(sample_data_1) %>% coord_unlikely()
#> <scrubr dframe>
#> Size: 1488 X 5
#> Lat/Lon vars: latitude/longitude
#>
#>                name  longitude latitude                date        key
#>               (chr)      (dbl)    (dbl)              (time)      (int)
#> 1  Ursus americanus  -79.68283 38.36662 2015-01-14 16:36:45 1065590124
#> 2  Ursus americanus  -82.42028 35.73304 2015-01-13 00:25:39 1065588899
#> 3  Ursus americanus  -99.09625 23.66893 2015-02-20 23:00:00 1098894889
#> 4  Ursus americanus  -72.77432 43.94883 2015-02-13 16:16:41 1065611122
#> 5  Ursus americanus  -72.34617 43.86464 2015-03-01 20:20:45 1088908315
#> 6  Ursus americanus -108.53674 32.65219 2015-03-29 17:06:54 1088932238
#> 7  Ursus americanus -108.53691 32.65237 2015-03-29 17:12:50 1088932273
#> 8  Ursus americanus -123.82900 40.13240 2015-03-28 23:00:00 1132403409
#> 9  Ursus americanus  -78.25027 36.93018 2015-03-20 21:11:24 1088923534
#> 10 Ursus americanus  -76.78671 35.53079 2015-04-05 23:00:00 1088954559
#> ..              ...        ...      ...                 ...        ...
```

Do all three


```r
dframe(sample_data_1) %>%
  coord_impossible() %>%
  coord_incomplete() %>%
  coord_unlikely()
#> <scrubr dframe>
#> Size: 1294 X 5
#> Lat/Lon vars: latitude/longitude
#>
#>                name  longitude latitude                date        key
#>               (chr)      (dbl)    (dbl)              (time)      (int)
#> 1  Ursus americanus  -79.68283 38.36662 2015-01-14 16:36:45 1065590124
#> 2  Ursus americanus  -82.42028 35.73304 2015-01-13 00:25:39 1065588899
#> 3  Ursus americanus  -99.09625 23.66893 2015-02-20 23:00:00 1098894889
#> 4  Ursus americanus  -72.77432 43.94883 2015-02-13 16:16:41 1065611122
#> 5  Ursus americanus  -72.34617 43.86464 2015-03-01 20:20:45 1088908315
#> 6  Ursus americanus -108.53674 32.65219 2015-03-29 17:06:54 1088932238
#> 7  Ursus americanus -108.53691 32.65237 2015-03-29 17:12:50 1088932273
#> 8  Ursus americanus -123.82900 40.13240 2015-03-28 23:00:00 1132403409
#> 9  Ursus americanus  -78.25027 36.93018 2015-03-20 21:11:24 1088923534
#> 10 Ursus americanus  -76.78671 35.53079 2015-04-05 23:00:00 1088954559
#> ..              ...        ...      ...                 ...        ...
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
#> <scrubr dframe>
#> Size: 1 X 5
#>
#>
#>               name longitude latitude                date        key
#>              (chr)     (dbl)    (dbl)              (time)      (dbl)
#> 1 Ursus americanus -76.78671 35.53079 2015-04-05 23:00:00 1088954555
```

## Dates

Standardize/convert dates


```r
df <- sample_data_1
# date_standardize(dframe(df), "%d%b%Y") # w/o pipe
dframe(df) %>% date_standardize("%d%b%Y")
#> <scrubr dframe>
#> Size: 1500 X 5
#>
#>
#>                name  longitude latitude      date        key
#>               (chr)      (dbl)    (dbl)     (chr)      (int)
#> 1  Ursus americanus  -79.68283 38.36662 14Jan2015 1065590124
#> 2  Ursus americanus  -82.42028 35.73304 13Jan2015 1065588899
#> 3  Ursus americanus  -99.09625 23.66893 20Feb2015 1098894889
#> 4  Ursus americanus  -72.77432 43.94883 13Feb2015 1065611122
#> 5  Ursus americanus  -72.34617 43.86464 01Mar2015 1088908315
#> 6  Ursus americanus -108.53674 32.65219 29Mar2015 1088932238
#> 7  Ursus americanus -108.53691 32.65237 29Mar2015 1088932273
#> 8  Ursus americanus -123.82900 40.13240 28Mar2015 1132403409
#> 9  Ursus americanus  -78.25027 36.93018 20Mar2015 1088923534
#> 10 Ursus americanus  -76.78671 35.53079 05Apr2015 1088954559
#> ..              ...        ...      ...       ...        ...
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
#> <scrubr dframe>
#> Size: 1500 X 8
#>
#>
#>                name  longitude latitude        key  year month   day
#>               (chr)      (dbl)    (dbl)      (int) (chr) (chr) (chr)
#> 1  Ursus americanus  -79.68283 38.36662 1065590124  2015    01    14
#> 2  Ursus americanus  -82.42028 35.73304 1065588899  2015    01    13
#> 3  Ursus americanus  -99.09625 23.66893 1098894889  2015    02    20
#> 4  Ursus americanus  -72.77432 43.94883 1065611122  2015    02    13
#> 5  Ursus americanus  -72.34617 43.86464 1088908315  2015    03    01
#> 6  Ursus americanus -108.53674 32.65219 1088932238  2015    03    29
#> 7  Ursus americanus -108.53691 32.65237 1088932273  2015    03    29
#> 8  Ursus americanus -123.82900 40.13240 1132403409  2015    03    28
#> 9  Ursus americanus  -78.25027 36.93018 1088923534  2015    03    20
#> 10 Ursus americanus  -76.78671 35.53079 1088954559  2015    04    05
#> ..              ...        ...      ...        ...   ...   ...   ...
#> Variables not shown: date (chr).
```

## Meta

* Please [report any issues or bugs](https://github.com/ropenscilabs/scrubr/issues).
* License: MIT
* Get citation information for `scrubr` in R doing `citation(package = 'scrubr')`
* Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

[![ropensci_footer](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
