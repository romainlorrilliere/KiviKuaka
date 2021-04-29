vecPackage=c("lubridate","data.table","move","ggplot2","sf","maps")
ip <- installed.packages()[,1]

for(p in vecPackage){
    if (!(p %in% ip))
        install.packages(pkgs=p,repos = "https://pbil.univ-lyon1.fr/CRAN/",dependencies=TRUE)
    library(p,character.only = TRUE)

}


get_pw <- function(file)
    readLines(file)



get_birds <- function(con,id_prog=1381110575,rep = "C:/git/Kivikuaka/",
                      file_ind_raw = "C:/git/Kivikuaka/data/data_kivikuaka_ind.csv",
                      file_taxon = "C:/git/Kivikuaka/data/taxon.csv"){


    ind <- move::getMovebank("individual",login= con,study_id=id_prog)
    setDT(ind)

    ind[,taxon := taxon_canonical_name]
    d_tax <- fread(file_taxon)
    ind <- merge(ind,d_tax,by="taxon")

    ind[,bird_id := local_identifier]
    for(i in 1:nrow(ind)) {
        ind[i,bird_id := gsub(ind[i,nick_name],"",ind[i,bird_id])]
        ind[i,bird_id := gsub(ind[i,taxon_fr],"",ind[i,bird_id])]
    }
    ##    ind[,color := NA]
    ind[grep("FRP",ring_id),color := "red"]
    ind[,bird_id := paste0(substr(gsub(" ","",bird_id),1,3),"_",color)]

    ind[timestamp_start == "",timestamp_start := NA]
    ind[timestamp_end == "",timestamp_end := NA]
    ind[,date_start := format(as.POSIXlt(timestamp_start),"%Y-%m-%d")]
    ind[,date_end := format(as.POSIXlt(timestamp_end),"%Y-%m-%d")]
    ind[,nb_day_silence :=  round(as.numeric(difftime(Sys.time(), as.POSIXlt(timestamp_end), units = "days")))]

    path_file_ind_raw  <- paste0(rep,file_ind_raw)
    if(gsub("data/","",file_ind_raw) %in% dir(paste0(rep,"data/"))) {
        last_ind <- fread(file_ind_raw)
        last_ind <- last_ind[,.(id,import_date)]
        d[last_ind, on ="id", import_date := import_date]
        ind[,new := !(id %in% last_ind$id)]
        ind[new == TRUE,import_date := as.Date(Sys.time())]

    } else {
        ind[,new := TRUE]
        ind[,import_date := as.Date(Sys.time())]
    }


    fwrite(ind,file_ind_raw)
    return(ind)
}


get_events <- function(con,id_prog=1381110575,rep = "C:/git/Kivikuaka/",
                       file_events_raw = "data/data_kivikuaka_events.csv",
                       file_ind_raw =  "data/data_kivikuaka_ind.csv",
                       id_previous_import = NULL){


    path_file_ind_raw <- paste0(rep,file_ind_raw)

    ind <- fread(path_file_ind_raw)
    ind_taxon <- ind[,.(id,bird_id,taxon,taxon_fr,taxon_eng,nick_name)]
    setnames(ind_taxon,"id","individual_id")

    today <- format(as.Date(Sys.time()))

    path_file_events_raw  <- paste0(rep,file_events_raw)

    if(!is.null(id_previous_import)) {
        path_previous_file <- paste0(rep,file_path_sans_ext(file_events_raw),"_last_",id_previous_import,".csv")
        file.copy(path_previous_file,path_file_events_raw,overwrite=TRUE)
    }




    d <- move::getMovebank("event",login= con,study_id=id_prog)
    setDT(d)

    d <- merge(d,ind_taxon)
    d[,event_id := paste0(individual_id,"_",format(as.POSIXlt(timestamp),"%Y%m%d%H%M%S"))]


    if(gsub("data/","",file_events_raw) %in% dir(paste0(rep,"data/"))) {

        lastEvents <- fread(path_file_events_raw)
        lastEvents <- lastEvents[,.(event_id,import_date)]

        d[lastEvents, on ="event_id", import_date := import_date]
        d[,new:= !(event_id %in% lastEvents$event_id)]
        d[,import_date := as.character(import_date)]

        d[new == TRUE,import_date := today]

    } else {
        d[,new:=TRUE]
        d[,import_date := today]

    }

    d[,date := format(as.POSIXlt(timestamp),"%Y-%m-%d")]
    d[,hour_trunc := as.numeric(format(as.POSIXlt(timestamp),"%H"))]

    d[,hour_float := round(hour_trunc + as.numeric(format(as.POSIXlt(timestamp),"%m"))/60,2)]
    d[,julian := as.numeric(format(as.POSIXlt(timestamp),"%j"))]
    d[,db_date := Sys.time()]

    setcolorder(d,c("event_id","individual_id","bird_id","nick_name","taxon","timestamp","location_lat","location_long","tag_id","taxon_fr","taxon_eng","date","julian","hour_trunc","hour_float","import_date","new","db_date"))


    fwrite(d,path_file_events_raw)

    return(d)
}




