


#### 2021-06-08 spatial occupency of the tikei's tatler

vecPackage=c("move","lubridate","ggplot2","ggmap","ggspatial","moveVis","data.table","suncalc","ggspatial","HelpersMG","adehabitatHR","rtide")
ip <- installed.packages()[,1]

for(p in vecPackage){
    if (!(p %in% ip))
        install.packages(pkgs=p,repos = "https://pbil.univ-lyon1.fr/CRAN/",dependencies=TRUE)
    library(p,character.only = TRUE)

}



saveData <- TRUE
get_data <- TRUE
shp_processing <- FALSE
get_tide <- FALSE
make_fig_simple <- FALSE
do_kernel <- FALSE
do_proximity_moving_windows <- TRUE

source("../functions/fun_importation.r")
source("../functions/fun_generic.r")


### get location data

## ind <- getMovebankAnimals(study=study_id, login=log)


if(get_data) {

    pw <- readLines("../library/pw.txt")
    username <-"romainlorrilliere"
    log <- movebankLogin(username,pw)
    study_id  <- 1381110575

    ind <- get_birds(con=log)

    setDT(ind)
    head(ind)

    if(saveData) fwrite(ind,"movebank_ind.csv")

    ## tikei's tatler without T18 that seems to have lost his beacon
    code <- paste0("T",sprintf("%02d", c(6:17,19:22)))
    birds <- unique(ind[grep(paste(code,collapse="|"),local_identifier),.(id,nick_name,ring_id,taxon_fr,taxon_eng,bird_id,color,date_start,date_end,nb_day_silence,import_date)])
    birds <- birds[!is.na(date_start),]
   ## head(birds)
    the_names <- birds[,id]

    d <- getMovebankData(study=study_id, login=log,removeDuplicatedTimestamps=TRUE,animalName=the_names,timestamp_start="20210215000000000")

   ## plot(d)
  ##  head(d)
    dd <- setDT(as.data.frame(d))
    col <- c("individual_id","tag_id","sensor_type_id","timestamp","location_accuracy_comments","location_lat","location_long")
     dd <- dd[,col,with=FALSE]
    dd <- merge(dd,birds,by.x="individual_id",by.y="id")


    dd[,timestamp := as.POSIXct(timestamp)]
    dd[,date := as.Date(timestamp)]
    dd[,local_timestamp := with_tz(timestamp,tz="Pacific/Tahiti")]
    dd[,heure := as.numeric(format(local_timestamp,"%H"))]
    dd[,day := ifelse(heure > 6 & heure < 18,"day","night")]
    dd <- dd[!is.na(day),]
    dd[,week := cut(as.POSIXlt(timestamp),breaks ="week",include.lowest=TRUE)]
## head(dd)


    dsf <- st_as_sf(dd,coords=c("location_long","location_lat"))
    dsf <- st_set_crs(dsf, 4326)
    st_crs(dsf)
    dsf <- st_transform(dsf,crs=3832)

    dd <- cbind(dd,st_coordinates(dsf))
    if(saveData) fwrite(dd,"movebank_data_tikei.csv")

} else {

    dd <- fread("movebank_data_tikei.csv")
}


### preparation shp


if(shp_processing) {
    vec_shp <- paste0("../GIS/tikei_",c("ocean","platier","cost","bush","forest"),".shp")
    vec_shp

    vec_habitat <- c("ocean","reef","beach","scrub","forest")


    i <- 1
    shp_file <- vec_shp[i]
    shp <- st_read(shp_file)
    shp$habitat <- vec_habitat[i]
    shp$id <- i
    shp <- shp[,c("id","habitat")]
    shp <- st_transform(shp,crs=3832)

    tikei <- shp

    for(i in 2: 5) {
        ##  i <- 2
        shp_file <- vec_shp[i]
        shp <- st_read(shp_file)
        shp$habitat <- vec_habitat[i]
        shp$id <- i
        shp <- shp[,c("id","habitat")]
        shp <- st_transform(shp,crs=3832)
        shp <- shp[1,]


        tikei_diff <- st_difference(tikei,shp)
        tikei_diff  <- tikei_diff [,c("id","habitat")]
        tikei <- rbind(tikei_diff,shp)


    }

    marge <-100
    bbox_reef <- st_bbox(st_buffer(tikei[2,],marge))

    tikei_crop <- st_crop(tikei,bbox_reef)

    st_write(tikei_crop, "../GIS/tikei_crop.shp")
} else {
    tikei_crop <- st_read("../GIS/tikei_crop.shp")
}


