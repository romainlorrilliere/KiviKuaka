
## importation and exploration weather data at nc format
## https://pjbartlein.github.io/REarthSysSci/netCDF.html



### Reading a netCDF data set using the ncdf4 package

## load the ncdf4 package
library(ncdf4)


## set path and filename
ncpath <- "../data_weather/test_20210823/"
ncname <- "test_fc_small_20210823"
ncfname <- paste(ncpath, ncname, ".nc", sep="")
dname <- "t"  ## note: tmp means temperature (not temporary)

## open a netCDF file
ncin <- nc_open(ncfname)
print(ncin)


## get longitude and latitude
lon <- ncvar_get(ncin,"longitude")
nlon <- dim(lon)
head(lon)

lat <- ncvar_get(ncin,"latitude")
nlat <- dim(lat)
head(lat)

## get time
time <- ncvar_get(ncin,"time")
time

tunits <- ncatt_get(ncin,"time","units")
nt <- dim(time)
nt
tunits


## get temperature
tmp_array <- ncvar_get(ncin,dname)
dlname <- ncatt_get(ncin,dname,"long_name")
dunits <- ncatt_get(ncin,dname,"units")
fillvalue <- ncatt_get(ncin,dname,"_FillValue")
dim(tmp_array)

## close nc connexion
##nc_close()



### Reshaping from raster to rectangular

## load some packages
library(chron)
library(lattice)
library(RColorBrewer)


## convert time -- split the time units string into fields
tustr <- strsplit(tunits$value, " ")
tdstr <- strsplit(unlist(tustr)[3], "-")
tmonth <- as.integer(unlist(tdstr)[2])
tday <- as.integer(unlist(tdstr)[3])
tyear <- as.integer(unlist(tdstr)[1])
chron(time,origin=c(tmonth, tday, tyear))

## replace netCDF fill values with NA's
tmp_array[tmp_array==fillvalue$value] <- NA

length(na.omit(as.vector(tmp_array[,,1,1])))



## get a single slice or layer (January)
m <- 1
heure <- 1
tmp_slice <- tmp_array[,,m,heure]


## quick map
image(lon,sort(lat),tmp_slice, col=rev(brewer.pal(10,"RdBu")))

## levelplot of the slice
grid <- expand.grid(lon=lon, lat=lat)
grid <- data.frame(grid,tmp_slice = as.vector(tmp_slice))
cutpts <- seq(250,270,length.out = 11)
levelplot(tmp_slice ~ lon * lat, data=grid, at=cutpts, cuts=11, pretty=T,col.regions=(rev(brewer.pal(10,"RdBu"))))

library(ggplot2)
gg <- ggplot(data=grid, aes(y =lat,x= lon, fill= tmp_slice))
gg <- gg + geom_tile()
gg <- gg + scale_fill_gradient2(midpoint = mean(tmp_slice), low = "blue", mid = "white",  high = "red" )
gg

## create dataframe -- reshape data
## matrix (nlon*nlat rows by 2 cols) of lons and lats
lonlat <- as.matrix(expand.grid(lon,lat))
dim(lonlat)


## vector of `tmp` values
tmp_vec <- as.vector(tmp_slice)
length(tmp_vec)



## create dataframe and add names
tmp_df01 <- data.frame(cbind(lonlat,tmp_vec))
names(tmp_df01) <- c("lon","lat",paste(dname,as.character(m), sep="_"))
head(na.omit(tmp_df01), 10)


tmp_vec_long <- as.vector(tmp_array)
length(tmp_vec_long)


###_________________________________



library(data.table)
DT1 <- as.data.table(as.data.frame.table(tmp_array[,,,]))
dt_lon <- data.table(Var1 = sort(unique(DT1[,Var1])), lon)
dt_lat <- data.table(Var2 = sort(unique(DT1[,Var2])), lat)
dt_alt <- data.table(Var3 = sort(unique(DT1[,Var3])),alt = c(100,500,1500,3000,4200,5600))
dt_hour <- data.table(Var4 = sort(unique(DT1[,Var4])),hour = paste0(sprintf("%02d",0:23),":00"))



DT <- merge(DT1,dt_lon,by="Var1")
DT <- merge(DT,dt_lat,by="Var2")
DT <- merge(DT,dt_alt,by="Var3")
DT <- merge(DT,dt_hour,by="Var4")
DT[,temperature := Freq - 273.15]

gg <- ggplot(data=DT, aes(y =lat,x= lon, fill= temperature)) + facet_grid(hour~alt)
gg <- gg + geom_tile()
gg <- gg + scale_fill_gradient2(midpoint = mean(DT$temperature), low = "blue", mid = "white",  high = "red" )
gg


aaa <- array(rnorm(3*4*2), dim = c(3,4,2))
DT1 <- as.data.table(as.data.frame.table(aaa))