summary_new_ind <- function(ind) {

    t_birds <- ind[number_of_events > 0,list(nb_birds = .N),by=list(taxon_eng)]
    t_birds_5days <- ind[nb_day_silence <= 5 ,list(nb_birds_5days = .N),by=list(taxon_eng)]
    t_birds_10days <- ind[nb_day_silence <= 10 ,list(nb_birds_10days = .N),by=list(taxon_eng)]
    t_birds_15days <- ind[nb_day_silence <= 15 ,list(nb_birds_15days = .N),by=list(taxon_eng)]


    t_sum  <- unique(ind[,.(taxon_eng,taxon_fr)])
    t_sum[t_birds,on = "taxon_eng", nb_birds := nb_birds]
    t_sum[t_birds_5days,on = "taxon_eng", nb_birds_5days := nb_birds_5days]
    t_sum[,prop_5days := round(nb_birds_5days/nb_birds,2)]
    t_sum[t_birds_10days,on = "taxon_eng", nb_birds_10days := nb_birds_10days]
    t_sum[,prop_10days := round(nb_birds_10days/nb_birds,2)]
    t_sum[t_birds_15days,on = "taxon_eng", nb_birds_15days := nb_birds_15days]
    t_sum[,prop_15days := round(nb_birds_15days/nb_birds,2)]


    return(t_sum)
}



ggplot_silence <- function(ind) {

    gg <- ggplot(ind,aes(x="",y=nb_day_silence,group=taxon_eng,fill=taxon_eng,colour=taxon_eng)) + geom_violin() + facet_grid(taxon_eng~.,scales="free_y")
    gg <- gg + labs(x="",y="Number of days without data since the last location",fill="")+theme(legend.position="none")
    gg

}







summary_new_events <- function(d) {

    dd <- as.data.frame(table(d[!(is.na(location_lat))& new==TRUE,bird_id]))
    if(nrow(dd)>0) {
        setDT(dd)
        colnames(dd) <- c("bird_id","nb_new_events")

        d_last <- d[!(is.na(location_lat)),list(date = as.Date(max(date))),by = list(bird_id)]
        dd[d_last,on="bird_id",last_date := date]
        setorder(dd, bird_id)
    } else {
        dd <- NULL
    }

    return(dd)

}




