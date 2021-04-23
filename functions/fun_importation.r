vecPackage=c("lubridate","data.table","move","ggplot2")
ip <- installed.packages()[,1]

for(p in vecPackage){
    if (!(p %in% ip))
        install.packages(pkgs=p,repos = "https://pbil.univ-lyon1.fr/CRAN/",dependencies=TRUE)
    library(p,character.only = TRUE)

}


get_pw <- function(file)
    readLines(file)



get_birds <- function(con,id_prog=1381110575,
                      file_ind_raw = "C:/git/Kivikuaka/data/data_kivikuaka_ind_raw.csv",
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
                       file_ind_raw =  "data/data_kivikuaka_ind.csv" ){


    path_file_ind_raw <- paste0(rep,file_ind_raw)
    ind <- fread(path_file_ind_raw)
    ind_taxon <- ind[,.(id,bird_id,taxon,taxon_fr,taxon_eng,nick_name)]
    setnames(ind_taxon,"id","individual_id")

    d <- move::getMovebank("event",login= con,study_id=id_prog)
    setDT(d)

    d <- merge(d,ind_taxon)
    d[,event_id := paste0(individual_id,"_",format(as.POSIXlt(timestamp),"%Y%m%d%H%M%S"))]



    today <- format(as.Date(Sys.time()))


    path_file_events_raw  <- paste0(rep,file_events_raw)

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
    d[,hour := as.numeric(format(as.POSIXlt(timestamp),"%H"))]
    d[,hour_float := round(hour + as.numeric(format(as.POSIXlt(timestamp),"%m"))/60,2)]
    d[,julian := as.numeric(format(as.POSIXlt(timestamp),"%j"))]
    d[,db_date := Sys.time()]

    setcolorder(d,c("event_id","individual_id","bird_id","nick_name","taxon","timestamp","location_lat","location_long","tag_id","taxon_fr","taxon_eng","date","julian","hour","hour_float","import_date","new","db_date"))


   fwrite(d,path_file_events_raw)

    return(d)
}




summary_new_ind <- function(ind) {

    t_birds <- ind[number_of_events > 0,list(nb_birds = .N),by=list(taxon_eng)]
    t_birds_5days <- ind[nb_day_silence <= 5 ,list(nb_birds_5days = .N),by=list(taxon_eng)]
    t_birds_10days <- ind[nb_day_silence <= 10 ,list(nb_birds_10days = .N),by=list(taxon_eng)]


    t_sum  <- unique(ind[,.(taxon_eng,taxon_fr)])
    t_sum[t_birds,on = "taxon_eng", nb_birds := nb_birds]
    t_sum[t_birds_5days,on = "taxon_eng", nb_birds_5days := nb_birds_5days]
    t_sum[,prop_5days := round(nb_birds_5days/nb_birds,2)]
    t_sum[t_birds_10days,on = "taxon_eng", nb_birds_10days := nb_birds_10days]
    t_sum[,prop_10days := round(nb_birds_10days/nb_birds,2)]


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
    setorder(dd,-nb_new_events)
    } else {
        dd <- NULL
    }

    return(dd)

}




data_by_day <- function(d,ind,vec_tax) {

       ind_taxon <- ind[,.(id,bird_id,taxon,taxon_fr,taxon_eng,nick_name)]
    setnames(ind_taxon,"id","individual_id")

    d[,nb_data_by_day := .N,by = list(julian,bird_id)]

    d_nbLocByDay <- d[!(is.na(location_lat)),list(nb_loc_by_day = .N),by = list(julian,bird_id)]
    d <- merge(d,d_nbLocByDay,by = c("bird_id","julian"),all.x=TRUE)

    d[,prop_loc_by_day := ifelse(is.na(nb_loc_by_day),0,nb_loc_by_day) / nb_data_by_day]



    d_first <- d[!(is.na(location_lat)),list(date = as.Date(min(date))),by = list(bird_id)]
    d_first[,`:=` (date_short = format(date,"%d/%m"),julian =as.numeric(format(date,"%j"))-2) ]
    d_first <- merge(ind_taxon,d_first,by="bird_id")


    d_last <- d[!(is.na(location_lat)),list(date = as.Date(max(date))),by = list(bird_id)]
    d_last[,`:=` (date_short = format(date,"%d/%m"),julian =as.numeric(format(date,"%j"))+2) ]
    d_last <-merge(ind_taxon,d_last,by="bird_id")


    vec_date <- as.Date(paste0(rep("2021",24),"-",rep(1:12,each=2),"-",rep(c(1,15),12)),"%Y-%m-%d")
    t_date <- data.table(date = vec_date, date_short=format(vec_date,"%d/%m"),julian = as.numeric(format(vec_date,"%j")))

    t_date_gg <- t_date[julian >= min(d$julian) & julian <= max(d$julian),]

    julian_export <- as.numeric(format(Sys.time(),"%j"))

    for(tax in vec_tax) {

       ## cat("\n",tax,":\n")

       gg <- ggplot(data = d[taxon == tax & !(is.na(location_lat)),],aes(x=julian,y=hour_float,colour=nb_loc_by_day)) + facet_grid(bird_id~.)
        gg <- gg + geom_vline(xintercept= julian_export,colour="white",size=1.5)
        gg <- gg + geom_vline(xintercept= julian_export,colour="darkgray",size=.5)
        gg <- gg + geom_text(data=d_first[taxon == tax,],aes(label=date_short),y=12,colour="black",size=3)
        gg <- gg + geom_text(data=d_last[taxon == tax,],aes(label=date_short),y=12,colour="black",size=3)
        gg <- gg  + geom_line(colour="black")+ geom_point(size=1.5)

        gg <- gg + labs(title = tax,y="Time of day", x="Date",colour="Number\nof loc\nper day" )
        gg <- gg + scale_x_continuous(breaks = t_date_gg$julian, labels = t_date_gg$date_short)
        gg <- gg + scale_y_continuous(breaks = c(10,22))
        gg <- gg +  theme(panel.grid.minor=element_blank(),panel.grid.minor.y=element_blank())
        gg <- gg + scale_colour_continuous(type = "viridis")

       print(gg)

        ##  ggfile <- paste0("output/",tax,"_loc_per_day.png")
        ##  cat(ggfile)
        ##  ggsave(ggfile,gg,width=8,height=8.5)


        ## cat("   DONE !\n")
    }



}