## add tide information

if(get_tide) {
tikei_lon  <-  -144.5465183
tikei_lat <- -14.9505897
tikei_tide <- tide.info(year=2021, longitude=tikei_lon, latitude=tikei_lat)
dim(tikei_tide)


install.packages("http://max2.ese.u-psud.fr/epc/conservation/CRAN/HelpersMG.tar.gz", repos=NULL, type="source")
packageVersion("HelpersMG")
## [1]4.6.4
library(HelpersMG)
tikei_lon  <- (-144.5465183)
tikei_lat <- -14.9505897
Year <- 2021
tikei_tide <- tide.info(year=Year, longitude=tikei_lon, latitude=tikei_lat)
plot(tikei_tide[, "DateTime.local"], tikei_tide[, "Tide.meter"],
     type="l", bty="n", las=1,
     main=tikei_tide[1, "Location"],
     xlab=as.character(Year), ylab="Tide level in meter")

load("../data/tikei_tide.Rdata")


}

##gg <- ggplot(data = dd, aes(x = location_long, y = location_lat, group=bird_id,colour= bird_id)) +
##    geom_point(size = 1.5) + theme_bw() + coord_cartesian() + facet_wrap(.~day,scales="free")
## gg





vec_colour <- c("ocean"="#1f78b4","reef"="#a6cee3","beach"="#fdbf6f","scrub"="#b2df8a","forest"="#33a02c")
                                        #names(vec_colour) <- vec_habitat

