scrubr
======



[![Build Status](https://travis-ci.org/sckott/scrubr.svg?branch=master)](https://travis-ci.org/sckott/scrubr)
[![codecov.io](http://codecov.io/github/sckott/scrubr/coverage.svg?branch=master)](http://codecov.io/github/sckott/scrubr?branch=master)

__Clean Biological Occurrence Records__

Clean using the following use cases:

- [x] Impossible lat/long values: e.g., latitude 75
- [x] Incomplete cases: one or the other of lat/long missing
- [x] Unlikely lat/long values: e.g., points at 0,0
- [x] Deduplication: try to identify duplicates, esp. when pulling data from multiple sources, e.g., can try to use occurrence IDs, if provided
* Political centroids: unlikely that occurrences fall exactly on these points, more likely a
default position
* Herbaria/Museums: many specimens may have location of the collection they are housed in
* Habitat type filtering: e.g., fish should not be on land; marine fish should not be in fresh water
* Check for contextually wrong values: That is, if 99 out of 100 lat/long coordinates are within the continental US, but 1 is in China, then perhaps something is wrong with that one point
* Outside political boundary: User input to check for points in the wrong country, or points outside of a known country
* Taxonomic name based cleaning: via `taxize`
* Date based cleaning perhaps?
* ...

## Install


```r
devtools::install_github("sckott/scrubr")
```


```r
library("scrubr")
```

## Coordinate based cleaning

Remove impossible coordinates (using sample data included in the pkg)


```r
clean_df(sample_data_1) %>% coord_impossible()
#> <clean dataset>
#> Size: 1500 X 5
#> 
#>                name  longitude latitude                date        key
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

Remove impossible coordinates


```r
clean_df(sample_data_1) %>% coord_incomplete()
#> <clean dataset>
#> Size: 1306 X 5
#> 
#>                name  longitude latitude                date        key
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

Remove unlikely points (e.g., those at 0,0)


```r
clean_df(sample_data_1) %>% coord_unlikely()
#> <clean dataset>
#> Size: 1488 X 5
#> 
#>                name  longitude latitude                date        key
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
clean_df(sample_data_1) %>%
  coord_impossible() %>%
  coord_incomplete() %>%
  coord_unlikely()
#> <clean dataset>
#> Size: 1294 X 5
#> 
#>                name  longitude latitude                date        key
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
clean_df(sample_data_1) %>% coord_incomplete(drop = TRUE) %>% NROW
#> [1] 1306
clean_df(sample_data_1) %>% coord_incomplete(drop = FALSE) %>% NROW
#> [1] 1500
```


## Dedpulicate


```r
smalldf <- sample_data_1[1:20, ]
# create a duplicate record
smalldf <- rbind(smalldf, smalldf[10,])
# make it slightly different
smalldf[21, "key"] <- 1088954555
NROW(smalldf)
#> [1] 21
dp <- clean_df(smalldf) %>% dedup()
#> Error in sparseMatrix(i = indices, j = rep.int(1:length(strings), strings.length)): could not find function "checkAtAssignment"
NROW(dp)
#> Error in NROW(dp): object 'dp' not found
attr(dp, "dups")
#> Error in eval(expr, envir, enclos): object 'dp' not found
```

## Meta

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