data_by_day <- function(d,ind,vec_tax=c("Numenius tahitiensis","Onychoprion fuscatus","Pluvialis fulva","Tringa incana"),nb_last_day=30,point_size=2,last_update_date=NULL) {

    ind_taxon <- ind[,.(id,bird_id,taxon,taxon_fr,taxon_eng,nick_name)]
    setnames(ind_taxon,"id","individual_id")

    d[,hms := as.POSIXct(format(as.POSIXlt(timestamp),"%H:%M:%S"), format = "%H:%M:%S")]


    d[,nb_data_by_day := .N,by = list(julian,bird_id)]

    d_nbLocByDay <- d[!(is.na(location_lat)),list(nb_loc_by_day = .N),by = list(julian,bird_id)]
    d <- merge(d,d_nbLocByDay,by = c("bird_id","julian"),all.x=TRUE)

    d[,prop_loc_by_day := ifelse(is.na(nb_loc_by_day),0,nb_loc_by_day) / nb_data_by_day]



    d_first <- d[!(is.na(location_lat)),list(date = as.Date(min(date))),by = list(bird_id)]
    d_first[,`:=` (date_short = format(date,"%d-%b"),julian =as.numeric(format(date,"%j"))-2) ]
    d_first <- merge(ind_taxon,d_first,by="bird_id")


    d_last <- d[!(is.na(location_lat)),list(date = as.Date(max(date))),by = list(bird_id)]
    d_last[,`:=` (date_short = format(date,"%d-%b"),julian =as.numeric(format(date,"%j"))+2) ]
    d_last <-merge(ind_taxon,d_last,by="bird_id")


    vec_date <- as.Date(paste0(rep("2021",24),"-",rep(1:12,each=2),"-",rep(c(1,15),12)),"%Y-%m-%d")
    t_date <- data.table(date = vec_date, date_short=format(vec_date,"%d-%b"),julian = as.numeric(format(vec_date,"%j")))

    t_date_gg <- t_date[julian >= min(d$julian) & julian <= max(d$julian),]

    julian_export <- as.numeric(format(Sys.time(),"%j"))
    date_export <- as.Date(Sys.time())



    if(nb_last_day >= 0) {

        julian_first  <- as.numeric(format(Sys.time(),"%j")) - nb_last_day
        julian_today <- as.numeric(format(Sys.time(),"%j"))

        date_first  <- as.Date(Sys.time()) - nb_last_day
        date_today <- as.Date(Sys.time())

        setnames(d_first,c("julian","date"),c("julian_date","bird_date_first"))
        d_first[,julian := ifelse(julian_date < julian_first, julian_first,julian)]
        d_first[,date := as.Date(as.character(julian),"%j")]


        setnames(d_last,c("date"),c("bird_last_first"))
        d_last[,date := as.Date(as.character(julian),"%j")]
        d_last <- d_last[julian > julian_first,]
        d_first <- d_first[bird_id %in% d_last[,bird_id]]
        d <- d[bird_id %in% d_last[,bird_id]]

    }

    vec_tax <- vec_tax[vec_tax %in% d[,taxon]]


    vec_hour <- as.POSIXct(format(as.POSIXlt(paste(as.Date(Sys.time()),c("06:00:00","12:00:00","18:00:00"))),"%H:%M:%S"), format = "%H:%M:%S")

    Sys.setlocale("LC_TIME", "English")

    for(tax in vec_tax) {

        ## cat("\n",tax,":\n")

        dgg  <-  d[taxon == tax & !(is.na(location_lat)),]
        dgg[,date := as.Date(date)]
        gg <- ggplot(data = dgg,aes(x=date,y=hms,colour=nb_loc_by_day)) + facet_grid(bird_id~.)
        if(! is.null(last_update_date)) {
            gg <- gg + geom_rect(xmin=as.Date(last_update_date), xmax=date_export, ymin=-Inf, ymax=Inf, fill="white", alpha=0.05,colour=NA)
        }
        gg <- gg + geom_vline(xintercept= date_export,colour="white",size=1.5)
        gg <- gg + geom_vline(xintercept= date_export,colour="darkgray",size=.5)
        gg <- gg + geom_text(data=d_first[taxon == tax,],aes(label=date_short),y=vec_hour[2],colour="black",size=3)
        gg <- gg + geom_text(data=d_last[taxon == tax,],aes(label=date_short),y=vec_hour[2],colour="black",size=3)
        gg <- gg  + geom_line(colour="black")+ geom_point(size=point_size)
        gg <- gg + geom_point(data = dgg[new == TRUE,],colour ="white",size = .3 * point_size)
        gg <- gg + labs(title = tax,y="Time of day", x="Date",colour="Number\nof loc\nper day" )
        gg <- gg +  theme(panel.grid.minor=element_blank(),panel.grid.minor.y=element_blank())
        gg <- gg + scale_colour_continuous(type = "viridis")
        if(nb_last_day > 0) {
            gg <- gg + scale_x_date(date_breaks = "1 week",labels = function(x) format(x, "%d-%b"),limits = c(as.Date(Sys.Date()) - nb_last_day, date_export))
        } else {
            gg <- gg + scale_x_date(date_breaks = "1 week",labels = function(x) format(x, "%d-%b"),limits = c(NA, date_export))
        }
        gg <- gg + scale_y_datetime(breaks=vec_hour,labels = function(y) format(y,"%H:%M"))

        print(gg)

        ##  ggfile <- paste0("output/",tax,"_loc_per_day.png")
        ##  cat(ggfile)
        ##  ggsave(ggfile,gg,width=8,height=8.5)


        ## cat("   DONE !\n")
    }



}