if(make_fig_simple) {

gg <- ggplot() + theme_bw()
gg <- gg + geom_sf(data =tikei_crop,aes(fill=habitat), colour=NA, size=0.2, alpha=.5)
gg <- gg + coord_sf(xlim = c(7284148,7288089), ylim = c( -1673693, -1671352))
gg
gg <- gg + geom_sf(data = dsf,aes(group=bird_id,colour= bird_id)) + geom_path(data=dd,aes(x=X,y=Y,group=bird_id,colour= bird_id),alpha=0.5,size=0.8)
gg
gg <- gg + geom_sf(data = dsf[dsf$day == "day",],colour="white",size=0.5,alpha=.8) + geom_sf(data = dsf[dsf$day == "night",],colour="black",size=0.5,alpha=0.8)
gg <- gg + scale_fill_manual(values=vec_colour)
gg <- gg + annotation_scale()
gg <- gg + labs(x="",y="",colour="birds")
gg <- gg + coord_sf(xlim = c(7284148,7288089), ylim = c( -1673693, -1671352))
gg
ggsave("output/tikei_tattler.png",width=10,height=8)


gg <- ggplot() + theme_bw() + facet_wrap(day~.,nrow=2)
gg <- gg + geom_sf(data =tikei_crop,aes(fill=habitat), colour=NA, size=0.2, alpha=.5)
gg <- gg + geom_sf(data = dsf,aes(group=bird_id,colour= bird_id)) + geom_path(data=dd,aes(x=X,y=Y,group=bird_id,colour= bird_id),alpha=0.5,size=0.8)
##gg <- gg + geom_sf(data = dsf[dsf$day,],colour="white",size=0.5,alpha=.8) + geom_sf(data = dsf[dsf$day == FALSE,],colour="black",size=0.5,alpha=0.8)
gg <- gg + scale_fill_manual(values=vec_colour)
gg <- gg + annotation_scale()
gg <- gg + labs(x="",y="",colour="birds")
gg <- gg + coord_sf(xlim = c(7284148,7288089), ylim = c( -1673693, -1671352))
gg
ggsave("output/tikei_tattler_day_night.png",width=8,height=8)



gg <- ggplot() + theme_bw() + facet_wrap(week~.)
gg <- gg + geom_sf(data =tikei_crop,aes(fill=habitat), colour=NA, size=0.2, alpha=.5)
gg <- gg + geom_sf(data = dsf,aes(group=bird_id,colour= bird_id),size=1.2) + geom_path(data=dd,aes(x=X,y=Y,group=bird_id,colour= bird_id),alpha=0.7,size=1)
gg <- gg + geom_sf(data = dsf[dsf$day=="day",],colour="white",size=0.7,alpha=.8) + geom_sf(data = dsf[dsf$day == "night",],colour="black",size=0.7,alpha=0.8)
gg <- gg + scale_fill_manual(values=vec_colour)
## gg <- gg + annotation_scale()
gg <- gg + labs(x="",y="",colour="birds")
gg <- gg + coord_sf(xlim = c(7284148,7288089), ylim = c( -1673693, -1671352))
gg
ggsave("output/tikei_tattler_week.png",gg)




gg <- ggplot() + theme_bw() + facet_wrap(bird_id ~.)
gg <- gg + geom_sf(data = tikei_crop,aes(fill=habitat), colour=NA, size=0.2, alpha=.5)
gg <- gg + geom_sf(data = dsf,aes(group=bird_id,colour= bird_id),size=1.2) + geom_path(data=dd,aes(x=X,y=Y,group=bird_id,colour= bird_id),alpha=0.7,size=1)
gg <- gg + geom_sf(data = dsf[dsf$day=="day",],colour="white",size=0.7,alpha=.8) + geom_sf(data = dsf[dsf$day == "night",],colour="black",size=0.7,alpha=0.8)
gg <- gg + scale_fill_manual(values=vec_colour)
## gg <- gg + annotation_scale()
gg <- gg + labs(x="",y="",colour="birds")
gg <- gg + coord_sf(xlim = c(7284148,7288089), ylim = c( -1673693, -1671352))
gg
ggsave("output/tikei_tattler_bird.png",gg)

}



