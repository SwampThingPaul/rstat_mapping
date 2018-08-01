# Mapping In R

To date mapping in R has been very limited and frustrating. As many people have noted that R is not a mapping software. Its not really a geospatial analysis software however with the develope of more and more packages and the evolution of R.

This repository houses a geospatial database (.gdb) assembled in ArcGIS, several comma-seperated files (.csv) and a basic R script developed for this repositiory. 

The R-script utilizes several packages including `library(tmap)` [github page](https://github.com/mtennekes/tmap) and `library(HatchedPolygons)` [github page](https://github.com/statnmap/HatchedPolygons). The R-script has everything identified. 

Here is a list of libraries called for this effort (some may not be used).
```
library(maptools)
library(classInt)
library(GISTools)
library(rgdal)
library(sp)
library(tmap)
library(raster)
library(spatstat)
library(sf)
library(HatchedPolygons)

library(plyr)
```
