
# Adding inset maps
_All info has been moved to the README.md file_

Adding an inset or regional map is sometime the go-to thing, expecially for ecological studies. This helps put the study in a regional or national context and orient people to your study area. 

Using the exsisting [code](https://github.com/SwampThingPaul/rstat_mapping/blob/f64c19d9c00d66986d969b4c7d2e02c9c88407fe/X_rstat_map.R) and data posted in this repository in conjunction with `Viewport()` in the `library(grid)` or `tmap_save()`.

![example](https://user-images.githubusercontent.com/36565183/45112137-d40ec480-b114-11e8-814d-0a69e04fa6ae.png)

Focused study site map.
```
map2=base.map+tm_shape(TN.GM)+
  tm_symbols(size=0.5,col="Geomean",breaks=c(-Inf,0.5,1,2,Inf),showNA=T,palette=cols.rmp,
             title.col="Annual Geometric \nMean TN \nConcentration (mg/L)",
             labels=c("\u003C 0.5","0.5 - 1.0","1.0 - 2.0", "\u003E2.0"),border.lwd=0.5,colorNA = "white")+
  tm_compass(type="arrow",position=c("left","bottom"))+
  tm_scale_bar(position=c("left","bottom"))+
  tm_layout(bg.color=cols[2],fontfamily = "serif",legend.outside=T,scale=1,asp=NA,
            outer.margins=c(0.005,0.01,0.005,0.01),inner.margins = 0,between.margin=0,
            legend.text.size=1,legend.title.size=1.25)
```

Essentially a second regional map is needed for the inset and adding a polygon showing the larger map extent. To make the larger map extent polygon you can leverage the `bbox` of the larger map.
```
bbox.poly=as(bbox,"SpatialPolygons")#makes the polygon
proj4string(bbox.poly)=proj4string(evpa)#projects the polygon

#the smaller basic regional map
region.map=tm_shape(shore)+tm_polygons(col=cols[1])+
  tm_shape(bbox.poly)+tm_borders(lty=2,lwd=2.5,"red")
 ```
To view and see how things fits together you can use the `Viewport()` function, granted its tricky to move things around since the units Normalised Parent Coordinates"npc".

```
map2
print(region.map,vp=viewport(0.82,0.29,0.3,0.60,just="right"))
```

But if you want to write the map to a file you can use `tmap_save()` function
```
tmap_save(map2,"example.png",width = 6.5,height=7,units="in",dpi=200,
  insets_tm=region.map,insets_vp =viewport(0.94,0.21,0.3,0.60,just="right") )
```

***
