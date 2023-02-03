


#### 2021-06-08 spatial occupency of the tikei's tatler

vecPackage=c("move","lubridate","ggplot2","ggmap","ggspatial","moveVis","data.table","suncalc","ggspatial","HelpersMG","adehabitatHR","rtide","glmmTMB","DHARMa","ggeffects")
ip <- installed.packages()[,1]

for(p in vecPackage){
    if (!(p %in% ip))
        install.packages(pkgs=p,repos = "https://pbil.univ-lyon1.fr/CRAN/",dependencies=TRUE)
    library(p,character.only = TRUE)

}



saveData <- TRUE
get_data <- FALSE
shp_processing <- FALSE
get_tide <- FALSE
make_fig_simple <- FALSE
do_temporal_ditribution <- FALSE
do_get_h_kernel <- FALSE
do_kernel <- FALSE
do_intersect_kernel <- FALSE
do_proximity_moving_windows <- FALSE
do_distance <- FALSE
do_distance_time <- FALSE
do_rmd_script <- FALSE

source("../functions/fun_importation_utf-8.r")
source("../functions/fun_generic.r")
                                        #source("../functions/fun_homerange.r")



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
    dsf <- st_as_sf(dd,coords=c("location_long","location_lat"))
    dsf <- st_set_crs(dsf, 4326)
    st_crs(dsf)
    dsf <- st_transform(dsf,crs=3832)
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

    st_write(tikei_crop, "../GIS/tikei.shp")
} else {
    tikei_crop <- st_read("../GIS/tikei.shp")
}

dsf_ud  <- dsf[,c("bird_id")]
dsf_ud <- st_crop(dsf_ud,st_bbox(tikei_crop))
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


if(do_get_h_kernel) l_kernel <- get_kernel_h(dsf_ud)


if(do_kernel) {
                                        # home range
    if(do_get_h_kernel) l_kernel <- get_kernel_h(dsf_ud) else l_kernel <- readRDS("output/h_kernel.rds")
    bird_h <- l_kernel[[1]]

    library(adehabitatHR)
    ##dsf_ud  <- dsf[,c("bird_id")]
    ##dsf_ud <- st_crop(dsf_ud,st_bbox(tikei_crop))

    ##dsf_ud <- as(dsf_ud,'Spatial')




    shp_file <- "../GIS/tikei_platier.shp"
    habitat <- "reef"
    shp_reef <- st_read(shp_file)
    shp_reef$habitat <- habitat
    shp_reef <- st_transform(shp_reef,crs=3832)

    border <- st_cast(st_crop(shp_reef,st_bbox(tikei_crop)),"MULTILINESTRING")
    plot(border)

    border_sp <- as(border,'Spatial')



    fig <- FALSE


    vec_k <- c(seq(30,90,10),95)
    sf_kernel  <- NULL
    for(i in 1:nrow(bird_h)) {



        b <- bird_h$bird_id[i]
        H <- bird_h$h[i]
        G <- bird_h$grid[i]
        cat("\n  ===  ",b,"  ===\n")
        cat("h:",H,"  grid:",G,"\n")
        dsf_b <- subset(dsf,bird_id == b)

        dsf_ud  <- dsf_b[,c("bird_id")]
        dsf_ud <- st_crop(dsf_ud,st_bbox(tikei_crop))
        dsf_ud <- as(dsf_ud,'Spatial')
        kd <- kernelUD(dsf_ud,h=H, grid=G,extent=10)
        ## image(kd)

                                        # creating SpatialPolygonsDataFrame
        kd_names <- names(kd)


        for(k in vec_k) {
            cat("\nk:",k)

            ud_k <-  try(getverticeshr(kd, k),silent=TRUE)

            if(class(ud_k) != "try-error") {
                sf_kernel_k <- st_as_sf(ud_k)
                sf_kernel_k$k <- k
                sf_kernel_k$bird_id  <- b
                sf_kernel_k$h  <- H
                sf_kernel_k$grid  <- G
                sf_kernel_k$extent  <- 10
                sf_kernel <- rbind(sf_kernel,sf_kernel_k)
                cat("  DONE!")
            }
        }
    }




    st_write(sf_kernel,"../GIS/kernel_tikei_brut.shp",append=TRUE)

    gg <- ggplot() + facet_grid(k~bird_id)
    gg <- gg + geom_sf(data=tikei)
    gg <- gg + geom_sf(data=sf_kernel,aes(fill=k),alpha=0.5)
gg
    ##    intersection des kernels

##  sf_kernel_poly1 <-  st_cast(sf_kernel,"POLYGON")
##
##  gg <- ggplot() + facet_grid(k~bird_id)
##  gg <- gg + geom_sf(data=tikei)
##  gg <- gg + geom_sf(data=sf_kernel_poly1,aes(fill=k),alpha=0.5)
##  gg
##  ggsave("output/tikei_kernek_pb_cast.png")
##

    sf_kernel <- st_cast(st_cast(sf_kernel,"MULTIPOLYGON"),"POLYGON")
    sf_kernel <- st_make_valid(sf_kernel)




    if(fig) {


    tikei <- st_read("../GIS/tikei.shp")

  gg <- ggplot() + facet_grid(k~bird_id)
    gg <- gg + geom_sf(data=tikei)
    gg <- gg + geom_sf(data=sf_kernel,aes(fill=k),alpha=0.5)
gg
      ggsave("output/tikei_kernel_brut_facet.png")


        gg <- ggplot() + facet_wrap(.~bird_id)
        gg <- gg + geom_sf(data=tikei)
        gg <- gg + geom_sf(data=sf_kernel,aes(fill=k),alpha=0.5)
gg
        ggsave("output/tikei_kernel_brut.png",width=14,height=10)


    }




    st_write(sf_kernel,"../GIS/kernel_tikei.shp",append=TRUE)

}


