
vecPackage=c("move","lubridate","ggplot2","ggmap","moveVis","data.table","suncalc")
ip <- installed.packages()[,1]

for(p in vecPackage){
    if (!(p %in% ip))
        install.packages(pkgs=p,repos = "https://pbil.univ-lyon1.fr/CRAN/",dependencies=TRUE)
    library(p,character.only = TRUE)

}



pw <-"crexCREX44!"
username <-"romainlorrilliere"
log <- movebankLogin(username,pw)
study_id  <- 1381110575





###### analyse of the track synchrony betwwen two curlew
### EC110534 and EC110531

source("../functions/fun_importation.r")


ind <- getMovebankAnimals(study=study_id, login=log)
setDT(ind)

vecRing <- c("[FRP-EC110534]","[FRP-EC110531]","[FRP-EC110533]","[FRP-EC110536]")
the_names <- unique(ind[ring_id %in% vecRing,individual_id])

d <- getMovebankData(study=study_id, login=log,removeDuplicatedTimestamps=TRUE,animalName=the_names,timestamp_start="20210425000000000")

plot(d)


##data2 <- spTransform(d, CRSobj="+proj=aeqd +ellps=WGS84", center=TRUE)

## create a DBBMM object
##dbbmm <- brownian.bridge.dyn(object=data2, location.error=12, dimSize=125, ext=1.2,
		##	     time.step=2, margin=15)

##plot(dbbmm)

dd <- as.data.frame(d)
setDT(dd)

ddd <- dd[,c("tag_id","trackId","individual_id","local_identifier","nick_name","event_id","timestamp","location_long","location_lat")]
fwrite(ddd,"data/4_courlis.csv")


ggplot(data = dd, aes(x = location_long, y = location_lat, color = trackId)) +
    geom_path() + geom_point(size = 0.5) + theme_bw() + coord_cartesian()

## library(ggmap)
## require(mapproj)
## dDF <- as.data.frame(d)
## m <- get_map(bbox(extent(d)*1.1), source="stamen", zoom=12)
## ggmap(m)+geom_path(data=dDF, aes(x=location.long, y=location.lat))


unstacked <- split(d)

d1 <- getMovebankData(study=study_id, login=log,removeDuplicatedTimestamps=TRUE,animalName=the_names[1],timestamp_start="20210425000000000")

interp500p1 <- interpolateTime(unstacked[[1]], time=500, spaceMethod='greatcircle')
interp500p2 <- interpolateTime(unstacked[[2]], time=500, spaceMethod='greatcircle')
plot(d, col="red",pch=20, main="By number of locations")
points(interp500p)



m <- align_move(d, res = 3, unit = "hours")


frames <- frames_spatial(m,
                         map_service = "osm", map_type = "watercolor", alpha = 0.5,path_size = 3,path_legend = FALSE) %>%
  add_labels(x = "Longitude", y = "Latitude") %>% # add some customizations, such as axis labels
  add_northarrow() %>%
  add_scalebar() %>%
  add_timestamps(m, type = "label") %>%
  add_progress()

##frames[[100]] # preview one of the frames, e.g. the 100th frame

# animate frames
animate_frames(frames, out_file = "output/moveVis_4_curlew_2021-05-11_500.gif",width = 500, height = 500, res = 72)






## Extracting temporal and spatial information of tracks


## Extract time lag between locations. Units should be always stated to be able to interpret the results properly.
tl <- timeLag(d,units = "hours")
## Extract distance between locations. Returned values will be in map units, if the projection is in geographic coordinates (lon/lat) the units will be in meters
td <- distance(d)
## Extract speed between locations. Returned values will be in map units/second, if the projection is in geographic coordinates (lon/lat) the units will be in m/s.
ts <- speed(d))
## Extract heading of trajectory, returning angles in degrees relative to the North pole:
ta <- angle(d)
## Extract turning angles
tta <-turnAngleGc(d)


dd <- dd[,local_identifier_2 := gsub(" |'|\\[|\\]|-",".",local_identifier,perl=TRUE)]

tt <- NULL
for (i in names(tl)) {

ti <- data.frame(i,c(tl[[i]],NA),c(td[[i]],NA),c(ts[[i]],NA),c(ta[[i]],NA),c(NA,tta[[i]],NA))
tt  <-  rbind(tt,ti)
}

colnames(tt) <- c("local_identifier_2","time_lag","distance","speed","angle","turning_angle")
setDT(tt)

tt[,inc_event_local_identifier := 1:.N, by = local_identifier_2]

dd[,inc_event_local_identifier := 1:.N, by = local_identifier_2]

dim(dd)
dim(tt)


dd[,distance := distance / 1000]

dd <- merge(dd,tt,by = c("local_identifier_2","inc_event_local_identifier"))


dd <- dd[timestamp > as.POSIXlt("2021-05-01") & timestamp < as.POSIXlt("2021-06-01"),]
dd[,lat_sup_15 := location_lat > -15]

dd[,index := ifelse(lat_sup_15,inc_event_local_identifier,NA)]

dd[,start_migr := min(index,na.rm = TRUE) -1,by = local_identifier]
dd[,end_migr := max(index,na.rm = TRUE) +1,by = local_identifier]
dd[,migration := inc_event_local_identifier >= start_migr & inc_event_local_identifier <= end_migr]

dd[inc_event_local_identifier >= min(inc_event_local_identifier)-1 &  inc_event_local_identifier <= max(inc_event_local_identifier)+1, migration := TRUE  , by =  local_identifier]

dd_migr <- dd[migration == TRUE,]

gg <- ggplot(data = dd_migr, aes(x=timestamp,y = location_lat, colour =  local_identifier,group = nick_name,shape=location_lat > -15) ) + geom_line() + geom_point()
gg



dd_migr_summary <- dd_migr[,.(distance_km = round(sum(distance,na.rm = TRUE)),
                              time_lag_day = round(sum(time_lag,na.rm=TRUE)/24,1)),
                              by = local_identifier]