if(do_temporal_ditribution) {

## distribution temporelle des données par oiseau

birds[,date_start := as.Date(date_start)]

gg <- ggplot(data = birds, aes(x=date_start)) + geom_histogram(binwidth=1)
gg

head(dd)
d_week<- dd[,.(count = .N),by = .(bird_id,week,day)]
head(d_week)

d_week[,week := as.Date(week)]

first_date <- min(d_week[,week])
last_date <- max(d_week[,week])

ddays <- expand.grid(bird_id = unique(d_week$bird_id),week = seq(first_date, last_date, by="week"),day=c("day","night"),stringsAsFactors=FALSE)


d_week <- merge(d_week,ddays,by=c("bird_id","week","day"),all=TRUE)
d_week[is.na(count),count := 0]


gg <- ggplot(data = d_week, aes(x=as.Date(week), y = count, colour=day, group=day)) + facet_grid(bird_id~.)
gg  <- gg + geom_line(size = 1.2,alpha=.5) + geom_point(alpha=.5,size=2) + geom_point(data=d_week[count == 0,],colour ="white",alpha=.5,size=1)
gg <-  gg + labs(y="Nombre de données par semaine",x="Semaine",colour="")
gg
ggsave("output/tikei_tattler_nb_data_week.png",gg,width=10,height= 10.5)


d_sum_week <- d_week[,.(sum = sum(as.numeric(count>0))),by = .(week,day)]

gg <- ggplot(data = d_sum_week, aes(x=as.Date(week), y = sum, colour=day, group=day))
gg  <- gg + geom_line(size = 1.2,alpha=.5) + geom_point(alpha=.5,size=2) + geom_point(data=d_sum_week[sum <2,],colour ="white",alpha=.5,size=1)
gg <-  gg + labs(y="Nombre d'oiseaux conncetés par semaine",x="Semaine",colour="")
gg
ggsave("output/tikei_tattler_nb_data_week.png",gg,width=10,height= 5)


d_day <- dd[,.(nb=.N),by=.(date,bird_id,day)]
d_sum_day <- d_day[,.(sum = .N),by = .(date,day)]
d_sum_day[,date := as.Date(date)]


first_date <- min(d_sum_day[,date])
last_date <- max(d_sum_day[,date])

ddays <- expand.grid(date = seq(first_date, last_date, by="day"),day=c("day","night"),stringsAsFactors=FALSE)


d_sum_day <- merge(d_sum_day,ddays,by=c("date","day"),all=TRUE)
d_sum_day[is.na(sum),sum := 0]



gg <- ggplot(data = d_sum_day, aes(x=as.Date(date), y = sum, colour=day, group=day))
gg  <- gg + geom_line(size = 1.2,alpha=.5) + geom_point(alpha=.5,size=2) + geom_point(data=d_sum_day[sum < 2,],colour ="white",alpha=.5,size=1)
gg <-  gg + labs(y="Nombre d'oiseaux conncetés par jour",x="Date",colour="")
gg
ggsave("output/tikei_tattler_nb_data_day.png",gg,width=10,height= 5)

    vec_date_hour <- as.POSIXlt(paste0(format(dd[,local_timestamp],"%Y-%m-%d %H"),":00:00"),tz="Pacific/Tahiti")
    vec_date_hour_txt <- as.character(vec_date_hour)
    dd[,local_date_hour := vec_date_hour_txt]
    dd[,local_date_hour := as.POSIXct(local_date_hour,tz="Pacific/Tahiti")]


d_hour <- dd[,.(nb=.N),by=.(local_date_hour,bird_id,day)]
d_sum_hour <- d_hour[,.(sum = .N),by = .(local_date_hour,day)]
d_sum_hour[,local_date_hour := as.POSIXct(local_date_hour,tz="Pacific/Tahiti")]
head(d_sum_hour)

gg <- ggplot(data = d_sum_hour, aes(x=local_date_hour, y = sum))
gg  <- gg + geom_line(size = 0.5,alpha=1) + geom_point(aes( colour=day),alpha=1,size=1) + geom_point(data=d_sum_hour[sum < 2,],colour ="white",alpha=.5,size=0.5)
    gg <-  gg + labs(y="Nombre d'oiseaux conncetés par heure",x="Date",colour="")
    gg <- gg + scale_y_continuous(breaks=seq(from = 0,to = 12,by = 2))
gg
ggsave("output/tikei_tattler_nb_data_hour.png",gg,width=10,height= 5)


    d_sum_week[,panel := "week"]
    setnames(d_sum_week,"week","date")
    d_sum_week[,date := as.POSIXct(date,tz="Pacific/Tahiti")]
    d_sum_week[,group := day]

    d_sum_day[,panel := "day"]
      d_sum_day[,date := as.POSIXct(date,tz="Pacific/Tahiti")]
    d_sum_day[,group := day]

    d_sum_hour[,panel := "hour"]
        setnames(d_sum_hour,"local_date_hour","date")
    d_sum_hour[,group := ""]

dd_sum <- rbind(d_sum_week,rbind(d_sum_day,d_sum_hour))

dd_sum[,panel := factor(panel, levels = c("week","day","hour"))]

gg <- ggplot(data = dd_sum, aes(x=date, y = sum,group=group))+facet_grid(panel~.)
gg
gg <- gg + geom_hline(yintercept=2,colour="red")
    gg  <- gg + geom_line(size = 0.5,alpha=1) + geom_point(aes( colour=day),alpha=1,size=1)# + geom_point(data=d_sum_hour[sum < 2,],colour ="white",alpha=.5,size=0.5)
gg

    gg <-  gg + labs(y="Nombre d'oiseaux localisé",x="Date",colour="")
    gg <- gg + scale_y_continuous(breaks=seq(from = 0,to = 12,by = 2))
gg
ggsave("output/tikei_tattler_nb_data_week_day_hour.png",gg,width=16,height= 8)

}