bird_tracks <- function(d) {



    dbird <- d[bird_id == "T03" & !(is.na(location_lat)),]

    dbird.mercator <- as.data.frame( OpenStreetMap::projectMercator( lat = dbird$location_lat, long = dbird$location_long ) )
    dbird <- cbind(dbird,dbird.mercator)


    dfirst <- dbird[, list(UTC_datetime = min(UTC_datetime)),by = device_id]
    dfirst <- merge(dfirst,d,by=c("UTC_datetime","device_id"))

    dlast <- d[,list(UTC_datetime = max(UTC_datetime)),by = device_id]
    dlast <- merge(dlast,d,by=c("UTC_datetime","device_id"))

    upperL <- c(min(dbird[,location_long]-0.03),max(dbird[,location_lat]+.03))
    lowerR <- c(max(dbird[,location_long]+.03),min(dbird[,location_lat]-.03))




    d.axis <- data.table(expand.grid(Latitude = seq(-85,85,5),Longitude = seq(-175,175,5)))
    d.mercator.axis <- as.data.frame( OpenStreetMap::projectMercator( lat = d.axis$Latitude, long = d.axis$Longitude ) )
    d.axis <- cbind(d.axis,d.mercator.axis)
    d.axis <- d.axis[Longitude > upperL[1] & Longitude <lowerR[1] & Latitude > lowerR[2] & Latitude < upperL[2] ,]
    d.axis.x <- unique(d.axis[,.(Longitude,x)])
    d.axis.y <- unique(d.axis[,.(Latitude,y)])

    setnames(d.axis.x,"x","breaks")
    d.axis.x[,label := paste0(Longitude,"° ",ifelse(Longitude > 0, "E","W"))]

    setnames(d.axis.y,"y","breaks")
    d.axis.y[,label := paste0(Latitude,"° ",ifelse(Latitude > 0, "N","S"))]

    vecCol <- c("green"="#09d703","red"="#ff0700","yellow"="#fff800")

    file_fig <- paste0("output/",prefix_file_fig,numfig,".png")
    cat("figure",file_fig,"\n")

    mp <- openmap(upperL[2:1],lowerR[2:1],type='bing')

    gg <- autoplot.OpenStreetMap(mp)
    gg <- gg + labs(x="",y="",colour="")+ theme(legend.position="none")
    gg <- gg + geom_path(data=dbird,mapping=aes(x=x,y=y,colour=hour,group=ind_code),alpha= 1 ,size=1)
    gg

    gg <- gg + geom_point(data=dfirst,mapping=aes(x=x,y=y,colour=hour),alpha= 1 ,size=3.3)
    gg <- gg + geom_point(data=dfirst,mapping=aes(x=x,y=y),colour="white",alpha= 1 ,size=1.2)
    gg <- gg + geom_point(data=dlast,mapping=aes(x=x,y=y,colour=cat),alpha= 1 ,size=3.3)
    gg <- gg + geom_point(data=dlast,mapping=aes(x=x,y=y),colour="black",alpha= 1 ,size=1.2)
    gg <- gg + geom_point(data=dlastred,mapping=aes(x=x,y=y,colour=cat),alpha= 0.8 ,size=3.3)
    gg <- gg + geom_point(data=dlastred,mapping=aes(x=x,y=y),colour="black",alpha= 0.8 ,size=1.2)

    gg <- gg + scale_colour_manual(values=vecCol)
    gg

}