source("fun_wether_nc.r")


d_temp <- get_weather_variable()
d_temp[,id := paste(Var1,Var2,Var3,Var4,sep="_")]
d <- d_temp

d_hum <- get_weather_variable( dname = "r",var_name = "humidity",conv_var= NULL)
d_hum[,id := paste(Var1,Var2,Var3,Var4,sep="_")]
d_hum <- d_hum[,.(id,humidity)]
d <- merge(d,d_hum,by="id")

d_vent_u <- get_weather_variable( dname = "u",var_name = "wind_u",conv_var= NULL)
d_vent_u[,id := paste(Var1,Var2,Var3,Var4,sep="_")]
d_vent_u <- d_vent_u[,.(id,wind_u)]
d <- merge(d,d_vent_u,by="id")

d_vent_v <- get_weather_variable( dname = "u",var_name = "wind_v",conv_var= NULL)
d_vent_v[,id := paste(Var1,Var2,Var3,Var4,sep="_")]
d_vent_v <- d_vent_v[,.(id,wind_v)]
d <- merge(d,d_vent_v,by="id")


d[,wind_speed := sqrt(wind_u^2 + wind_v^2)]
d[,wind_direction := windDir(wind_u,wind_v)]

d[,altitude_fact := factor(altitude,levels=sort(unique(altitude),decreasing=TRUE))]

d[,wind_direction_1_3 := longitude %in% sort(unique(longitude))[c(FALSE,TRUE,FALSE)] & latitude %in% sort(unique(latitude))[c(FALSE,TRUE,FALSE)]]

d[,wind_direction_1_5 := longitude %in% sort(unique(longitude))[c(FALSE,FALSE,TRUE,FALSE,FALSE)] & latitude %in% sort(unique(latitude))[c(FALSE,FALSE,TRUE,FALSE,FALSE)]]


gg <- ggplot(data=d_vent, aes(y =latitude,x= longitude, fill= vent_vitesse)) + facet_grid(hour~altitude_fact)
gg <- gg + geom_tile()
gg <- gg + scale_fill_gradient(low = "yellow", high = "red" )
gg


gg <- ggplot(d_vent, aes(x = longitude , y = latitude, fill = vent_vitesse, angle = vent_dir, radius = scales::rescale(vent_dir, c(.2, .8))))
gg <- gg + facet_grid(hour~altitude)
gg <- gg + geom_tile()#    geom_raster() +
gg <- gg + geom_spoke(arrow = arrow(length = unit(.05, 'inches')))
gg <- gg + scale_fill_distiller(palette = "RdYlGn")
gg <- gg + coord_equal(expand = 0)
gg <- gg + theme(legend.position = 'bottom', legend.direction = 'horizontal')
gg



d_vent[,vent_direction_1_3 := longitude %in% sort(unique(longitude))[c(FALSE,TRUE,FALSE)] & latitude %in% sort(unique(latitude))[c(FALSE,TRUE,FALSE)]]


d_vent_h_alt <- d_vent[hour == "12:00" & altitude == 100,]
d_vent_h <- d_vent[hour == "12:00",]


gg <- ggplot(d_vent_h, aes(x = longitude , y = latitude, fill = vent_vitesse, angle = vent_dir, radius = scales::rescale(vent_vitesse, c(.2, .8))))
gg <- gg + facet_grid(altitude~hour)
gg <- gg + geom_tile()#    geom_raster() +
gg <- gg + geom_spoke(data= d_vent_h[vent_direction_1_3 == TRUE,],arrow = arrow(length = unit(.05, 'inches')))
gg <- gg + scale_fill_distiller(palette = "RdYlGn")
gg <- gg + coord_equal(expand = 0)
gg <- gg + theme(legend.position = 'bottom', legend.direction = 'horizontal')
gg






library(ggplot2)

gg <- ggplot(data=d[hour %in% c("00:00","06:00","12:00","18:00"),], aes(y =latitude,x= longitude, fill= temperature)) + facet_grid(altitude_fact~hour)
gg <- gg + geom_tile()
gg <- gg + scale_fill_gradient2(midpoint = mean(d$temperature), low = "blue", mid = "white",  high = "red" )
gg <- gg + labs(main="temperature",sub=ncname)
gg
ggsave("output/temperature.png",gg,width=16,height=9)



gg <- ggplot(data=d[hour %in% c("00:00","06:00","12:00","18:00"),], aes(y =latitude,x= longitude, fill= humidity)) + facet_grid(altitude_fact~hour)
gg <- gg + geom_tile()
gg <- gg + labs(main="humidity",sub=ncname)
ggsave("output/humidity.png",gg,width=16,height=9)