bird_tracks_new <- function(d,nb_last_day=10,date_last_update=NULL,margin=.5){

    ##  nb_last_day=30;date_last_update = as.Date(last_import_date);margin=.5

    date_update <- as.Date(d[1,db_date])
    if(!is.null(date_last_update))  nb_day_update <- round(difftime(date_update,date_last_update,units="days"))


    dd <- d[difftime(date,as.Date(Sys.time())- nb_last_day) > 0  & !is.na(location_lat),]

    t_ind <- unique(dd[,.(bird_id,nick_name,taxon_eng)])
    setorder(t_ind,bird_id)

    for(i in 1:nrow(t_ind)) {
  ###  for(i in 1:5) {
        d_ind <- dd[bird_id == t_ind[i,bird_id],]
        title <- paste(t_ind[i,bird_id],t_ind[i,nick_name],": ",t_ind[i,taxon_eng])

        f_date <- min(d_ind$date)
        l_date <- max(d_ind$date)
        nb_day <- round(difftime(l_date,f_date,units="days"))
        nb_loc <- nrow(d_ind)
        sub <- paste0(f_date," -> ",l_date," (",nb_day," day",ifelse(nb_day>1,"s",""),"): ",nb_loc," location",ifelse(nb_loc>1,"s",""),"\nUpdate date: ",date_update)

        if(!is.null(date_last_update)) {

            nb_loc_new <- nrow(d_ind[new==TRUE,])
            txt_new <- paste0(" |  since the last update ",date_last_update," (",nb_day_update," day",ifelse(nb_day_update>1,"s",""),"): ",nb_loc_new," location",ifelse(nb_loc_new>1,"s",""))
            sub <- paste0(sub,txt_new)

        }
        gg_file  <- paste0("c:/GIT/kivikuaka/output/map_new_",sub(" ","_",t_ind[i,bird_id]),".png")

        bird_tracks_pacific(d_ind,gg_title = title,gg_sub =sub,margin=margin,gg_save=TRUE,gg_file = gg_file)

    }

}







