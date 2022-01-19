

nc_2_dt <- function(ncpath = "../data_weather/test_20210823/",
                                 ncname = "test_fc_small_20210823",
                                 ncfname = paste(ncpath, ncname, ".nc", sep=""),save=TRUE,file_out=NULL) {

    require(ncdf4)
    require(data.table)

    d_temp <- get_weather_variable(ncpath = ncpath, ncname = ncname)
    d_temp[,id := paste(Var1,Var2,Var3,Var4,sep="_")]
    d <- d_temp

    d_hum <- get_weather_variable(ncpath = ncpath, ncname = ncname, dname = "r",var_name = "humidity",conv_var= NULL)
    d_hum[,id := paste(Var1,Var2,Var3,Var4,sep="_")]
    d_hum <- d_hum[,.(id,humidity)]
    d <- merge(d,d_hum,by="id")

    d_vent_u <- get_weather_variable(ncpath = ncpath, ncname = ncname, dname = "u",var_name = "wind_u",conv_var= NULL)
    d_vent_u[,id := paste(Var1,Var2,Var3,Var4,sep="_")]
    d_vent_u <- d_vent_u[,.(id,wind_u)]
    d <- merge(d,d_vent_u,by="id")

    d_vent_v <- get_weather_variable(ncpath = ncpath, ncname = ncname, dname = "u",var_name = "wind_v",conv_var= NULL)
    d_vent_v[,id := paste(Var1,Var2,Var3,Var4,sep="_")]
    d_vent_v <- d_vent_v[,.(id,wind_v)]
    d <- merge(d,d_vent_v,by="id")


    d[,wind_speed := sqrt(wind_u^2 + wind_v^2)]

    d[,wind_direction := windDir(wind_u,wind_v,wind_speed)]

    d[,altitude_fact := factor(altitude,levels=sort(unique(altitude),decreasing=TRUE))]

    d[,wind_direction_1_3 := longitude %in% sort(unique(longitude))[c(FALSE,TRUE,FALSE)] & latitude %in% sort(unique(latitude))[c(FALSE,TRUE,FALSE)]]

    d[,wind_direction_1_5 := longitude %in% sort(unique(longitude))[c(FALSE,FALSE,TRUE,FALSE,FALSE)] & latitude %in% sort(unique(latitude))[c(FALSE,FALSE,TRUE,FALSE,FALSE)]]

    if(save) {
        if(is.null(file_out)) file_out  <-  paste0(ncpath, ncname, ".csv")
        fwrite(d,file_out)
        }

    return(d)

}





get_weather_variable <- function(ncpath = "../data_weather/test_20210823/",
                                 ncname = "test_fc_small_20210823",
                                 ncfname = paste(ncpath, ncname, ".nc", sep=""),
                                 dname = "t",var_name = "temperature",conv_var= function(x) x - 273.15,
                                 conversion_level=data.frame(
                                     level = c(1000,950,850,700,600,500),
                                     altitude = c(100,500,1500,3000,4200,5600)),
                                 time_origin = "1900-01-01"){

#    ncpath = "../data_weather/test_20210823/"; ncname = "test_fc_small_20210823"; ncfname = paste(ncpath, ncname, ".nc", sep=""); dname = "t";conversion_level=data.frame(level = c(1000,950,850,700,600,500),altitude = c(100,500,1500,3000,4200,5600));conv_var= function(x) x - 273.15; time_origin = "1900-01-01"

    require(data.table)
    require(ncdf4)
    require(lubridate)
    require(sf)

    ## open a netCDF file
    ncin <- nc_open(ncfname)

    fillvalue <- ncatt_get(ncin,dname,"_FillValue")


    v3      <- ncin$var[[3]]
    varsize <- v3$varsize
    ndims   <- v3$ndims

    varlist <- list()
    for(i in 1:ndims) {
        var_i <- v3$dim[[i]]
        length_i <- var_i$len
        name_i <- var_i$name
        varlist_i <-  as.vector(var_i$vals)
       unit_i <- var_i$units

        list_i <- list(name=name_i,var=varlist_i,unit=unit_i,length=length_i)
        varlist[[i]] <- list_i
        names(varlist)[[i]] <- name_i
    }

    tmp_array <- ncvar_get(ncin,dname)
    tmp_array[tmp_array==fillvalue$value] <- NA

    if(!is.null(conv_var)) tmp_array <- conv_var(tmp_array)

    DT <- as.data.table(as.data.frame.table(tmp_array))

    list_dt <- list()
    for(i in 1:ndims) {
        dt_i <- data.table(Var = levels(DT[,paste0("Var",i),with=FALSE][[1]]), varlist[[i]]$var)
        setnames(dt_i,c("Var","V2"),c(paste0("Var",i),varlist[[i]]$name))
        if(varlist[[i]]$name == "level") {
          #  browser()
            dt_i  <-  merge(dt_i,conversion_level,by="level")
        }

        if(varlist[[i]]$name == "time") {
            dt_i[,time := as.POSIXct(time*3600,origin="1900-01-01")]
            dt_i[,`:=`(date = as.Date(time),hour = format(time, format = "%H:%M"))]
        }
        list_dt[[i]] <- dt_i
    }


    for(i in 1:ndims)
        DT <- merge(DT,list_dt[[i]],by=paste0("Var",i))

    setnames(DT,"Freq",var_name)

    DT[,longitude_raw := longitude]
    DT[,longitude := correction_longitude_wgs84(longitude)]


    DT[,id_loc := paste0(Var1,"_",Var2)]
    DT_point <- unique(DT[,.(id_loc,longitude,latitude)])
    point.sf <- st_as_sf(DT_point,coords=c("longitude","latitude"),crs= 4326)
    point.sf <- st_transform(point.sf,crs=3832)

    point_coord <- data.table(st_coordinates(point.sf))
    setnames(point_coord,c("X","Y"),c("longitude_3832","latitude_3832"))
    DT_point <- cbind(id_loc = DT_point[,id_loc],point_coord)
    DT <- merge(DT,DT_point,by="id_loc")

    return(DT)
}