gg <- ggplot(data=d[hour %in% c("06:00","12:00","18:00")& altitude %in% c(100,1500,4200),], aes(x = longitude , y = latitude, fill = wind_speed, angle = wind_direction, radius = scales::rescale(wind_speed, c(.2, .8))))
gg <- gg + facet_grid(altitude_fact~hour)
gg <- gg + geom_tile()#    geom_raster() +
gg <- gg + geom_spoke(data= d[hour %in% c("06:00","12:00","18:00")& altitude %in% c(100,1500,4200)& wind_direction_1_5 == TRUE,],arrow = arrow(length = unit(.03, 'inches')))
gg <- gg + scale_fill_distiller(palette = "RdYlGn")
gg <- gg + coord_equal(expand = 0)
gg <- gg + labs(main="wind",sub=ncname)
                                        ## gg <- gg + theme(legend.position = 'bottom', legend.direction = 'horizontal')
gg
ggsave("output/wind_2.png",gg,width=16,height=9)


gg <- ggplot(data=d[hour %in% c("12:00")& altitude %in% c(3000),], aes(x = longitude , y = latitude, fill = wind_speed, angle = wind_direction, radius = scales::rescale(wind_speed, c(.2, .8))))
gg <- gg + facet_grid(altitude_fact~hour)
gg <- gg + geom_tile()#    geom_raster() +
gg <- gg + geom_spoke(data= d[hour %in% c("12:00")& altitude %in% c(3000)& wind_direction_1_3 == TRUE,],arrow = arrow(length = unit(.03, 'inches')))
gg <- gg + scale_fill_distiller(palette = "RdYlGn")
gg <- gg + coord_equal(expand = 0)
gg <- gg + labs(main="wind",sub=ncname)
                                        ## gg <- gg + theme(legend.position = 'bottom', legend.direction = 'horizontal')
gg
ggsave("output/wind_1.png",gg,width=16,height=9)







source("fun_wether_nc.r")
d <- nc_2_dt()
dim(d)
dd <- d



world <- sf::st_as_sf(maps::map('world', plot = FALSE, fill = TRUE))
world.pacific <- st_transform(world,crs=3832)
xlim <- c(min(d$longitude_3832),max(d$longitude_3832))
ylim <- c(min(d$latitude_3832),max(d$latitude_3832))


gg <- ggplot() + geom_sf(data = world.pacific,fill="white", colour="#7f7f7f", size=0.2)
gg <- gg + geom_sf(data=point.sf,colour="black",alpha=0.5)
gg <- gg + coord_sf(xlim=xlim,ylim=ylim)
gg <- gg + theme(panel.background = element_rect(fill = "#a6bddb"), panel.grid = element_blank())
gg


 the_date="2021-08-23";the_hour="12:00";altitudes=c(100);save=FALSE;file_out=NULL;width=NULL;height=NULL;return=TRUE
d <- d[date ==the_date & hour == the_hour,]
 if(!is.null(altitudes)) d <- d[altitude %in% altitudes,]

    gg_temp <- ggplot(data=d, aes(y =latitude_3832,x= longitude_3832, fill= temperature)) + facet_grid(altitude_fact~.)
    gg_temp <- gg_temp + geom_tile()
    gg_temp <- gg_temp + scale_fill_gradient2(midpoint = 15, low = "blue", mid = "white",  high = "red" )
    gg_temp <- gg_temp + coord_equal(expand = 0)
    gg_temp <- gg_temp + labs(main="temperature")
    gg_temp <- gg_temp + theme(legend.position = 'bottom', legend.direction = 'horizontal')

gg_temp


world <- sf::st_as_sf(maps::map('world', plot = FALSE, fill = TRUE))
world.pacific <- st_transform(world,crs=3832)
xlim <- c(min(d$longitude_3832),max(d$longitude_3832))
ylim <- c(min(d$latitude_3832),max(d$latitude_3832))

fun_color_range <- colorRampPalette(c("lightgray","purple","darkblue","lightblue","green","yellow","red","darkred"))
my_colors <- fun_color_range(90)


gg_temp <- ggplot() + geom_sf(data = world.pacific,fill="white", colour="white", size=0.2)
gg_temp <- gg_temp + geom_tile(data=d,aes(y =latitude_3832,x= longitude_3832, fill= temperature),alpha=0.8,colour=NA)
gg_temp <- gg_temp + geom_sf(data = world.pacific,fill=NA, colour="white",size=0.2)
gg_temp <- gg_temp + coord_sf(xlim=xlim,ylim=ylim)
gg_temp <- gg_temp + theme(panel.background = element_rect(fill = "#a6bddb"), panel.grid = element_blank())
    gg_temp <- gg_temp + labs(main="temperature",x="",y="")
