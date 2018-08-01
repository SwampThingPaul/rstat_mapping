# Mapping In R

To date mapping in R has been very limited and frustrating. As many people have noted that R is not a mapping software. Its not really a geospatial analysis software however with the develope of more and more packages and the evolution of R.

This repository houses a geospatial database (.gdb) assembled in ArcGIS, several comma-seperated files (.csv) and a basic R script developed for this repositiory to develop the map below.

![wy2018_tn_demo_plot](https://user-images.githubusercontent.com/36565183/43526306-e46419de-9571-11e8-9b11-2a8ef9c3852f.png)

The R-script utilizes several packages including `library(tmap)` [github page](https://github.com/mtennekes/tmap) and `library(HatchedPolygons)` [github page](https://github.com/statnmap/HatchedPolygons). 

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

Unfortunatly at this time, the `tmap` library does not have a pattern filled option for polygons as discussed [here](https://github.com/mtennekes/tmap/issues/49). Therefore a workaround is needed, leveraging the functions in the `library(HatchedPolygons)` library, I developed a custom helper function to make a patterned fill. the purporse of the custom function is that the `hatched.SpatialPolygons()` function does not produce a spatial data frame with a projection, therefore I added the `proj4string()` function into the custom function.  

```
hatched.SP=function(x,density=0.001,angle=45,fillOddEven = FALSE){
  require(HatchedPolygons)
  tmp=hatched.SpatialPolygons(x,density=density,angle=angle,fillOddEven = fillOddEven)
  proj4string(tmp)=proj4string(x)
  return(tmp)
}
```

So far after endless hours of searching I found the `tmap` library the easiest for producing reproducible maps in the R-environment. After importing and adjusting data as needed a basemap can be put together very easily using the `tmap` functionality. After setting your bounding box or "Area of Interest" you are off to the races specifying where the layers sit (like in ArcGIS), what color, line type, point type, etc. Below is from the r-script ([link](https://github.com/SwampThingPaul/rstat_mapping/blob/6cb5b478149678830c7e9d5e09de66918623ce94/X_rstat_map.R)), some layers are layers twice for effect. 

```
bbox=raster::extent(473714,587635,2748300,2960854);#Bounding box for our Area of Interest (AOI)
base.map=tm_shape(shore,bbox=bbox)+tm_polygons(col=cols[1])+
  tm_shape(eaa)+tm_fill("olivedrab1")+tm_borders("grey",lwd=1.5,lty=1.75)+
  tm_shape(spsample(eaa,"random",n=500,pretty=F))+tm_dots(col="grey80",size=0.005)+
  tm_shape(c139)+tm_fill("grey")+
  tm_shape(sta)+tm_polygons("skyblue")+
  tm_shape(rs.feat)+tm_polygons("steelblue3")+
  tm_shape(rs.feat.hatch)+tm_lines(col="grey")+
  tm_shape(wma)+tm_borders("grey50",lwd=1.5,lty=2)+tm_fill(cols[3])+
  tm_shape(wma.hatch)+tm_lines(col=cols[5],lwd=2)+tm_shape(wma)+tm_borders("grey50",lwd=2,lty=1)+
  tm_shape(wca)+tm_fill("white")+
  tm_shape(bcnp)+tm_fill(cols[4])+
  tm_shape(enp.shore)+tm_fill("white")+tm_borders("dodgerblue3",lwd=1)+
  tm_shape(canal)+tm_lines("dodgerblue3",lwd=2)+
  tm_shape(canal)+tm_lines(cols[2],lwd=1)+
  tm_shape(evpa)+tm_borders(col="red",lwd=1.5);
```

Once the base map is put together to your liking, then you can layer on points, rasters, etc. very simply. 

```
base.map+tm_shape(TN.GM)+tm_symbol();
```
Use the `png() ... dev.off()` function to write the plot to a file. 

A complete script has been posted in this repository for your convience named [X_rstat_map.r](https://github.com/SwampThingPaul/rstat_mapping/blob/6cb5b478149678830c7e9d5e09de66918623ce94/X_rstat_map.R). 

__NOTE:__ All paths are relative but I do set a working directory, therefore you will need to adjust as needed for your machine. 

If you run into issues or have questions feel free to drop me a [line](mailto:pjulian@ufl.edu).