if(do_intersect_kernel) {

    if(!do_kernel) sf_kernel <- st_read("../GIS/kernel_tikei.shp")
sf_kernel <- sf_kernel[!duplicated(sf_kernel),]
    tikei_crop <- st_read("../GIS/tikei_crop.shp")
    tikei <- st_read("../GIS/tikei.shp")




    sf_intersect_kernel <- st_make_valid(st_intersection(sf_kernel,tikei_crop))

    gg <- ggplot() + facet_wrap(bird_id~k)
    gg <- gg + geom_sf(data=tikei)
    gg <- gg + geom_sf(data=subset(sf_kernel,bird_id == "T22_red"),aes(fill=k),alpha=0.5)
    gg <- gg + geom_sf(data=subset(sf_intersect_kernel,habitat %in% c("reef","beach","scrub") & bird_id == "T22_red"),fill="red",alpha=0.2)

    gg

    vec_h <- c("reef","beach","scrub")
    sf_intersect_kernel_border <- subset(sf_intersect_kernel,habitat %in% vec_h)
    sf_intersect_kernel_border$area_m2 <- as.numeric(st_area(sf_intersect_kernel_border))

   gg <- ggplot() + facet_grid(k~bird_id)
    gg <- gg + geom_sf(data=tikei)
    gg <- gg + geom_sf(data=sf_intersect_kernel_border,aes(fill=area_m2),alpha=0.8)
   ##  gg

    #### OK #####
    vec_K <- c(30,40,50,60,70,80,90,95)

    for(K in vec_K) {
        for(H in vec_h) {
        sf_K <- subset(sf_intersect_kernel_border,k==K & habitat == H )
        intersect_K <- st_intersects(sf_K)
        ## print(intersect_K)

        unlist(intersect_K)
        n <- sapply(intersect_K, length)
        unlist(lapply(n, seq_len))
        id <- rep(1:length(intersect_K), times = n)

        t_intersect_K <- data.frame(intersect_K)
         setDT(t_intersect_K)
        t_intersect_K[,id1 := sf_K$id[t_intersect_K[,row.id]]]
        t_intersect_K[,id2 := sf_K$id[t_intersect_K[,col.id]]]
        t_intersect_K <- t_intersect_K[id1 < id2,]
        t_intersect_K[,kernel := K]
        t_intersect_K[,habitat := H]

        nb_intersect_K <- t_intersect_K[,.(nb_intersection = .N),by=id1]
        nb_intersect_K[,kernel := K]
         nb_intersect_K[,habitat := H]



        if(K == vec_K[1] & H == vec_h[1]) t_intersect <- t_intersect_K else t_intersect <- rbind(t_intersect,t_intersect_K)
        if(K == vec_K[1]& H == vec_h[1]) nb_intersect <- nb_intersect_K else nb_intersect <- rbind(nb_intersect,nb_intersect_K)
        }
    }

    t_intersect[,id := paste(id1,id2,sep="_")]
    t_intersect_min <- t_intersect[,.(min_kernel = min(kernel)), by = .(id,id1,id2)]
    setorder(t_intersect_min,id1,id2)


    print(t_intersect_min)

    fwrite(t_intersect,"output/t_intersect.csv")
    fwrite(t_intersect_min,"output/t_intersect_min.csv")
        fwrite(nb_intersect,"output/nb_intersect.csv")

##   vec_id <- unique(sf_kernel$id)
##   tab_id <- expand.grid(id_1 = vec_id, id_2 = vec_id)
##   setDT(tab_id)
##   tab_id[,`:=`(id_1 = as.character(id_1), id_2 = as.character(id_2))]
##   tab_id <- tab_id[id_1 < id_2,]
##
##
##
##   sf_overlap_kernel_border  <- NULL
##
##   for(K in vec_k[1:6]) {
##       cat("\n\n## ",K,"\n")
##       for(H in vec_h) {
##           cat("\n  -",H,"\n")
##           for(i in 1:nrow(tab_id)){
##               cat(i,"")
##               the_id <- c(tab_id[[1]][i],tab_id[[2]][i])
##               sf_k <- subset(sf_intersect_kernel_border,k==K & habitat == H & id %in% the_id)
##               sf_k <- st_cast(st_cast(sf_k,"MULTIPOLYGON"),"POLYGON")
##
##            ##   ggplot() + geom_sf(data=tikei)+ geom_sf(data=sf_k,aes(fill=bird_id),alpha=0.6)
##
##
##               sf_k <- st_make_valid(sf_k)
##               sf_k$area_m2 <- as.numeric(st_area(sf_k))
##
##               sf_k <- subset(sf_k,area_m2 > 500)
##f(nrow(sf_k)> 1){
##               sf_k <- st_set_precision(sf_k,1)
##
##       sf_overlap_kernel_border <- rbind(sf_overlap_kernel_border,st_make_valid(st_intersection(sf_k)))
### ggplot() + geom_sf(data=tikei)+ geom_sf(data=sf_k,aes(fill=bird_id)) + facet_wrap(.~bird_id)
##
##
##           }
##
##       }
##       saveRDS(sf_overlap_kernel_border,"output/overlap_kernel.rds")
##   }
##
##   sf_intersect_kernel <- st_cast(sf_intersect_kernel,"POLYGON")
##   gg <- ggplot() + facet_wrap(.~bird_id)
##   gg <- gg + geom_sf(data=tikei)
##   gg <- gg + geom_sf(data=sf_intersect_kernel,aes(fill=k),alpha=0.5)
##   gg
##
##
##
##   gg <- ggplot() + facet_wrap(.~bird_id)
##   gg <- gg + geom_sf(data=tikei)
##   gg <- gg + geom_sf(data=sf_intersect_kernel,aes(fill=k),alpha=0.5)
##   gg
##
##   setDT(intersect_kernel_50)
##
##   sf_kernel_50$area_m2 <- as.numeric(st_area(sf_kernel_50))
##   kernel_50 <- as.data.frame(sf_kernel_50)
##   setDT(kernel_50)
##   kernel_50[,i := 1:.N]
##   kernel_50 <- kernel_50[,.(i,bird_id)]
##
##   intersect_kernel_50 <- merge(intersect_kernel_50,kernel_50,by.x="row.id",by.y="i")
##   intersect_kernel_50 <- merge(intersect_kernel_50,kernel_50,by.x="col.id",by.y="i")
##
##   intersect_kernel_50 <- intersect_kernel_50[,3:4]
##   colnames(intersect_kernel_50) <- c("bird_id_1","bird_id_2")
##
##   intersect_kernel_50 <- unique(intersect_kernel_50)
##
##   nb_intersect_50 <- intersect_kernel_50[,.(nb_intersect_50 = (.N)-1),by=bird_id_1]
##
##
##   intersect_kernel_90 <- as.data.frame(st_intersects(sf_kernel_90))
##   setDT(intersect_kernel_90)
##
##   sf_kernel_90$area_m2 <- as.numeric(st_area(sf_kernel_90))
##   kernel_90 <- as.data.frame(sf_kernel_90)
##   setDT(kernel_90)
##   kernel_90[,i := 1:.N]
##   kernel_90 <- kernel_90[,.(i,bird_id)]
##
##   intersect_kernel_90 <- merge(intersect_kernel_90,kernel_90,by.x="row.id",by.y="i")
##   intersect_kernel_90 <- merge(intersect_kernel_90,kernel_90,by.x="col.id",by.y="i")
##
##   intersect_kernel_90 <- intersect_kernel_90[,3:4]
##   colnames(intersect_kernel_90) <- c("bird_id_1","bird_id_2")
##
##   intersect_kernel_90 <- unique(intersect_kernel_90)
##
##   nb_intersect_90 <- intersect_kernel_90[,.(nb_intersect_90 = (.N)-1),by=bird_id_1]
##
##   nb_intersect <- merge(nb_intersect_90,nb_intersect_50,by="bird_id_1")
##
##   setnames(nb_intersect,"bird_id_1","bird_id")
##
##   print(nb_intersect)
##   fwrite(nb_intersect,"output/intersect.csv")
##
##
##
##   gg_nb_intersect <- melt(nb_intersect, id.vars = c("bird_id"))
##   gg <- ggplot(gg_nb_intersect, aes(x=variable,y=value)) + geom_violin(draw_quantiles=.5,alpha=0.8,colour=NA)
##   gg <- gg + geom_line(aes(group=bird_id,colour=bird_id),size=2,alpha=.5)+geom_jitter(aes(colour=bird_id),height=0.1,width=0.05)
##   gg <- gg + scale_y_continuous(name="Nombre d'interactions", breaks = seq(0,12,2)) + labs(x="Kernel",colour="") + theme(legend.position="none")
##   gg
##   ggsave("output/intersect_90_50.png",gg)
##
}