bird_tracks_pacific <- function(dind,gg_title="",gg_sub="",ratio_ref = 4/3,fixe_orientation=TRUE,margin=.5,gg_print =TRUE,gg_save=FALSE,gg_file=NULL) {

##  dind <- d_ind ; gg_sub = sub ; gg_title=title ; gg_print =TRUE;gg_save=FALSE;margin=0.5;ratio_ref = 4/3;geographic_marker_file = "data/geographic_marker.csv";fixe_orientation=TRUE

    point.sf <- st_as_sf(dind,coords=c("location_long","location_lat"),crs= 4326)
    point.sf <- st_transform(point.sf,crs=3832)

    newpoint.sf <- subset(point.sf,new ==TRUE)

    path <- as.data.frame(st_coordinates(point.sf))
    setDT(path)

    upperLm <- c(min(path[,X]),max(path[,Y]))
    lowerRm <- c(max(path[,X]),min(path[,Y]))

    if(length(unique(path[,X]))== 1)  {
        upperLm[1] <- upperLm[1] - 1000
        lowerRm[1] <-  lowerRm[1] + 1000
    }

    if(length(unique(path[,Y]))== 1)  {
        upperLm[2] <- upperLm[2] + 1000
        lowerRm[2] <- lowerRm[2] - 1000
    }

    Ydist <- abs(upperLm[2] - lowerRm[2])
    Xdist <- abs(upperLm[1] - lowerRm[1])



    if(!(is.null(ratio_ref))){

        if(Xdist >= Ydist | fixe_orientation){
            ratio <- Xdist / Ydist
            if(ratio > ratio_ref) {
                Ydistnew <- Xdist / ratio_ref
                ajout <- (Ydistnew - Ydist)/2
                upperLm[2] <- upperLm[2]+ ajout
                lowerRm[2] <- lowerRm[2]- ajout
            }

            if(ratio < ratio_ref){
                Xdistnew <- Ydist * ratio_ref
                ajout <- (Xdistnew - Xdist)/2
                upperLm[1] <- upperLm[1]- ajout
                lowerRm[1] <- lowerRm[1]+ ajout
            }

        } else {
            ratio <- Ydist / Xdist
            if(ratio > ratio_ref) {
                Xdistnew <- Ydist / ratio_ref
                ajout <- (Xdistnew - Xdist)/2
                upperLm[1] <- upperLm[1]- ajout
                lowerRm[1] <- lowerRm[1]+ ajout

            }
            if(ratio < ratio_ref) {
                Ydistnew <- Xdist * ratio_ref
                ajout <- (Ydistnew - Ydist)/2
                upperLm[2] <- upperLm[2]+ ajout
                lowerRm[2] <- lowerRm[2]- ajout

            }
        }


        Xdist <- abs(upperLm[1] - lowerRm[1])
        Ydist <- abs(upperLm[2] - lowerRm[2])
    }
    margeX <- (Xdist * margin)/2
    margeY <- (Ydist * margin)/2

    upperLm <- upperLm + (c(margeX,margeY) * c(-1,1))
    lowerRm <- lowerRm + (c(margeX,margeY) * c(1,-1))

    corner.m <- data.table(corner = c("upperL","lowerR"),x=c(upperLm[1],lowerRm[1]),y=c(upperLm[2],lowerRm[2]))


    xlim  <- corner.m[,x]
    ylim <- corner.m[2:1,y]


    world <- sf::st_as_sf(maps::map('world', plot = FALSE, fill = TRUE))
    world.pacific <- st_transform(world,crs=3832)

 ##   corner.box <- c(xmin = xlim[1],ymin=ylim[1],xmax=xlim[2],ymax=ylim[2])
  ##  corner.box.sf <- bbox_to_SpatialPolygons(corner.box,crs=3832)
  ##  b0 = st_polygon(list(t(as.matrix(corner.m[,2:3]))))


    island.sf <- st_read("c:/GIT/Kivikuaka/GIS/pacific_cost.shp")
    island.sf <- st_transform(island.sf,crs=3832)
  ##  island.box <- as.vector(st_bbox(island.sf))
 ##   box <- data.frame(rbind(corner.box,island.box))
  ##  island.sf <- st_crop(island.sf,xmin = max(box$xmin),ymin=max(box$ymin),xmax=min(box$xmax),ymax=max(box$ymax))

    water.sf <- st_read("c:/GIT/Kivikuaka/GIS/pacific_water.shp")
    water.sf <- st_transform(water.sf,crs=3832)
  ##  water.box <- as.vector(st_bbox(water.sf))
  ##  box <- data.frame(rbind(corner.box,water.box))
  ##  water.sf <- st_crop(water.sf,xmin = max(box$xmin),ymin=max(box$ymin),xmax=min(box$xmax),ymax=max(box$ymax))
    ## water.sf <- st_crop(water.sf,xmin = xlim[1],ymin=ylim[1],xmax=xlim[2],ymax=ylim[2])


    gg <- ggplot() + geom_sf(data = world.pacific,fill="white", colour="#7f7f7f", size=0.2)
    gg <- gg + geom_sf(data = water.sf, fill = "#a6bddb",color = NA)
    gg <- gg + geom_sf(data = island.sf,fill="white")
    gg <- gg + geom_path(data = path,aes(x=X,y=Y))
    gg <- gg + geom_sf(data= point.sf, aes(colour=as.Date(date)) ,size=2)
    gg <- gg + labs(x="",y="",colour="Date",title=gg_title,subtitle = gg_sub)
    if(nrow(newpoint.sf)>0) gg <- gg + geom_sf(data = newpoint.sf,colour="yellow",alpha= 1 ,size=1)
    gg <- gg + scale_colour_date(low="blue", high="red" )
    gg <- gg + coord_sf(xlim=xlim,ylim=ylim)
    gg <- gg + theme(panel.background = element_rect(fill = "#a6bddb"), panel.grid = element_blank())


    if(gg_save) {
        cat("figure",gg_file,"\n")
        ggsave(gg_file,gg,width=7,height=7)
    }

    if(gg_print) print(gg)




}