gg_temp <- gg_temp + theme(legend.position = 'bottom', legend.direction = 'horizontal')
gg_temp <- gg_temp + scale_fill_gradientn(colours = my_colors,limits=c(-20,40))
gg_temp



gg1 <- gg_weather_date_alt(d,the_date="2021-08-23",the_hour="12:00",altitudes=c(100,1500,4200),width=16,height=9,save=TRUE)




gg <- ggplot(data=lulu, aes(x = longitude_raw , y = latitude, fill = wind_speed, angle = wind_direction, radius = scales::rescale(wind_speed, c(0.2, 0.8))))
gg <- gg + facet_grid(altitude_fact~hour)
gg <- gg + geom_tile()#    geom_raster() +
gg <- gg + geom_spoke(data= lulu[wind_direction_1_5 == TRUE,],arrow = arrow(length = unit(.03, 'inches')))
#gg <- gg + scale_fill_distiller(palette = "RdYlGn")
gg <- gg + coord_equal(expand = 0)
gg <- gg + labs(main="wind",sub=ncname)
  gg <- gg + scale_fill_gradientn(colours = my_colors,limits=c(0,400))
gg

hist(lulu$wind_u)
hist(lulu$wind_v)
hist(lulu$wind_u/lulu$wind_v)


lulu[,wind_direction_2 := atan2(wind_u/wind_speed, wind_v/wind_speed)*180/pi ]




source("fun_wether_nc.r")
d <- nc_2_dt()

vecH <- c("00:00","01:00","02:00","03:00","04:00","05:00","06:00","07:00","08:00","09:00","10:00","11:00","12:00","13:00","14:00","15:00","16:00","17:00","18:00","19:00","20:00","21:00","22:00","23:00")
lgg <- list()
for(i in 1:length(vecH)){
    h <- vecH[i]
    cat(i,h,"")
    lgg[[i]] <- gg_weather_date_alt(d,the_date="2021-08-23",the_hour=h,altitudes=c(100,1500,4200),width=16,height=9,save=TRUE)
    print(lgg[[i]])
    cat("  DONE !\n")
}





#################################################



    # load libraries
library("ecmwfr")
library("raster")
library("tidyverse")
library("rnaturalearth")
library("sf")
library("gganimate")
library("gifski")

# custom fonts
library(showtext)
font_add_google("Prata", regular.wt = 400)
showtext_auto()


# formulate a ECMWF API request
request <- list(
  date = "2021-07-21/2021-07-21",
  type = "forecast",
  format = "netcdf_zip",
  variable = "black_carbon_aerosol_optical_depth_550nm",
  time = "00:00",
  leadtime_hour = as.character(1:120),
  area = c(90, -180, 0, 180),
  dataset_short_name = "cams-global-atmospheric-composition-forecasts",
  target = "download.zip"
)



# download the data (file location is returned)
file <- wf_request(
  request,
  user = "xyz"
  )




# unzip zip file (when multiples are called this will be zipped)
unzip(file, exdir = tempdir())
files <- list.files(tempdir(), "*.nc", full.names = TRUE)

# copy files to the data directory
file.copy(files, "data/carbon.nc")



########################################################



source("fun_wether_nc.r")
d <- nc_2_dt()
dim(d)
dd <- d

dalt <- d[altitude == 100,]

require(ggplot2)
require(ggpubr)
require(sf)
require(gganimate)

world <- sf::st_as_sf(maps::map('world', plot = FALSE, fill = TRUE))
world.pacific <- st_transform(world,crs=3832)
xlim <- c(min(d$longitude_3832),max(d$longitude_3832))
ylim <- c(min(d$latitude_3832),max(d$latitude_3832))

fun_color_range <- colorRampPalette(c("lightgray","purple","darkblue","lightblue","green","yellow","red","darkred"))
my_colors <- fun_color_range(90)


gg_temp <- ggplot()+ geom_sf(data = world.pacific,fill="white", colour="white", size=0.2)
gg_temp <- gg_temp + facet_grid(altitude_fact~.)
gg_temp <- gg_temp + geom_tile(data=dalt,aes(y =latitude_3832,x= longitude_3832, fill= temperature),alpha=0.8,colour=NA)
gg_temp <- gg_temp + geom_sf(data = world.pacific,fill=NA, colour="white",size=0.2,alpha=0.5)
gg_temp <- gg_temp + coord_sf(xlim=xlim,ylim=ylim)
gg_temp <- gg_temp + scale_fill_gradientn(colours = my_colors,limits=c(-20,40))
gg_temp <- gg_temp + theme(panel.background = element_rect(fill = "#a6bddb"), panel.grid = element_blank())
gg_temp <- gg_temp + labs(main="temperature",x="",y="")
gg_temp <- gg_temp + theme(legend.position = 'bottom', legend.direction = 'horizontal')
gg_temp <- gg_temp + transition_manual(hour)