if(do_distance) {

    for (i in 1:nrow(t_intersect_min)) {

        id1 <- t_intersect_min[i,id1]
        dd_id1 <- subset(dd,bird_id == id1)
        dd_id1 <- dd_id1[,.(bird_id,local_timestamp,day,X,Y)]
        setnames(dd_id1,colnames(dd_id1),paste0(colnames(dd_id1),"_1"))
          ## 2m
        dd_id1[,start_close := local_timestamp_1 - 120]
        dd_id1[,end_close := local_timestamp_1 + 120]
        ## 2h -> 2j same day/night
        dd_id1[,start_far_1 := local_timestamp_1 - (3600*24*2)]
        dd_id1[,end_far_1 := local_timestamp_1 - 7200]
        dd_id1[,start_far_2 := local_timestamp_1 + 7200]
        dd_id1[,end_far_2 := local_timestamp_1 + (3600*24*2)]

        id2 <- t_intersect_min[i,id2]
        dd_id2 <- subset(dd,bird_id == id2)
        dd_id2 <- dd_id2[,.(bird_id,local_timestamp,day,X,Y)]
         setnames(dd_id2,colnames(dd_id2),paste0(colnames(dd_id2),"_2"))

        d_dist_close <- dd_id1[dd_id2,on=.(start_close <= local_timestamp_2,end_close >= local_timestamp_2 ,day_1 == day_2),.(bird_id_1,bird_id_2,time = abs(as.numeric(difftime(local_timestamp_1,local_timestamp_2,units="hours"))),local_timestamp_1,local_timestamp_2,day_1,day_2,X_1,Y_1,X_2,Y_2)][!is.na(bird_id_1)& bird_id_1 != bird_id_2]
        d_dist_close[,dist := round(sqrt((X_1 - X_2)^2 + (Y_1 - Y_2)^2 ))]

        d_dist_close[,cat_time := "close"]


        d_dist_far_1 <- dd_id1[dd_id2,on=.(start_far_1 <= local_timestamp_2,end_far_1 >= local_timestamp_2 ,day_1 == day_2),.(bird_id_1,bird_id_2,time = abs(as.numeric(difftime(local_timestamp_1,local_timestamp_2,units="hours"))),local_timestamp_1,local_timestamp_2,day_1,day_2,X_1,Y_1,X_2,Y_2)][!is.na(bird_id_1)& bird_id_1 != bird_id_2]
        d_dist_far_2 <- dd_id1[dd_id2,on=.(start_far_2 <= local_timestamp_2,end_far_2 >= local_timestamp_2 ,day_1 == day_2),.(bird_id_1,bird_id_2,time = abs(as.numeric(difftime(local_timestamp_1,local_timestamp_2,units="hours"))),local_timestamp_1,local_timestamp_2,day_1,day_2,X_1,Y_1,X_2,Y_2)][!is.na(bird_id_1)& bird_id_1 != bird_id_2]
        d_dist_far <- rbind(d_dist_far_1,d_dist_far_2)
        d_dist_far[,dist := round(sqrt((X_1 - X_2)^2 + (Y_1 - Y_2)^2 ))]

        d_dist_far[,cat_time := "far"]

        d_dist_i <- rbind(d_dist_close,d_dist_far)

        d_dist_i[,`:=`(id=t_intersect_min[i,id],kernel_min = t_intersect_min[i,min_kernel])]

        if(i == 1) d_dist  <- d_dist_i else d_dist  <-  rbind(d_dist,d_dist_i)

    }
    d_dist <- d_dist[dist<5000,]

    fwrite(d_dist,"output/distance_time_intersect.csv")

    gg <- ggplot(d_dist,aes(x=kernel_min ,y=dist)) + facet_grid(day_1~cat_time)
    gg <- gg + geom_point() + geom_smooth(method = "lm")
    gg
    ggsave("output/distance_time_intersect.png",gg)


    d_dist <- fread("output/distance_time_intersect.csv")
    d_bird <- fread("data/data_JIGUET_2021.csv",encoding="Latin-1",dec=",")
    setnames(d_bird,colnames(d_bird),gsub(" ","_",colnames(d_bird)))
    d_bird <- d_bird[,.(INSCRIPTION_GAUCHE,BAGUE,ESPECE,MA,LOCALITE,MA,LT,LP)]
    setnames(d_bird,"INSCRIPTION_GAUCHE","bird_id")
    d_bird <- d_bird[!is.na(bird_id) & bird_id != "" & !is.null(bird_id) & ESPECE == "TRIINC" & LOCALITE == "TAKAROA", ]
    d_bird[,bird_id := paste(bird_id,"red",sep="_")]
    d_bird <- d_bird[,.(bird_id,MA,LT,LP)]
    d_bird[,`:=`(MA = as.numeric(MA), LT = as.numeric(LT), LP = as.numeric(LP))]


    d_dist[,`:=`(bird_id_1 = substr(id,1,7),bird_id_2 = substr(id,9,15))]
    setnames(d_bird,colnames(d_bird),paste(colnames(d_bird),"1",sep="_"))
    d_dist <- merge(d_dist,d_bird,by="bird_id_1",all.x=TRUE)
    setnames(d_bird,colnames(d_bird),gsub("1","2",colnames(d_bird)))
    d_dist <- merge(d_dist,d_bird,by="bird_id_2",all.x=TRUE)

    d_dist[,date := as.Date(local_timestamp_1)]

    d_dist[,`:=`(diff_MA = abs(MA_1 - MA_2), diff_LT = abs(LT_1 - LT_2), diff_LP = abs(LP_1 - LP_2))]
    d_dist[,`:=`(diff_MA_sc = scale(diff_MA), diff_LT_sc = scale(diff_LT), diff_LP_sc = scale(diff_LP))]


    d_dist_day <- d_dist[,.(nb = .N), by = .(date,cat_time,day_1)]

    gg <- ggplot(data = d_dist_day, aes(x=as.Date(date),y=nb,colour=day_1))
    gg <- gg + geom_point() + geom_line(alpha = .5)
    gg <- gg + labs(x="Date",y = "Number of synchronous pair data (< 2 min)", colour="")
    gg
    ggsave("output/synchronous_data.png",gg)

    hist(d_dist$dist)
    glmm <- glmmTMB(dist ~ kernel_min * cat_time + day_1 + (1|id),data=d_dist,family="nbinom2")
sglmm <- summary(glmm)
print(sglmm)
simulationOutput <- simulateResiduals(fittedModel = glmm, plot = F)
testZeroInflation(simulationOutput)
plot(simulationOutput)

library(ggeffects)
ggpred <- ggpredict(glmm,terms = c("kernel_min","cat_time","day_1"))
print(ggpred)
plot(ggpred)

    glmm <- glmmTMB(dist ~  cat_time * day_1 + (1|id) + (1|kernel_min),data=d_dist,family="nbinom2")
sglmm <- summary(glmm)
print(sglmm)
simulationOutput <- simulateResiduals(fittedModel = glmm, plot = F)
testZeroInflation(simulationOutput)
plot(simulationOutput)

library(ggeffects)
ggpred <- ggpredict(glmm,terms = c("cat_time","day_1"))
print(ggpred)
plot(ggpred)



     glmm <- glmmTMB(dist ~ kernel_min * cat_time + diff_MA * cat_time + diff_LT * cat_time + diff_LP * cat_time + (1|day_1) + (1|id),data=d_dist,family="nbinom2")
sglmm <- summary(glmm)
print(sglmm)
simulationOutput <- simulateResiduals(fittedModel = glmm, plot = F)
testZeroInflation(simulationOutput)
plot(simulationOutput)

library(ggeffects)
ggpred <- ggpredict(glmm,terms = c("kernel_min","cat_time"))
print(ggpred)
plot(ggpred)

    d_dist[,kernel_min_txt := as.character(kernel_min)]




      glmm <- glmmTMB(dist ~ kernel_min_txt * cat_time + day_1 + (1|id),data=d_dist,family="nbinom2")
sglmm <- summary(glmm)
print(sglmm)
simulationOutput <- simulateResiduals(fittedModel = glmm, plot = F)
testZeroInflation(simulationOutput)
plot(simulationOutput)

ggpred <- ggpredict(glmm,terms = c("kernel_min_txt","cat_time","day_1"))
print(ggpred)
plot(ggpred)




     glmm <- glmmTMB(dist ~ kernel_min_txt * cat_time +(1|day_1) + (1|id),data=d_dist,family="nbinom2")
sglmm <- summary(glmm)
print(sglmm)
simulationOutput <- simulateResiduals(fittedModel = glmm, plot = F)
testZeroInflation(simulationOutput)
plot(simulationOutput)

ggpred <- ggpredict(glmm,terms = c("kernel_min_txt","cat_time"))
print(ggpred)
plot(ggpred)


}

