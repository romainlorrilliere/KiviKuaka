### vecPackage=c("ggplot2","ggmap","mapproj","lubridate","maps","mapdata","dplyr","rgdal","maptools","raster","sf","data.table","ggsn","gridExtra","OpenStreetMap","ggrepel","move")

vecPackage=c("kableExtra","knitr","maptools")

ip <- installed.packages()[,1]

for(p in vecPackage){
    if (!(p %in% ip))
        install.packages(pkgs=p,repos = "https://pbil.univ-lyon1.fr/CRAN/",dependencies=TRUE)
    library(p,character.only = TRUE)

}





my_kable_print <- function(d,caption="",bootstrap_options = "hover",position="center" , font_size=11,full_width = FALSE,fixed_thead = TRUE,scroll=TRUE,scroll_height = "300px", scroll_width = "100%") {

    k <- kableExtra::kable_styling(knitr::kable(d,caption = caption),bootstrap_options = ,bootstrap_options, full_width = full_width,fixed_thead = fixed_thead, position=position,font_size=font_size)
    if(scroll)
        k <- kableExtra::scroll_box(k,width = scroll_width, height = scroll_height)

    return(k)
}




sunrise_sunset <- function() {


## ---- initializing parameters for debugging ----
## dd <- dtot[,c("id","latitude_wgs84","longitude_wgs84","date_complet")]
## ---

require(maptools)

cat("  -  Assessing the sunrise and sunset in function of location and date \n")


dd <- subset(dd,!is.na(date_complet))
cat(nrow(dd),"samples with valid date and time\n")

ddd <- subset(dd,is.na(longitude_wgs84))
dd <- subset(dd,!is.na(longitude_wgs84))

cat(nrow(dd),"samples with valid location\n")

coordinates(dd) <- c("longitude_wgs84", "latitude_wgs84")
lonlat <- SpatialPoints(coordinates(dd),proj4string=CRS("+proj=longlat +datum=WGS84"))
dd$sunrise <- sunriset(lonlat, as.POSIXct(dd$date_complet), direction="sunrise", POSIXct=TRUE)$time
dd$sunset <- sunriset(lonlat, as.POSIXct(dd$date_complet), direction="sunset", POSIXct=TRUE)$time
dd$dawn <- dd$sunrise - (30*60)
dd$dusk <- dd$sunset + (30*60)
dd$sunrise2sunset <- dd$date_complet > dd$sunrise & dd$date_complet < dd$sunset
dd$dawn2dusk <- dd$date_complet > dd$dawn & dd$date_complet < dd$dusk

dd <- dd@data[,c("id","dawn","sunrise","sunset","dusk","sunrise2sunset","dawn2dusk")]
cat("   -> Done !\n")

## we assess the sunrise in the case of western place
cat(nrow(ddd),"samples with not valid location  -> In these case we assess generic sunrise and sunset such as: \n")
cat("  1) Assessing sunrise from the most westerly place in France\n")

ddd1 <- ddd
ddd1$latitude_wgs84 <- 48.453117
ddd1$longitude_wgs84 <- -5.128283
coordinates(ddd1) <- c("longitude_wgs84", "latitude_wgs84")
lonlat1 <- SpatialPoints(coordinates(ddd1),proj4string=CRS("+proj=longlat +datum=WGS84"))
ddd1$sunrise <- sunriset(lonlat1, as.POSIXct(ddd$date_complet), direction="sunrise", POSIXct=TRUE)$time
ddd1$dawn <- ddd1$sunrise - (30*60)
ddd1 <- ddd1@data[,c("id","date_complet","dawn","sunrise")]
cat("   -> Done !\n")

                                        # and sunset for eastern place
cat("  2) Assessing sunset from the most easterly place in France\n")
ddd2 <- ddd
ddd2$latitude_wgs84 <- 48.969693
ddd2$longitude_wgs84 <- 8.222463
coordinates(ddd2) <- c("longitude_wgs84", "latitude_wgs84")
lonlat2 <- SpatialPoints(coordinates(ddd2),proj4string=CRS("+proj=longlat +datum=WGS84"))
ddd2$sunset <- sunriset(lonlat2, as.POSIXct(ddd$date_complet), direction="sunset", POSIXct=TRUE)$time
ddd2$dusk <- ddd2$sunset + (30*60)
ddd2 <- ddd2@data[,c("id","sunset","dusk")]
cat("   -> Done !\n")

ddd <- merge(ddd1,ddd2,by="id")

ddd$sunrise2sunset <- ddd$date_complet > ddd$sunrise & ddd$date_complet < ddd$sunset
ddd$dawn2dusk <- ddd$date_complet > ddd$dawn & ddd$date_complet < ddd$dusk

ddd <- ddd[,c("id","dawn","sunrise","sunset","dusk","sunrise2sunset","dawn2dusk")]


dd <- rbind(dd,ddd)

cat("==> Done !\n\n")
return(dd)

}


