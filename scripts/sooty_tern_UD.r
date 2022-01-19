
#### 2021-06-08 spatial occupency of the tikei's tatler

vecPackage=c("move","lubridate","ggplot2","ggmap","moveVis","data.table","suncalc","ggspatial","HelpersMG","adehabitatHR","sf","sp")
ip <- installed.packages()[,1]

for(p in vecPackage){
    if (!(p %in% ip))
        install.packages(pkgs=p,repos = "https://pbil.univ-lyon1.fr/CRAN/",dependencies=TRUE)
    library(p,character.only = TRUE)

}




rep = "C:/git/Kivikuaka/"
file_ind_raw =  "data/data_kivikuaka_ind.csv"
path_file_ind_raw <- paste0(rep,file_ind_raw)

ind <- fread(path_file_ind_raw)
ind_taxon <- ind[,.(id,bird_id,taxon,taxon_fr,taxon_eng,nick_name)]
setnames(ind_taxon,"id","individual_id")

code <- paste0("S",sprintf("%02d", c(1:12)))
birds <- unique(ind[grep(paste(code,collapse="|"),local_identifier),.(id,nick_name,ring_id,taxon_fr,taxon_eng,bird_id,color,date_start,date_end,nb_day_silence,import_date)])
birds <- birds[!is.na(date_start),]
head(birds)
the_names <- birds[,id]

pw <-"crexCREX44!"
username <-"romainlorrilliere"
log <- movebankLogin(username,pw)
study_id  <- 1381110575


d <- getMovebankData(study=study_id, login=log,removeDuplicatedTimestamps=TRUE,animalName=the_names,timestamp_start="20210215000000000")

plot(d)
head(d)

dd <- setDT(as.data.frame(d))



dd[,timestamp := as.POSIXlt(timestamp)]
dd[,local_timestamp := with_tz(timestamp,tz="Pacific/Tahiti")]
dd[,heure := as.numeric(format(local_timestamp,"%H"))]
dd[,day := ifelse(heure > 6 & heure < 18,"day","night")]
dd <- dd[!is.na(day),]
dd[,week := cut(as.POSIXlt(timestamp),breaks ="week",include.lowest=TRUE)]

dd <- merge(dd,birds,by.x="individual_id",by.y="id")
 head(dd)

fwrite(dd,"data/sooty_tern.csv")


dsf <- st_as_sf(dd,coords=c("location_long","location_lat"))
dsf <- st_set_crs(dsf, 4326)
st_crs(dsf)
dsf <- st_transform(dsf,crs=3832)

st_write(dsf,"data/sooty_tern.shp")



dd <- cbind(dd,st_coordinates(dsf))

head(dd)

fwrite(dd,"data/sooty_tern.csv")


dd_light <- dd[,.(individual_id,bird_id,tag_id,event_id,timestamp,location_lat,location_long)]
fwrite(dd_light,"data/sooty_tern_light.csv")

Xmin <- min(dd$X)
Xmax <- max(dd$X)
Ymin <- min(dd$Y)
Ymax <- max(dd$Y)



cost <- st_read("../GIS/pacific_cost.shp")
cost <- st_transform(cost,crs=3832)



mark <- st_read("../GIS/geographical_marker.shp")
mark <- st_transform(mark,crs=3832)





library(adehabitatHR)

dsf_ud  <- dsf[,c("bird_id")]
dsf_ud <- as(dsf_ud,'Spatial')





kd <- kernelUD(dsf_ud,h="LSCV",same4all=TRUE,grid=10)
image(kd)

# creating SpatialPolygonsDataFrame
kd_names <- names(kd)
ud_99 <- lapply(kd, function(x) try(getverticeshr(x, 99)))
# changing each polygons id to the species name for rbind call
sapply(1:length(ud_99), function(i) {
  row.names(ud_99[[i]]) <<- kd_names[i]
})
sdf_poly_99 <- Reduce(rbind, ud_99)
df_99 <- fortify(sdf_poly_99)
df_99$bird_id <- df_99$id

ud_75 <- lapply(kd, function(x) try(getverticeshr(x, 75)))
# changing each polygons id to the species name for rbind call
sapply(1:length(ud_75), function(i) {
  row.names(ud_75[[i]]) <<- kd_names[i]
})
sdf_poly_75 <- Reduce(rbind, ud_75)
df_75 <- fortify(sdf_poly_75)
df_75$bird_id <- df_75$id












gg <- ggplot() + theme_bw()
#gg <- gg + geom_sf(data =tikei_crop,aes(fill=habitat), colour=NA, size=0.2, alpha=.5)
#gg <- gg + coord_sf(xlim = c(7284148,7288089), ylim = c( -1673693, -1671352))
gg <- gg + geom_sf(data=cost) + geom_sf(data = mark,colour = "black",size=0.8)#+ geom_sf_label(data=mark,aes(label=name))
gg <- gg + geom_sf(data = dsf,aes(group=bird_id,colour= bird_id)) + geom_path(data=dd,aes(x=X,y=Y,group=bird_id,colour= bird_id),alpha=0.5,size=0.8)
gg <- gg + geom_sf(data = mark,colour = "red",size=1)
gg <- gg + coord_sf(xlim = c(Xmin,Xmax), ylim = c( Ymin, Ymax))
gg <- gg + annotation_scale()
gg <- gg + labs(x="",y="",colour="birds")
gg
ggsave("output/tekokota_tern.png",gg,width=10,height=8)


gg <- ggplot() + theme_bw() + facet_wrap(.~bird_id)
#gg <- gg + geom_sf(data =tikei_crop,aes(fill=habitat), colour=NA, size=0.2, alpha=.5)
#gg <- gg + coord_sf(xlim = c(7284148,7288089), ylim = c( -1673693, -1671352))
gg <- gg + geom_sf(data=cost) + geom_sf(data = mark,colour = "black",size=0.8)#+ geom_sf_label(data=mark,aes(label=name))
gg <- gg + geom_sf(data = dsf,aes(group=bird_id,colour= bird_id)) + geom_path(data=dd,aes(x=X,y=Y,group=bird_id,colour= bird_id),alpha=0.5,size=0.8)
gg <- gg + geom_sf(data = mark,colour = "red",size=1)
gg <- gg + coord_sf(xlim = c(Xmin,Xmax), ylim = c( Ymin, Ymax))
gg <- gg + annotation_scale()
gg <- gg + labs(x="",y="",colour="birds")
gg
ggsave("output/tekokota_tern_birds.png",gg,width=10,height=8)






## Extract time lag between locations. Units should be always stated to be able to interpret the results properly.
tl <- timeLag(d,units = "hours")
## Extract distance between locations. Returned values will be in map units, if the projection is in geographic coordinates (lon/lat) the units will be in meters
td <- distance(d)
## Extract speed between locations. Returned values will be in map units/second, if the projection is in geographic coordinates (lon/lat) the units will be in m/s.
ts <- speed(d)
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
dd <- merge(dd,tt,by =
dd[,distance := distance / 1000]
dd_migr_summary <- dd[,.(distance_km = round(sum(distance,na.rm = TRUE)),
                              time_lag_day = round(sum(time_lag,na.rm=TRUE)/24)),
                              by = local_identifier]
dd_migr_summary
