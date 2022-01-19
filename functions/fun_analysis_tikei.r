
f_get_data <- function(get_data=TRUE,saveData=TRUE) {

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

##browser()
    dsf <- st_as_sf(dd,coords=c("location_long","location_lat"))
    dsf <- st_set_crs(dsf, 4326)
    st_crs(dsf)
    dsf <- st_transform(dsf,crs=3832)

    dd <- cbind(dd,st_coordinates(dsf))
 if(saveData) fwrite(dd,"movebank_data_tikei.csv")
} else {

    dd <- fread("movebank_data_tikei.csv")
}
return(dd)
}





f_shp_tikei <- function(shp_processing) {
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
  return(tikei_crop)
}