if(do_kernel) {
                                        # home range


library(adehabitatHR)
dsf_ud  <- dsf[,c("bird_id")]
dsf_ud <- st_crop(dsf_ud,st_bbox(tikei_crop))

dsf_ud <- as(dsf_ud,'Spatial')




shp_file <- "../GIS/tikei_platier.shp"
habitat <- "reef"
shp_reef <- st_read(shp_file)
shp_reef$habitat <- habitat
shp_reef <- st_transform(shp_reef,crs=3832)

border <- st_cast(st_crop(shp_reef,st_bbox(tikei_crop)),"MULTILINESTRING")
plot(border)

border_sp <- as(border,'Spatial')


kd <- kernelUD(dsf_ud,h=50, grid=500,extent=2)
image(kd)

                                        # creating SpatialPolygonsDataFrame
kd_names <- names(kd)
ud_95 <- lapply(kd, function(x) try(getverticeshr(x, 95)))
                                        # changing each polygons id to the species name for rbind call
sapply(1:length(ud_95), function(i) {
    row.names(ud_95[[i]]) <<- kd_names[i]
})
sdf_poly_95 <- Reduce(rbind, ud_95)
df_95 <- fortify(sdf_poly_95)
df_95$bird_id <- df_95$id

ud_75 <- lapply(kd, function(x) try(getverticeshr(x, 75)))
                                        # changing each polygons id to the species name for rbind call
sapply(1:length(ud_75), function(i) {
    row.names(ud_75[[i]]) <<- kd_names[i]
})
sdf_poly_75 <- Reduce(rbind, ud_75)
df_75 <- fortify(sdf_poly_75)
df_75$bird_id <- df_75$id

gg <- ggplot()  + theme_bw()
gg <- gg + geom_sf(data =tikei_crop,aes(fill=habitat), colour=NA, size=0.2, alpha=.5)
gg <- gg +   geom_polygon(data = df_95, aes(x = long, y = lat, color = bird_id, group = group),size=1.2,fill=NA,alpha = 1)
gg <- gg +   geom_polygon(data = df_75, aes(x = long, y = lat, color = bird_id, group = group),size=1.2,fill=NA,alpha = 1)
gg <- gg + geom_sf(data = dsf,aes(group=bird_id,colour= bird_id),size=0.8) + geom_path(data=dd,aes(x=X,y=Y,group=bird_id,colour= bird_id),alpha=0.2,size=0.5)
gg <- gg + annotation_scale()
gg <- gg + labs(x="",y="",colour="birds",title="Kernel 75% and 95%")
gg <- gg + coord_sf(xlim = c(7284148,7288089), ylim = c( -1673693, -1671352))
gg <- gg + scale_fill_manual(values=vec_colour)
gg
ggsave("output/tikei_tattler_kernel.png",width=10,height=8)





gg <- ggplot()  + theme_bw() + facet_wrap(~bird_id)
gg <- gg + geom_sf(data =tikei_crop,aes(fill=habitat), colour=NA, size=0.2, alpha=.5)
gg <- gg +   geom_polygon(data = df_95, aes(x = long, y = lat, color = bird_id, group = group),size=1.2,fill=NA,alpha = 1)
gg <- gg +   geom_polygon(data = df_75, aes(x = long, y = lat, color = bird_id, group = group),size=1.2,fill=NA,alpha = 1)
gg <- gg + geom_sf(data = dsf,aes(group=bird_id,colour= bird_id),size=0.8) + geom_path(data=dd,aes(x=X,y=Y,group=bird_id,colour= bird_id),alpha=0.2,size=0.5)
gg <- gg + labs(x="",y="",colour="birds")
gg <- gg + coord_sf(xlim = c(7284148,7288089), ylim = c( -1673693, -1671352))
gg <- gg + scale_fill_manual(values=vec_colour)
gg
ggsave("output/tikei_tattler_bird_kernel.png",gg)


sf_poly_75 <- st_as_sf(sdf_poly_75)
    intersect_75 <- st_intersects(sf_poly_75)
    print(intersect_75)

    unlist(intersect_75)
    n <- sapply(intersect_75, length)
    unlist(lapply(n, seq_len))
    id <- rep(1:length(intersect_75), times = n)


    sf_intersect_75 <- st_intersection(sf_poly_75)





gg <- ggplot()  + theme_bw()
gg <- gg + geom_sf(data =tikei_crop, colour=NA, size=0.2, alpha=.5)
gg <- gg +   geom_sf(data = sf_intersect_75, aes(fill = n.overlaps),size=1.2,colour=NA,alpha = 1)
gg


    sf_poly_95 <- st_as_sf(sdf_poly_95)
    intersect_95 <- st_intersects(sf_poly_95)
    options(digits = 20)
    sf_poly_95 <- st_make_valid(st_buffer(st_set_precision(sf_poly_95,1e10), 0.0000001))
    sf_intersect_95 <- st_intersection(sf_poly_95)


gg <- ggplot()  + theme_bw()
gg <- gg + geom_sf(data =tikei_crop, colour=NA, size=0.2, alpha=.5)
gg <- gg +   geom_sf(data = sf_poly_99, ,size=1.2,colour=NA,alpha = 1)
gg





}