correction_longitude_wgs84 <- function(x) {
    x <- ifelse(x>180,(-180 + (x-180)),x)
    return(x)

}


windDir <- function(u, v,speed) {
    return(atan2(u/speed, v/speed)*180/pi)
}






gg_weather_date_alt <- function(dgg,the_date,the_hour,altitudes=NULL,
                                save=FALSE,file_out=NULL,width=NULL,height=NULL,return=TRUE) {

    ## the_date="2021-08-23";the_hour="12:00";altitudes=c(100);save=FALSE;file_out=NULL;width=NULL;height=NULL;return=TRUE

    require(ggplot2)
    require(ggpubr)


    dgg <- dgg[date == the_date,]
    if(!is.null(the_hour)) dgg <- dgg[hour %in% the_hour,]
    if(!is.null(altitudes)) dgg <- dgg[altitude %in% altitudes,]
    if(is.null(file_out)) file_out  <- paste0("output/weather_",the_date,"_",format(strptime(the_hour, "%H:%M"), format="%H-%M"),".png")


    world <- sf::st_as_sf(maps::map('world', plot = FALSE, fill = TRUE))
    world.pacific <- st_transform(world,crs=3832)
    xlim <- c(min(dgg$longitude_3832),max(dgg$longitude_3832))
    ylim <- c(min(dgg$latitude_3832),max(dgg$latitude_3832))

    fun_color_range <- colorRampPalette(c("lightgray","purple","darkblue","lightblue","green","yellow","red","darkred"))
    my_colors <- fun_color_range(90)


    gg_temp <- ggplot()+ geom_sf(data = world.pacific,fill="white", colour="white", size=0.2)
    gg_temp <- gg_temp + facet_grid(altitude_fact~.)
    gg_temp <- gg_temp + geom_tile(data=dgg,aes(y =latitude_3832,x= longitude_3832, fill= temperature),alpha=0.8,colour=NA)
    gg_temp <- gg_temp + geom_sf(data = world.pacific,fill=NA, colour="white",size=0.2,alpha=0.5)
    gg_temp <- gg_temp + coord_sf(xlim=xlim,ylim=ylim)
    gg_temp <- gg_temp + scale_fill_gradientn(colours = my_colors,limits=c(-20,40))
    gg_temp <- gg_temp + theme(panel.background = element_rect(fill = "#a6bddb"), panel.grid = element_blank())
    gg_temp <- gg_temp + labs(main="temperature",x="",y="")
    gg_temp <- gg_temp + theme(legend.position = 'bottom', legend.direction = 'horizontal')
  #  gg_temp <- gg_temp + transition_manual(hour)




    fun_color_range <- colorRampPalette(c("firebrick","yellow","lightblue","darkblue"))
    my_colors <- fun_color_range(100)


    gg_hum <- ggplot() + geom_sf(data = world.pacific,fill="white", colour="white", size=0.2)
    gg_hum <- gg_hum + facet_grid(altitude_fact~.)
    gg_hum <- gg_hum + geom_tile(data=dgg,aes(y =latitude_3832,x= longitude_3832, fill= humidity),alpha=0.8,colour=NA)
    gg_hum <- gg_hum + geom_sf(data = world.pacific,fill=NA, colour="white",size=0.2,alpha=0.5)
    gg_hum <- gg_hum + coord_sf(xlim=xlim,ylim=ylim)
    gg_hum <- gg_hum + scale_fill_gradientn(colours = my_colors,limits=c(0,100))
    gg_hum <- gg_hum + theme(panel.background = element_rect(fill = "#a6bddb"), panel.grid = element_blank())
    gg_hum <- gg_hum + labs(main="humidity",x="",y="")
    gg_hum <- gg_hum + theme(legend.position = 'bottom', legend.direction = 'horizontal')




##    gg_hum <- ggplot(data=d, aes(y =latitude_3832,x= longitude_3832, fill= humidity)) + facet_grid(altitude_fact~.)
##    gg_hum <- gg_hum + geom_tile()
##    gg_hum <- gg_hum + coord_equal(expand = 0)
##    gg_hum <- gg_hum + labs(main="humidity")
##    gg_hum <- gg_hum + theme(legend.position = 'bottom', legend.direction = 'horizontal')
##
   fun_color_range_1 <- colorRampPalette(c("darkblue","lightblue","green","yellow","orange","red","darkred","purple"))
    my_colors_1 <- fun_color_range_1(200)

    fun_color_range_2 <- colorRampPalette(c("purple","pink","lightgray","white"))
    my_colors_2 <- fun_color_range_2(200)[-1]

    my_colors <- c(my_colors_1,my_colors_2)

##    lulu <- dgg[altitude == 4200,]
##  browser()
    gg_wind <- ggplot() + geom_sf(data = world.pacific,fill="white", colour="white", size=0.2)
    gg_wind <- gg_wind + facet_grid(altitude_fact~.)
    gg_wind <- gg_wind + geom_tile(data=dgg,aes(y =latitude_3832,x= longitude_3832, fill= wind_speed),alpha=0.8,colour=NA)
    ##    gg_wind <- gg_wind + geom_spoke(data= d[wind_direction_1_5 == TRUE,],aes(y =latitude_3832,x= longitude_3832,angle = wind_direction, radius = scales::rescale(wind_speed, c(.2, .8))*10),arrow = arrow(length = unit(.03, 'inches')),size=.1)
    gg_wind <- gg_wind + geom_spoke(data= dgg[wind_direction_1_5 == TRUE,],aes(y =latitude_3832,x= longitude_3832,angle = wind_direction,alpha=wind_speed),radius= 100000,arrow = arrow(length = unit(0.025, 'inches')),size=.35,colour="black")
    gg_wind <- gg_wind + geom_sf(data = world.pacific,fill=NA, colour="white",size=0.2,alpha=0.5)
    gg_wind <- gg_wind + coord_sf(xlim=xlim,ylim=ylim)
    gg_wind <- gg_wind + scale_fill_gradientn(colours = my_colors,limits=c(0,400))
    gg_wind <- gg_wind + theme(panel.background = element_rect(fill = "#a6bddb"), panel.grid = element_blank())
    gg_wind <- gg_wind + labs(main="humidity",x="",y="")
    gg_wind <- gg_wind + theme(legend.position = 'bottom', legend.direction = 'horizontal')
##gg_wind

##    gg_wind <- ggplot(data=d, aes(x = longitude_3832 , y = latitude_3832, fill = wind_speed, angle = wind_direction, radius = scales::rescale(wind_speed, c(.2, .8))))
##    gg_wind <- gg_wind + facet_grid(altitude_fact~.)
##    gg_wind <- gg_wind + geom_tile()#    geom_raster() +
##    gg_wind <- gg_wind + geom_spoke(data= d[wind_direction_1_5 == TRUE,],arrow = arrow(length = unit(.04, 'inches')))
##    gg_wind <- gg_wind + scale_fill_distiller(palette = "RdYlGn")
##    gg_wind <- gg_wind + coord_equal(expand = 0)
##    gg_wind <- gg_wind + labs(main="wind")
##    gg_wind <- gg_wind + theme(legend.position = 'bottom', legend.direction = 'horizontal')
##





    gg <- ggarrange(gg_temp,gg_hum,gg_wind,ncol=3)
    gg <- annotate_figure(gg, top = text_grob(paste(the_date,the_hour),color = "red", face = "bold", size = 14))

    if(save) {
        cat("-->",file_out)
        ggsave(file_out,gg,width=width,height=height)
        cat("   DONE!\n")
        }
    if(return) return(gg) else  print(gg)
}