bird_tracks <- function(dind,gg_title="",gg_sub="",ratio_ref = 4/3,fixe_orientation=TRUE,margin=1.5,gg_print =TRUE,gg_save=FALSE,file_fig=NULL,geographic_marker_file = "data/geographic_marker.csv") {

    dind <- d_ind ; gg_sub = sub ; gg_title=title ; gg_print =TRUE;gg_save=FALSE;margin=4;geographic_marker_file = "data/geographic_marker.csv"


    dind.mercator <- as.data.frame( OpenStreetMap::projectMercator( lat = dind$location_lat, long = dind$location_long ) )
    dind <- cbind(dind,dind.mercator)
    setDT(dind)

    upperLm <- c(min(dind[,x]),max(dind[,y]))
    lowerRm <- c(max(dind[,x]),min(dind[,y]))


    Ydist <- abs(upperLm[2] - lowerRm[2])
    Xdist <- abs(upperLm[1] - lowerRm[1])


    if(!(is.null(ratio_ref))){


        if(Xdist >= Ydist | fixe_orientation){
            ratio <- Xdist / Ydist
            if(ratio > ratio_ref) {
                Ydistnew <- Xdist / ratio_ref
                ajout <- (Ydistnew - Ydist)/2
                upperLm[2] <- upperLm[2]+ ajout
                lowerRm[2] <- lowerRm[2]- ajout

            }
            if(ratio < ratio_ref){
                Xdistnew <- Ydist * ratio_ref
                ajout <- (Xdistnew - Xdist)/2
                upperLm[1] <- upperLm[1]- ajout
                lowerRm[1] <- lowerRm[1]+ ajout
            }
        } else {
            ratio <- Ydist / Xdist
            if(ratio > ratio_ref) {
                Xdistnew <- Ydist / ratio_ref
                ajout <- (Xdistnew - Xdist)/2
                upperLm[1] <- upperLm[1]- ajout
                lowerRm[1] <- lowerRm[1]+ ajout

            }
            if(ratio < ratio_ref) {
                Ydistnew <- Xdist * ratio_ref
                ajout <- (Ydistnew - Ydist)/2
                upperLm[2] <- upperLm[2]+ ajout
                lowerRm[2] <- lowerRm[2]- ajout

            }
        }



        Xdist <- abs(upperLm[1] - lowerRm[1])
        Ydist <- abs(upperLm[2] - lowerRm[2])
    }
    margeX <- (Xdist * margin)/2
    margeY <- (Ydist * margin)/2

    upperLm <- upperLm + (c(margeX,margeY) * c(-1,1))
    lowerRm <- lowerRm + (c(margeX,margeY) * c(1,-1))

    corner.m <- data.table(corner = c("upperL","lowerR"),x=c(upperLm[1],lowerRm[1]),y=c(upperLm[2],lowerRm[2]))



    setDF(corner.m)
    sfc = st_as_sf(corner.m,coords = c("x", "y"), crs =osm()@projargs[1])#3857)
    sfc <- st_transform(sfc,4326)
    ##   proj4string(as.character(osm()@projargs[1])))

    upperL <- st_coordinates(sfc)[1,]
    lowerR <- st_coordinates(sfc)[2,]




    d.corner <- data.table(corner = c("upperL","lowerR"),longitude=c(upperL[1],lowerR[1]),latitude=c(upperL[2],lowerR[2]))
    d.mercator.corner <- as.data.frame( OpenStreetMap::projectMercator( lat = d.corner$latitude, long = d.corner$longitude ) )
    d.corner <- cbind(d.corner,d.mercator.corner)




    seq.x <- seq(d.corner[corner == "upperL",longitude],d.corner[corner == "lowerR",longitude], length.out=7)
    seq.x <- seq.x[c(2:6)]

    dig.x <- -2
    seq.x.round <- round(seq.x,dig.x)

    while(length(unique(seq.x.round))<length(seq.x) | dig.x == 5){
        dig.x <- dig.x +1
        seq.x.round <- round(seq.x,dig.x)

    }

    seq.x <- seq.x.round



    seq.y <- seq(d.corner[corner == "lowerR",latitude],d.corner[corner == "upperL",latitude], length.out=7)
    seq.y <- seq.y[c(2:6)]

    dig.y <- -2
    seq.y.round <- round(seq.y,dig.y)
    while(length(unique(seq.y.round))<length(seq.y) | dig.y == 5){
        dig.y <- dig.y +1
        seq.y.round <- round(seq.y,dig.y)

    }

    seq.y <- seq.y.round


    d.axis <- data.table(expand.grid(Latitude = seq.y,Longitude = seq.x))


    d.mercator.axis <- as.data.frame( OpenStreetMap::projectMercator( lat = d.axis$Latitude, long = d.axis$Longitude ) )
    d.axis <- cbind(d.axis,d.mercator.axis)
                                        #  d.axis <- d.axis[x >= min(d.corner$x) ,]#& x <=  max(d.corner$x) & y >=  min(d.corner$y) & y <=  max(d.corner$y)   ,]
    d.axis.x <- unique(d.axis[,.(Longitude,x)])
    setorder(d.axis.x,x)
    d.axis.y <- unique(d.axis[,.(Latitude,y)])
    setorder(d.axis.y,y)

    setnames(d.axis.x,"x","breaks")
    d.axis.x[,label := paste0(sprintf(paste0("%.",max(0,dig.x),"f"),Longitude),"° ",ifelse(Longitude > 0, "E","W"))]

    setnames(d.axis.y,"y","breaks")
    d.axis.y[,label := paste0(sprintf(paste0("%.",max(0,dig.y),"f"),Latitude),"° ",ifelse(Latitude > 0, "N","S"))]



    if(!is.null(geographic_marker_file)){
        geographic_marker <- fread(geographic_marker_file)
        geographic_marker.m <- as.data.frame( OpenStreetMap::projectMercator( lat = geographic_marker$Y, long = geographic_marker$X ) )
        geographic_marker <- cbind(geographic_marker,geographic_marker.m)

        xlim <- c(d.corner[corner == "upperL",longitude],d.corner[corner == "lowerR",longitude])
        ylim <- c(d.corner[corner == "lowerR",latitude],d.corner[corner == "upperL",latitude])

          geographic_marker <- geographic_marker[X > xlim[1] & x < xlim[2] & Y > ylim[1] & Y < ylim[2],]

    }
    mp <- openmap(upperL[2:1],lowerR[2:1],type="bing")

    gg <- autoplot.OpenStreetMap(mp)
    gg <- gg + labs(x="",y="",colour="Date",title=gg_title,subtitle = gg_sub)
    gg <- gg + geom_path(data=dind,mapping=aes(x=x,y=y),colour="white",alpha= 0.7 ,size=.8)
    gg <- gg + geom_point(data = dind, mapping=aes(x=x,y=y,colour=as.Date(date)),alpha= 0.7 ,size=2)
    gg <- gg + geom_point(data = dind[new ==TRUE,], mapping=aes(x=x,y=y),colour="white",alpha= 1 ,size=1)
    gg <- gg + scale_colour_date(low="blue", high="red" )
    gg <- gg + scale_x_continuous(breaks = d.axis.x$breaks, labels = d.axis.x$label,expand=c(0,0))
    gg <- gg + scale_y_continuous(breaks = d.axis.y$breaks, labels = d.axis.y$label,expand=c(0,0))
  ##  gg <- gg + geom_point(data = geographic_marker,aes(x=x,y=y),size=.001)
  ##  gg <- gg + geom_label_repel(data = geographic_marker,aes(x=x,y=y,label=name),size=3)
    gg

    if(gg_save) {
        cat("figure",file_fig,"\n")
        ggsave(file_fig,gg)
    }

    if(gg_print) print(gg)




}