if(do_proximity_moving_windows) {
                                        # home range
    tikei_crop <- st_read("../GIS/tikei_crop.shp")
    library(adehabitatHR)
    dd[,id_data := 1:.N]
    dsf <- st_as_sf(dd,coords=c("location_long","location_lat"))
    dsf <- st_set_crs(dsf, 4326)
    st_crs(dsf)
    dsf <- st_transform(dsf,crs=3832)

    dsf <- st_crop(dsf,st_bbox(tikei_crop))
    dsf <- st_intersection(dsf,tikei_crop)

    dd <- as.data.frame(dsf)
    setDT(dd)
    dd[,location_long:= location_long.1]
    dd[,location_lat:= location_lat.1]


    first_date <- min(dsf$date)+4
    last_date <- max(dsf$date)

    vec_date = format(seq(first_date, last_date, by="day"))

dd_centroid_dist  <- NULL
    for (theDay in vec_date) {
                                        # theDay <- vec_date[1]
       ## cat(theDay,"\n")
        theDay <- as.Date(theDay)
        mw_first  <- theDay - 3
        mw_last <- theDay + 3
        dsf$date <- as.Date(dsf$date)

        dd_d <- dd[date >= mw_first & date <= mw_last,]
        dd_d_centroid <- dd_d[,.(location_long = mean (location_long), location_lat  = mean (location_lat)),by = bird_id]

        dsf_d_centroid <- st_as_sf(dd_d_centroid,coords=c("location_long","location_lat"))
        dsf_d_centroid <- st_set_crs(dsf_d_centroid, 4326)
        st_crs(dsf_d_centroid)

        dist_d_centroid <- as.numeric(st_distance(dsf_d_centroid))

        vec_d_bird_id <- dsf_d_centroid$bird_id

        dd_d_centroid_dist <- data.frame(date=theDay, bird_id_1 = rep(vec_d_bird_id,length(vec_d_bird_id ) ), bird_id_2 = rep(vec_d_bird_id,each = length(vec_d_bird_id ) ),distance_centroid_7_days = dist_d_centroid)

        dd_centroid_dist  <- rbind(dd_centroid_dist,dd_d_centroid_dist)

    }

    dd_centroid_dist$date <- as.Date(dd_centroid_dist$date)

 setDT(dd_centroid_dist)
    dd_centroid_dist[,bird_ids := apply(dd_centroid_dist[,.(bird_id_1,bird_id_2)],1,FUN = function(x) paste(sort(x), collapse=" "))]

    dd_centroid_dist[, id_date := paste(format(date),bird_ids)]
     dd_centroid_dist <- unique(dd_centroid_dist, by="id_date")

    setkey(dd_centroid_dist,id_date)

  vec_date_hour <- as.POSIXlt(paste0(format(dd[,local_timestamp],"%Y-%m-%d %H"),":00:00"),tz="Pacific/Tahiti")
    vec_date_hour_txt <- as.character(vec_date_hour)
    dd[,local_date_hour := vec_date_hour_txt]
    dd[,local_date_hour := as.POSIXct(local_date_hour,tz="Pacific/Tahiti")]

    d_hour <- dd[,.(nb=.N),by=.(local_date_hour,bird_id,day)]
    d_sum_hour <- d_hour[,.(sum = .N),by = .(local_date_hour,day)]
    d_sum_hour[,local_date_hour := as.POSIXct(local_date_hour,tz="Pacific/Tahiti")]
    head(d_sum_hour)

    vec_date_hour <- format(unique(d_sum_hour[sum>1,local_date_hour]))

    dd_dist <- NULL
    for(dh in vec_date_hour) {
               dh <- as.POSIXct(dh,tz="Pacific/Tahiti")
        dd_dh <- dd[local_date_hour == dh,]
        dd_dh_centroid <- dd_dh[,.(location_long = mean (location_long), location_lat  = mean (location_lat)),by = .(bird_id,habitat)]

        dsf_dh_centroid <- st_as_sf(dd_dh_centroid,coords=c("location_long","location_lat"))
        dsf_dh_centroid <- st_set_crs(dsf_dh_centroid, 4326)
        st_crs(dsf_dh_centroid)

        dist_dh_centroid <- as.numeric(st_distance(dsf_dh_centroid))

        vec_dh_bird_id <- dsf_dh_centroid$bird_id
        vec_dh_habitat <- dsf_dh_centroid$habitat

        dd_dh_dist <- data.frame(local_date_hour=dh, bird_id_1 = rep(vec_dh_bird_id,length(vec_dh_bird_id ) ), habitat_bird_id_1 = rep(vec_dh_habitat,length(vec_dh_habitat ) ),bird_id_2 = rep(vec_dh_bird_id,each = length(vec_dh_bird_id ) ), habitat_bird_id_2 = rep(vec_dh_habitat,each = length(vec_dh_habitat )) ,distance = dist_dh_centroid)

        dd_dist  <- rbind(dd_dist,dd_dh_dist)

        ## platier


    }

    setDT(dd_dist)

    dd_dist <- dd_dist[bird_id_1 != bird_id_2,]

    dd_dist[,bird_ids := apply(dd_dist[,.(bird_id_1,bird_id_2)],1,FUN = function(x) paste(sort(x), collapse=" "))]
    dd_dist[, id_date_hour := paste(format(local_date_hour),bird_ids)]

    dd_dist[,habitats := apply(dd_dist[,.( habitat_bird_id_1,habitat_bird_id_2)],1,FUN = function(x) paste(sort(x), collapse=" "))]

    dd_dist[,habitats_2 := ifelse(habitat_bird_id_1 == habitat_bird_id_2,habitat_bird_id_1," diff")]

    dd_dist <- unique(dd_dist, by="id_date_hour")

    dd_dist[,date := as.Date(local_date_hour)]
    dd_dist[, id_date := paste(format(date),bird_ids)]
    setkey(dd_dist,id_date)


    dd_dist_summary <- dd_dist[,.(nb = .N , min_distance = min(distance), med_distance = median(distance), max_distance=max(distance)),by = .(id_date_hour)]

    head(dd_dist_summary)

    dd_dist_2 <- merge(dd_dist,dd_centroid_dist[,.(id_date,distance_centroid_7_days)])

    dd_dist_2[,`:=`(bird_first = pmin(bird_id_1,bird_id_2), bird_last = pmax(bird_id_1,bird_id_2))]


    gg_d_dist  <-  dd_dist[,.(id_date,local_date_hour,bird_ids,bird_id_1,bird_id_2,distance)]
    gg_d_dist[,group := "synchronous location"]

    gg_d_dist_centroid <- dd_centroid_dist[,.(id_date,date,bird_ids,bird_id_1,bird_id_2,distance_centroid_7_days)]
    gg_d_dist_centroid <- gg_d_dist_centroid[ id_date %in% gg_d_dist$id_date,]
    setnames(gg_d_dist_centroid,c("date","distance_centroid_7_days"),c("local_date_hour","distance"))


    gg_d_dist_centroid[,local_date_hour := as.POSIXct(paste0(format(local_date_hour)," 00:00:00"),tz="Pacific/Tahiti")]
    gg_d_dist_centroid[,group := "7 days centroid"]

    gg_d_dist <- rbind(gg_d_dist, gg_d_dist_centroid)

    gg <- ggplot(data = gg_d_dist,aes(x=local_date_hour,y=distance, colour=group, group=group))+ facet_wrap(.~bird_ids, scales = "free")
    gg <- gg + geom_line()
    gg



    dd_dist_2[,distance_scale := scale(distance)]
    dd_dist_2[,distance_centroid_7_days_scale := scale(distance_centroid_7_days)]
    dd_dist_2[,time_scale := scale(as.numeric(as.POSIXct(local_date_hour)))]

    dd_dist_2 <- dd_dist_2[habitat_bird_id_1 != "ocean" & habitat_bird_id_2 != "ocean",]

    library(glmmTMB)

  mdTMB <- glmmTMB(distance_scale ~ distance_centroid_7_days_scale * habitats_2 + time_scale + (1|bird_ids),data = dd_dist_2)
library(DHARMa)
    testDispersion(mdTMB)
simulationOutput <- simulateResiduals(fittedModel = mdTMB)
plot(simulationOutput,quantreg = T)

    smdTMB <- summary(mdTMB)
    print(smdTMB)
    coefTMB <- as.data.frame(smdTMB$coefficients$cond)
    names(coefTMB) <- c("estimate","sd","z_value","p_value")
    coefTMB$var <- rownames(coefTMB)


    setDT(coefTMB)

    coefTMB[,signif := p_value < 0.005]

    coefTMB[,sd_min := estimate - sd/2]
    coefTMB[,sd_max := estimate + sd/2]
    print(coefTMB)




    gg <- ggplot(data = coefTMB,aes(x=var,y=estimate,shape=signif)) + geom_hline(yintercept=0) + geom_point() + geom_errorbar(aes(ymin=sd_min,ymax=sd_max),width=0)
    gg  <-  gg +coord_flip()
    gg
ggsave("output/coefTMB.png",gg)


    md <- glm(distance_scale ~ distance_centroid_7_days_scale * habitats_2 + time_scale + bird_ids,data = dd_dist_2)
    smd <- summary(md)
    print(smd)

}




tikei_area  <-  data.table(habitat = tikei_crop$habitat, area = st_area(tikei_crop))
tikei_area[,area_km2 := round(as.numeric(area) / (1000*1000),2)]
tikei_area

area_tot <- sum(tikei_area[2:5,area_km2])
area_tot

tikei_area[2:5,.(habitat,area_km2)]