if(do_distance_time) {

    nb_intersect <- fread("output/intersect.csv")

    d_dist_1 <- dd[,.(bird_id,local_timestamp,day,X,Y)]
    setnames(d_dist_1,colnames(d_dist_1),paste0(colnames(d_dist_1),"_1"))
    d_dist_1[,start := local_timestamp_1 - 7200]
    d_dist_1[,end := local_timestamp_1 + 7200]


    d_dist_2 <- dd[,.(bird_id,local_timestamp,day,X,Y)]
    setnames(d_dist_2,colnames(d_dist_2),paste0(colnames(d_dist_2),"_2"))


    d_dist <- d_dist_1[d_dist_2,on=.(start <= local_timestamp_2,end >= local_timestamp_2 ),.(bird_id_1,bird_id_2,time = abs(as.numeric(difftime(local_timestamp_1,local_timestamp_2,units="hours"))),local_timestamp_1,local_timestamp_2,day_1,day_2,X_1,Y_1,X_2,Y_2)][!is.na(bird_id_1)& bird_id_1 != bird_id_2]
    d_dist[,dist := round(sqrt((X_1 - X_2)^2 + (Y_1 - Y_2)^2 ))]

    d_dist <- d_dist[dist < 5000,]
    d_dist[,day := ifelse(day_1=="day" & day_2 =="day","day",ifelse(day_1=="night"& day_2 =="night","night","diff"))]


    d_dist[,class_time := ifelse(time < 0.17,"inf_min",ifelse(time > 1,"sup_h","min-h"))]

    intersect_kernel_50[,kernel_50 := TRUE]
    d_dist <- merge(d_dist,intersect_kernel_50,by=c("bird_id_1","bird_id_2"),all.x=TRUE)
    d_dist[is.na(kernel_50),kernel_50 := FALSE]

    intersect_kernel_95[,kernel_95 := TRUE]
    d_dist <- merge(d_dist,intersect_kernel_95,by=c("bird_id_1","bird_id_2"),all.x=TRUE)
    d_dist[is.na(kernel_95),kernel_95 := FALSE]

    d_dist[,kernel := ifelse(kernel_50,"50",ifelse(kernel_95,"95","none"))]
    d_dist[,time_cat := ifelse(time < (15/60),"inf_15min","sup_15min")]
    d_dist[,kernel_cat := ifelse(kernel == 50, "intersect_core_area",ifelse(kernel==95,"intersect_home_range","none"))]
    dim(d_dist)
    head(d_dist)

    d_dist[,time_round := round(time,2)]
    d_dist[,dist_log := dist + 1]
    d_dist[,id := paste0(bird_id_1,"-", bird_id_2)]

    d_dist[,time_fact := as.factor(time_round)]

    d_dist_glm <- d_dist[bird_id_1 < bird_id_2,]



    gg <- ggplot(d_dist_glm[day %in% c("day","night"),],aes(x=time_cat,y=dist_log)) + facet_grid(day~kernel_cat)
    gg <- gg + geom_violin() + scale_y_log10()
    gg
    ggsave("output/dis_violin_jour_nuit_kernel.png")


    gg <- ggplot(d_dist_glm[day %in% c("day","night")& time_cat == "inf_15min" ,],aes(x=time_round,y=dist_log,colour=kernel_cat,group=kernel_cat)) + facet_grid(day~kernel_cat)
    gg <- gg + geom_point(alpha=.5,size=2) + geom_smooth(method="lm")
    gg <- gg +  scale_y_log10()
    gg
    ggsave("output/dis_time_jour_nuit_kernel.png")


    library(glmmTMB)
    md <- glm.nb(dist ~ time_fact + time_fact: kernel  +day + id ,data=d_dist_glm[time_cat == "inf_15min"])
    smd <- summary(md)
    print(smd)

    library(DHARMa)
    testDispersion(md)
    simulationOutput <- simulateResiduals(fittedModel = md, plot = F)
    residuals(simulationOutput)
    plot(simulationOutput)
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





if (do_rmd_script) {

    setwd("c:/git/kivikuaka/analysis/")


####---
####title: "Overlaping territories and interaction in a small wintering population of wandering tattler in French polinesia"
####author: "Romain Lorrilliere"
####date: "`r format(Sys.time(), '%d %B, %Y')`"
####output: pdf_document
####---

####```{r setup, include=FALSE}
####knitr::opts_chunk$set(echo = FALSE, eval=TRUE, warning=FALSE, message=FALSE,comment = FALSE)
####Sys.setlocale("LC_ALL", "English")
####```

                                        # Introduction



                                        # Material and methods


####```{r packages,  include=FALSE}

    vecPackage=c("move","lubridate","ggplot2","ggmap","sf","ggspatial","data.table")#,"moveVis",suncalc","HelpersMG","adehabitatHR","rtide")
    ip <- installed.packages()[,1]

    for(p in vecPackage){
        if (!(p %in% ip))
            install.packages(pkgs=p,repos = "https://pbil.univ-lyon1.fr/CRAN/",dependencies=TRUE)
        library(p,character.only = TRUE)

    }


    saveData <- TRUE
    get_data <- FALSE
    shp_processing <- FALSE
    get_tide <- FALSE
    make_fig_simple <- FALSE
    do_kernel <- FALSE
    do_proximity_moving_windows <- TRUE

    source("../functions/fun_importation_utf-8.r")
    source("../functions/fun_generic.r")
    source("../functions/fun_analysis_tikei.r")
    source("../functions/fun_rmd_generic.r")


    vec_colour <- c("ocean"="#1f78b4","reef"="#a6cee3","beach"="#fdbf6f","scrub"="#b2df8a","forest"="#33a02c")


####```

    ## The study area

####```{r get_tikei_crop, include=FALSE}
    tikei_crop <- f_shp_tikei(shp_processing)

    tikei_beach <- st_union(subset(tikei_crop,habitat %in% c("beach","scrub","forest")))
    tikei_beach_line <- st_cast(tikei_beach,"LINESTRING")
    area_beach <- round(as.numeric(st_area(tikei_beach)/1000000),1)
    perimeter_beach <- round(as.numeric(st_length(tikei_beach_line))/1000,1)



    tikei_reef <- st_union(subset(tikei_crop,habitat %in% c("beach","scrub","forest","reef")))
    tikei_reef_line <- st_cast(tikei_reef,"LINESTRING")
    area_reef <- round(as.numeric(st_area(tikei_reef)/1000000),1)
    perimeter_reef <- round(as.numeric(st_length(tikei_reef_line))/1000,1)


    vec_area_habitat <- round(as.numeric(st_area(tikei_crop)/1000000),1)
    names(vec_area_habitat) <- tikei_crop$habitat


####```

    ## The species

    ## Bird capture


    ## GPS beacons



                                        # Data exploration

    ## Importation


####```{r importation, include=FALSE}
    dd <- f_get_data(get_data,saveData)
    my_kable_print(head(dd),caption="The data")

    dsf <- st_as_sf(dd,coords=c("location_long","location_lat"))
    dsf <- st_set_crs(dsf, 4326)
    st_crs(dsf)
    dsf <- st_transform(dsf,crs=3832)

    dsf <- st_intersection(dsf,tikei_reef)

####```



    ## Exploration

### Spatial distribution of locations of birds

####```{r fig_tikei_tattler}

    gg <- ggplot() + theme_bw()
    gg <- gg + geom_sf(data =tikei_crop,aes(fill=habitat), colour=NA, size=0.2, alpha=.5)
    gg <- gg + coord_sf(xlim = c(7284148,7288089), ylim = c( -1673693, -1671352))

    gg <- gg + geom_sf(data = dsf,aes(group=bird_id,colour= bird_id)) + geom_path(data=dd,aes(x=X,y=Y,group=bird_id,colour= bird_id),alpha=0.5,size=0.8)

    gg <- gg + geom_sf(data = dsf[dsf$day == "day",],colour="white",size=0.5,alpha=.8) + geom_sf(data = dsf[dsf$day == "night",],colour="black",size=0.5,alpha=0.8)
    gg <- gg + scale_fill_manual(values=vec_colour)
    gg <- gg + annotation_scale()
    gg <- gg + labs(x="",y="",colour="birds")
    gg <- gg + coord_sf(xlim = c(7284148,7288089), ylim = c( -1673693, -1671352))

                                        # ggsave("output/tikei_tattler.png",gg,width=10,height=8)


    gg

####```



####```{r fig_tikei_tattler_bird}
    gg <- ggplot() + theme_bw() + facet_wrap(bird_id ~.)
    gg <- gg + geom_sf(data = tikei_crop,aes(fill=habitat), colour=NA, size=0.2, alpha=.5)
    gg <- gg + geom_sf(data = dsf,aes(group=bird_id,colour= bird_id),size=1.2) + geom_path(data=dd,aes(x=X,y=Y,group=bird_id,colour= bird_id),alpha=0.7,size=1)
    gg <- gg + geom_sf(data = dsf[dsf$day=="day",],colour="white",size=0.7,alpha=.8) + geom_sf(data = dsf[dsf$day == "night",],colour="black",size=0.7,alpha=0.8)
    gg <- gg + scale_fill_manual(values=vec_colour)
    gg <- gg + theme(legend.position = "none")
    gg <- gg + labs(x="",y="",colour="birds")
    gg <- gg + coord_sf(xlim = c(7284148,7288089), ylim = c( -1673693, -1671352))
    gg
    ## ggsave("output/tikei_tattler_bird.png",gg)
####```



####```{r bird_habitat}
    dsf_2 <- st_intersection(dsf,tikei_crop)
    setDT(dsf_2)
    t_bird_habitat <- as.data.frame(table(dsf_2[,.(bird_id,habitat)]))
    setDT(t_bird_habitat)

    t_n <- dd[,.(n = .N),by =bird_id]
    t_bird_habitat <- merge(t_bird_habitat,t_n,by="bird_id")
    t_bird_habitat[,bird_id := paste0(bird_id," (",n,")")]

    vec_surf_ha <- data.frame(bird_id = "habitat_ha", habitat = c("forest", "scrub", "beach", "reef"), Freq = c(3.2, 0.3, 0.28, 0.73),n=NA)

    t_bird_habitat <- rbind(t_bird_habitat,vec_surf_ha)

    t_bird_habitat[,tot := sum(Freq),by =bird_id]
    t_bird_habitat[, prop := round(Freq/tot,3)]


    t_bird_habitat[,habitat := factor(habitat,levels = c("forest", "scrub", "beach", "reef", "ocean"))]

                                        # my_kable_print(head(t_bird_habitat),caption="The distribution of location in each habitat")


####```


####```{r gg_bird_habitat}

    gg <- ggplot(data = t_bird_habitat, aes(x=bird_id,y=prop,fill=habitat)) + geom_bar(position= "stack", stat='identity')
    gg <- gg + scale_fill_manual(values=vec_colour) +  coord_flip()
    gg <- gg + labs(x="",y="Proportion")
    gg

####```


### Circadian distribution of locations of birds

####```{r fig_tikei_tattler_day_night}
    gg <- ggplot() + theme_bw() + facet_wrap(day~.,nrow=2)
    gg <- gg + geom_sf(data =tikei_crop,aes(fill=habitat), colour=NA, size=0.2, alpha=.5)
    gg <- gg + geom_sf(data = dsf,aes(group=bird_id,colour= bird_id)) + geom_path(data=dd,aes(x=X,y=Y,group=bird_id,colour= bird_id),alpha=0.5,size=0.8)
    ##gg <- gg + geom_sf(data = dsf[dsf$day,],colour="white",size=0.5,alpha=.8) + geom_sf(data = dsf[dsf$day == FALSE,],colour="black",size=0.5,alpha=0.8)
    gg <- gg + scale_fill_manual(values=vec_colour)
    gg <- gg + theme(legend.position = "none")
    gg <- gg + labs(x="",y="",colour="birds")
    gg <- gg + coord_sf(xlim = c(7284148,7288089), ylim = c( -1673693, -1671352))
    gg
    ## ggsave("output/tikei_tattler_day_night.png",width=8,height=8)
####```

### Temporal data gathering

####```{r limit_time}
    start <- as.Date("2021-02-22")
    end <- as.Date("2021-09-19")
    startPOSIX <- as.POSIXct(start)
    endPOSIX <- as.POSIXct(end)

    duration <- as.numeric(difftime(end,start,units="days"))

####```


####```{r nb_data_week_bird}
    d_week<- dd[,.(count = .N),by = .(bird_id,week,day)]
                                        #head(d_week)

    d_week[,week := as.Date(week)]

    first_date <- min(d_week[,week])
    last_date <- max(d_week[,week])

    ddays <- expand.grid(bird_id = unique(d_week$bird_id),week = seq(first_date, last_date, by="week"),day=c("day","night"),stringsAsFactors=FALSE)


    d_week <- merge(d_week,ddays,by=c("bird_id","week","day"),all=TRUE)
    d_week[is.na(count),count := 0]


    gg <- ggplot(data = d_week, aes(x=as.Date(week), y = count, colour=day, group=day)) + facet_grid(bird_id~.)
    gg  <- gg + geom_line(size = 1.2,alpha=.5) + geom_point(alpha=.5,size=2) + geom_point(data=d_week[count == 0,],colour ="white",alpha=.5,size=1)
    gg <- gg + geom_vline(xintercept = start,colour="blue")
    gg <- gg+ geom_vline(xintercept = end,colour="red")
    gg <-  gg + labs(y="Number of location per week",x="week",colour="")
    gg
    ##ggsave("output/tikei_tattler_nb_data_week.png",gg,width=10,height= 10.5)

####```

####```{r nb_data_week}


    d_sum_week <- d_week[,.(sum = sum(as.numeric(count>0))),by = .(week,day)]


    d_day <- dd[,.(nb=.N),by=.(date,bird_id,day)]
    d_sum_day <- d_day[,.(sum = .N),by = .(date,day)]
    d_sum_day[,date := as.Date(date)]


    first_date <- min(d_sum_day[,date])
    last_date <- max(d_sum_day[,date])

    ddays <- expand.grid(date = seq(first_date, last_date, by="day"),day=c("day","night"),stringsAsFactors=FALSE)


    d_sum_day <- merge(d_sum_day,ddays,by=c("date","day"),all=TRUE)
    d_sum_day[is.na(sum),sum := 0]


    vec_date_hour <- as.POSIXlt(paste0(format(dd[,local_timestamp],"%Y-%m-%d %H"),":00:00"),tz="Pacific/Tahiti")
    vec_date_hour_txt <- as.character(vec_date_hour)
    dd[,local_date_hour := vec_date_hour_txt]
    dd[,local_date_hour := as.POSIXct(local_date_hour,tz="Pacific/Tahiti")]


    d_hour <- dd[,.(nb=.N),by=.(local_date_hour,bird_id,day)]
    d_sum_hour <- d_hour[,.(sum = .N),by = .(local_date_hour,day)]
    d_sum_hour[,local_date_hour := as.POSIXct(local_date_hour,tz="Pacific/Tahiti")]


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
    gg <- gg + geom_vline(xintercept = startPOSIX,colour="blue")
    gg <- gg+ geom_vline(xintercept = endPOSIX,colour="red")
    gg <- gg + geom_hline(yintercept=2,colour="red")

    gg  <- gg + geom_line(size = 0.5,alpha=1) + geom_point(aes( colour=day),alpha=1,size=1)# + geom_point(data=d_sum_hour[sum < 2,],colour ="white",alpha=.5,size=0.5)
    gg <-  gg + labs(y="Number of bird with data",x="Date",colour="")
    gg <- gg + scale_y_continuous(breaks=seq(from = 0,to = 12,by = 2))


    gg

    dd[, valide := local_timestamp > startPOSIX & local_timestamp < endPOSIX]
    dsf$valide <- dsf$local_timestamp > startPOSIX & dsf$local_timestamp < endPOSIX
    dsf2 <- subset(dsf, valide  ==TRUE)

####```


### Temporal distribution of locations of birds


####```{r fig_tikei_tattler_week}
    gg <- ggplot() + theme_bw() + facet_wrap(week~.)
    gg <- gg + geom_sf(data =tikei_crop,aes(fill=habitat), colour=NA, size=0.2, alpha=.5)
    gg <- gg + geom_sf(data = dsf2,aes(group=bird_id,colour= bird_id),size=1.2) + geom_path(data=dd[valide == TRUE,],aes(x=X,y=Y,group=bird_id,colour= bird_id),alpha=0.7,size=1)
    gg <- gg + geom_sf(data = dsf2[dsf2$day=="day",],colour="white",size=0.7,alpha=.8) + geom_sf(data = dsf2[dsf2$day == "night",],colour="black",size=0.7,alpha=0.8)
    gg <- gg + scale_fill_manual(values=vec_colour)
    gg <- gg +theme(legend.position = "none")
    gg <- gg + labs(x="",y="",colour="birds")
    gg <- gg + coord_sf(xlim = c(7284148,7288089), ylim = c( -1673693, -1671352))
    gg
    ##ggsave("output/tikei_tattler_week.png",gg)
####```

### Homerange




####```{r kernel}



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

    kd <- kernelUD(subset(dsf_ud,bird_id == "T06_red"),h=50, grid=500,extent=2)
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

    ud_50 <- lapply(kd, function(x) try(getverticeshr(x, 50)))
                                        # changing each polygons id to the species name for rbind call
    sapply(1:length(ud_50), function(i) {
        row.names(ud_50[[i]]) <<- kd_names[i]
    })
    sdf_poly_50 <- Reduce(rbind, ud_50)
    df_50 <- fortify(sdf_poly_50)
    df_50$bird_id <- df_50$id

    gg <- ggplot()  + theme_bw()
    gg <- gg + geom_sf(data =tikei_crop,aes(fill=habitat), colour=NA, size=0.2, alpha=.5)
    gg <- gg +   geom_polygon(data = df_95, aes(x = long, y = lat, color = bird_id, group = group),size=1.2,fill=NA,alpha = 1)
    gg <- gg +   geom_polygon(data = df_50, aes(x = long, y = lat, color = bird_id, group = group),size=1.2,fill=NA,alpha = 1)
    gg <- gg + geom_sf(data = dsf,aes(group=bird_id,colour= bird_id),size=0.8) #+ geom_path(data=dd,aes(x=X,y=Y,group=bird_id,colour= bird_id),alpha=0.2,size=0.5)
    gg <- gg + annotation_scale()
    gg <- gg + labs(x="",y="",colour="birds",title="Kernel 75% and 95%")
    gg <- gg + coord_sf(xlim = c(7284148,7288089), ylim = c( -1673693, -1671352))
    gg <- gg + scale_fill_manual(values=vec_colour)
    gg

####```



####```{r kernel_bootstrap}

    library(adehabitatHR)
    dsf_ud  <- dsf[,c("bird_id")]
    dsf_ud <- st_crop(dsf_ud,st_bbox(tikei_reef))

    vecBird <- unique(dsf$bird_id)

    b <- vecBird[1]
    dsf_ud_b <- subset(dsf_ud,bird_id == b)

    dsf_ud_b <- as(dsf_ud_b,'Spatial')


    sdf_poly_95_all <- NULL
    df_95_all <- NULL

    for(h in seq(5,50,by=5)) {
        kd <- kernelUD(dsf_ud_b,h=h, grid=min(500,h*100),extent=4)
                                        # image(kd)

                                        # creating SpatialPolygonsDataFrame
        kd_names <- names(kd)
        ud_95 <- lapply(kd, function(x) try(getverticeshr(x, 95)))
                                        # changing each polygons id to the species name for rbind call

        if(class(ud_95[[1]]) != "try-error") {
            sapply(1:length(ud_95), function(i) {
                row.names(ud_95[[i]]) <<- kd_names[i]
            })
            sdf_poly_95 <- Reduce(rbind, ud_95)
            df_95 <- fortify(sdf_poly_95)

            cat(h,length(sdf_poly_95),"\n")
            sdf_poly_95$h <- h
            df_95$h <- h

            if(is.null(sdf_poly_95_all)) sdf_poly_95_all <- sdf_poly_95 else sdf_poly_95_all <- rbind(sdf_poly_95_all,sdf_poly_95)
            if(is.null(df_95_all)) df_95_all <- df_95 else df_95_all <- rbind(df_95_all,df_95)

        }



        dsf_b <- subset(dsf,bird_id == b)
    }


    gg <- ggplot()  + theme_bw()
    gg <- gg + geom_sf(data =tikei_crop, size=0.2, alpha=.5)
    gg <- gg +   geom_polygon(data = subset(df_95_all,h==50), aes(x = long, y = lat, group = group,fill=h),colour=NA,size=.2,alpha = 0.3)
    gg <- gg + geom_sf(data = dsf_b,size=0.8) #+ geom_path(data=dd,aes(x=X,y=Y,group=bird_id,colour= bird_id),alpha=0.2,size=0.5)
    gg <- gg + annotation_scale()
    gg <- gg + labs(x="",y="",colour="h",title="Kernel 95%")
    gg <- gg + coord_sf(xlim = c(7284148,7288089), ylim = c( -1673693, -1671352))
                                        #gg <- gg + scale_fill_manual(values=vec_colour)
    gg
####```




####```{r, fig_kernel1}


    gg <- ggplot()  + theme_bw()
    gg <- gg + geom_sf(data =tikei_crop,aes(fill=habitat), colour=NA, size=0.2, alpha=.5)
    gg <- gg +   geom_polygon(data = df_95, aes(x = long, y = lat, color = bird_id, group = group),size=1.2,fill=NA,alpha = 1)
    gg <- gg +   geom_polygon(data = df_75, aes(x = long, y = lat, color = bird_id, group = group),size=1.2,fill=NA,alpha = 1)
    gg <- gg + geom_sf(data = dsf,aes(group=bird_id,colour= bird_id),size=0.8) #+ geom_path(data=dd,aes(x=X,y=Y,group=bird_id,colour= bird_id),alpha=0.2,size=0.5)
    gg <- gg + annotation_scale()
    gg <- gg + labs(x="",y="",colour="birds",title="Kernel 75% and 95%")
    gg <- gg + coord_sf(xlim = c(7284148,7288089), ylim = c( -1673693, -1671352))
    gg <- gg + scale_fill_manual(values=vec_colour)
    gg
    ggsave("output/tikei_tattler_kernel.png",width=10,height=8)
####```



####```{r, fig_kernel2}



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
####```

####```{r, interaction_kernel1}


    sf_poly_75 <- st_as_sf(sdf_poly_75)
    intersect_75 <- st_intersects(sf_poly_75)
    ## print(intersect_75)

    unlist(intersect_75)
    n <- sapply(intersect_75, length)
    unlist(lapply(n, seq_len))
    id <- rep(1:length(intersect_75), times = n)

    t_intersect_75 <- data.frame(intersect_75)
    colnames(t_intersect_75) <- c("id1","id2")
    setDT(t_intersect_75)

    nb_intersect_75 <- t_intersect_75[,.(nb_intersection = .N),by=id1]
    nb_intersect_75[,kernel := "kernel 75%"]

    t_intersect_75 <- t_intersect_75[id1 < id2,]

    sf_intersect_75 <- st_intersection(sf_poly_75)



    sf_poly_95 <- st_as_sf(sdf_poly_95)
    intersect_95 <- st_intersects(sf_poly_95)

    t_intersect_95 <- data.frame(intersect_95)
    colnames(t_intersect_95) <- c("id1","id2")
    setDT(t_intersect_95)

    nb_intersect_95 <- t_intersect_95[,.(nb_intersection = .N),by=id1]
    nb_intersect_95[,kernel := "kernel 95%"]

    t_intersect_95 <- t_intersect_95[id1 < id2,]
    t_intersect_95[,bird_id1 := rownames(sf_poly_95)[t_intersect_95[,id1]]]
    t_intersect_95[,bird_id2 := rownames(sf_poly_95)[t_intersect_95[,id2]]]

    nb_intersect <- rbind(nb_intersect_75,nb_intersect_95)

    gg <- ggplot(data = nb_intersect, aes(x = nb_intersection)) + facet_grid(kernel~.)
    gg <- gg + geom_histogram()
    gg <- gg + labs(x = "number of interaction for each birds", y="") + scale_x_continuous(breaks = 1:12)
    gg

####```

}
