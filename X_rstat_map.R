### Mapping in R to produce easily reproducable maps
## Script assembled by Paul Julian, PhD 
## Email: pjulian@ufl.edu
## version: 2018-08-01

#Remove/clears everything. (STARTING FRESH)
rm(list=ls(all=T));cat("\014");dev.off()
CurWY=2018
###Set working directory (Don't hate me)
## Must adjust this to the path on your PC. All other paths are relative to the working directory
setwd("//fldep1/owper/evg/programmatic/waterquality/SFER/SFER Analysis/Analysis")

##Libraries (some are not used in this specific script)
# installs libraries from github
# devtools::install_github("statnmap/HatchedPolygons")
# devtools::install_github("mtennekes/tmaptools"); # earlier version available in repository
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
###Paths 
## Must adjust this to paths on your PC. 
PlotPath=paste(getwd(),"/Plots/WY",CurWY,"/Ch3A/",sep=""); #where final plots get saved. 
GIS.path=paste(dirname(dirname(getwd())),"/GIS_NEW/",sep=""); #Where GIS data resides.
db.path=paste(GIS.path,"SFER_GIS_Geodatabase.gdb",sep=""); #Path of the geodatabase where base shapefiles are housed.

#Custom Functions and other items
#source("D:/CommonlyUsedFunctions.r"); #not used in this script
N=function(x,NA.val="NA") length(which(x!=NA.val))

hatched.SP=function(x,density=0.001,angle=45,fillOddEven = FALSE){
  require(HatchedPolygons)
  tmp=hatched.SpatialPolygons(x,density=density,angle=angle,fillOddEven = fillOddEven)
  proj4string(tmp)=proj4string(x)
  return(tmp)
}

cols=c(rgb(255/255,235/255,175/255,1,"esri.topaz.sand"),
       rgb(190/255,232/255,255/255,1,"esri.light.blue"),
       rgb(151/255,219/255,242/255,1,"esri.light.blue1"),
       rgb(247/255,255/255,231/255,1,"light.green"),
       rgb(109/255,187/255,67/255,1,"esri.green1"))

#Projection help
#site location data are projected in the NAD83 HARN Florida State Plane East Zone coordinates in units of feet
state.plane=CRS("+proj=tmerc +lat_0=24.33333333333333 +lon_0=-81 +k=0.999941177 +x_0=200000.0001016002 +y_0=0 +ellps=GRS80 +to_meter=0.3048006096012192 +no_defs")
####
####
#### Data import
####
####
## site location data
site.loc=read.csv(paste0(GIS.path,"site_location.csv"))
#Some Alias' are duplicated as Station IDs have changed during the course of sampling and/or sampling location has slightly shifted. 
site.loc1=ddply(site.loc,c("Alias","Area","Class"),summarise,Xval=min(XCOORD,na.rm=T),Yval=min(YCOORD,na.rm=T),Nval=N(Alias))
site.loc2=ddply(subset(site.loc,Status=="Active"),c("Alias","Area","Class"),summarise,Xval=min(XCOORD,na.rm=T),Yval=min(YCOORD,na.rm=T),Nval=N(Alias))

## Spatial data
evpa=readOGR(db.path,"EPA_Boundary")
rs.feat=readOGR(db.path,"RestorationStrategies_Features")
rs.feat.hatch=hatched.SP(rs.feat)
sta=readOGR(db.path,"EvergladesSTAs")
bcnp=readOGR(db.path,"BCNP")
canal=readOGR(db.path,"SFWMD_Canals")
shore=readOGR(db.path,"SFWMD_Shoreline")
eaa=readOGR(db.path,"EvergladesAgriculturalArea")
wma=readOGR(db.path,"HoleyLand_Rotenberger")
wma.hatch=hatched.SP(wma)
wca=readOGR(db.path,"WCAs")
enp.shore=readOGR(db.path,"Shoreline_ENPClip")
c139=readOGR(db.path,"C139Annex")
enp=readOGR(db.path,"ENP")

## Geometric Mean TN concentration for the current WY
TN.GM=read.csv(paste0(GIS.path,"TN_WY2018_GMMaps.csv"))
TN.GM=merge(TN.GM,site.loc2,by.x=c("STATION_ID","Area","Class"),by.y=c("Alias","Area","Class"),all.y=T);#merge GM data and XY data
sum(is.na(TN.GM$Xval))#double check to make sure all sites have coordinates. Value should be 0
TN.GM=SpatialPointsDataFrame(coords=TN.GM[,c("Xval","Yval")],data=TN.GM,proj4string = state.plane)
TN.GM=spTransform(TN.GM,crs(evpa))# reproject the data in the sample coordinates system of EvPA
crs(TN.GM);#double check the coordinates



####
####
#### Mapping
####
####

## Base Map 
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
  tm_shape(evpa)+tm_borders(col="red",lwd=1.5)

base.map

col.rmp=colorRampPalette(c("lawngreen","indianred1"))
cols.rmp=as.character(col.rmp(5))

#png(filename=paste(PlotPath,"WY",CurWY,"_TN_Demo_Plot.png",sep=""),width=6.5,height=7.5,units="in",res=200,type="windows",bg="white")
base.map+tm_shape(TN.GM)+
  tm_symbols(size=0.5,col="Geomean",breaks=c(-Inf,0.5,1,2,Inf),showNA=T,palette=cols.rmp,
             title.col="Annual Geometric \nMean TN \nConcentration (mg/L)",
             labels=c("\u003C 0.5","0.5 - 1.0","1.0 - 2.0", "\u003E2.0"),border.lwd=0.5,colorNA = "white")+
  tm_compass(type="arrow",position=c("left","bottom"))+
  tm_scale_bar(position=c("left","bottom"))+
  tm_layout(bg.color=cols[2],fontfamily = "serif",legend.outside=T,scale=1,asp=NA,
            outer.margins=c(0.005,0.01,0.005,0.01),inner.margins = 0,between.margin=0,
            legend.text.size=1,legend.title.size=1.25)
dev.off()

#Another way to write the map to a file  is to use the tmap_save() function
map2=base.map+tm_shape(TN.GM)+
  tm_symbols(size=0.5,col="Geomean",breaks=c(-Inf,0.5,1,2,Inf),showNA=T,palette=cols.rmp,
             title.col="Annual Geometric \nMean TN \nConcentration (mg/L)",
             labels=c("\u003C 0.5","0.5 - 1.0","1.0 - 2.0", "\u003E2.0"),border.lwd=0.5,colorNA = "white")+
  tm_compass(type="arrow",position=c("left","bottom"))+
  tm_scale_bar(position=c("left","bottom"))+
  tm_layout(bg.color=cols[2],fontfamily = "serif",legend.outside=T,scale=1,asp=NA,
            outer.margins=c(0.005,0.01,0.005,0.01),inner.margins = 0,between.margin=0,
            legend.text.size=1,legend.title.size=1.25)

tmap_save(map2,"map.png",width = 6.5,height=7,units="in",dpi=200) #may have to adjust the dimensions slightly. Code added after the fact.
