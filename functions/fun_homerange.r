### funciton about home range or utilisation distribution assessing


vecPackage=c("ggplot2","ggmap","data.table","adehabitatHR","ggrepel")
ip <- installed.packages()[,1]

for(p in vecPackage){
    if (!(p %in% ip))
        install.packages(pkgs=p,repos = "https://pbil.univ-lyon1.fr/CRAN/",dependencies=TRUE)
    library(p,character.only = TRUE)

}

# get_kernel_h(dsf)
get_kernel_h <- function (dsf,h_start = 10,max_run=20,grid=500,grid_max=5000,extent=10) {
    require(adehabitatHR)
    require(ggplot2)
    require(ggrepel)

    ## shp_file <- "../GIS/tikei_platier.shp"
    ## habitat <- "reef"
    ## shp_reef <- st_read(shp_file)
    ## shp_reef$habitat <- habitat
    ## shp_reef <- st_transform(shp_reef,crs=3832)
    ## border <- st_cast(st_crop(shp_reef,st_bbox(tikei_crop)),"MULTILINESTRING")
    ## plot(border)
    ## border_sp <- as(border,'Spatial')

    ##  h_start = 10;max_run=15;grid=1000;extent=10


    vecBird <- unique(dsf$bird_id)

    d_h_bird <- data.table(bird_id = vecBird,grid=0,h=0,nb_poly=0)
    df_95_all <- NULL
    d_h_all <- NULL

    for(b in vecBird) {

        ## b <- "T06_red"
        current_grid <- grid

        cat("\n====",b,"====\n")
        dsf_b <- subset(dsf,bird_id == b)


        dsf_ud  <- dsf_b[,c("bird_id")]
        ## dsf_ud <- st_crop(dsf_ud,st_bbox(tikei_crop))
        dsf_ud <- as(dsf_ud,'Spatial')

        get_h  <-  TRUE
        R <- 1

        d_h <- data.table(run = 1:max_run,grid=0,h=0,nb_poly=0)

        H  <-  h_start
        while(R <= max_run & get_h) {

            kdh <- kernelUD(dsf_ud,h=H, grid=current_grid,extent=extent)
                                        # image(kd)

                                        # creating SpatialPolygonsDataFrame
            kdh_names <- names(kdh)
            ud_95h <- lapply(kdh, function(x) try(getverticeshr(x, 95),silent=TRUE))
                                        # changing each polygons id to the species name for rbind call

            grid_error <- class(ud_95h[[1]]) == "try-error"
            while(grid_error & grid < grid_max) {
                current_grid <- round(current_grid * 1.25)
                cat("\n   **",current_grid,"**\n")

                kdh <- kernelUD(dsf_ud,h=H, grid=current_grid,extent=extent)
                                        # image(kd)

                                        # creating SpatialPolygonsDataFrame
                kdh_names <- names(kdh)
                ud_95h <- lapply(kdh, function(x) try(getverticeshr(x, 95),silent=TRUE))
                                        # changing each polygons id to the species name for rbind call

                grid_error <- class(ud_95h[[1]]) == "try-error"

            }


            row.names(ud_95h[[1]]) <- b

            ## sapply(1:length(ud_95h), function(i) {
            ##     row.names(ud_95h[[i]]) <- kdh_names[i]
            ## })
            sdf_poly_95h <- Reduce(rbind, ud_95h)
            df_95h <- fortify(sdf_poly_95h)

            df_95h$bird_id <- df_95h$id
            df_95h$h  <-  H


            NB_poly <- length(unique(df_95h$piece))

            cat(b,": h= ", H," , nb poly: ",NB_poly,"\n")
            sdf_poly_95h$h <- H
            sdf_poly_95h$nb_poly  <-  NB_poly
            df_95h$h <- H
            df_95h$nb_poly <- NB_poly

            ##        gg <- ggplot()  + theme_bw()
            ##gg <- gg + geom_sf(data =tikei_crop,aes(fill=habitat), colour=NA, size=0.2, alpha=.5)
            ##gg <- gg +   geom_polygon(data = df_95h, aes(x = long, y = lat, color = as.factor(h), group = group),size=1.2,fill=NA,alpha = 1)
            ##gg <- gg + geom_sf(data = subset(dsf_b,bird_id == "T06_red"),size=0.8) #+ geom_path(data=dd,aes(x=X,y=Y,group=bird_id,colour= bird_id),alpha=0.2,size=0.5)
            ##gg <- gg + annotation_scale()
            ##gg <- gg + labs(x="",y="",colour="h",title=paste(b,H,NB_poly))
            ##gg <- gg + coord_sf(xlim = c(7284148,7288089), ylim = c( -1673693, -1671352))
            ##gg <- gg + scale_fill_manual(values=vec_colour)
            ##print(gg)
            ##

            if(R == 1) df_95  <- df_95h else df_95 <- rbind(df_95,df_95h)

            d_h[run == R, h := H];  d_h[run == R, nb_poly :=NB_poly]; d_h[run == R, grid :=current_grid]




            sub_d_h <- d_h[1:R,]
            if(NB_poly > 1) {
                d_h_sup <- sub_d_h[nb_poly == 1,]
                if(nrow(d_h_sup) > 0) {
                    H_sup <- min(d_h_sup[,h])
                    H_inf <- max(sub_d_h[nb_poly >  1,h])
                    H <- round(mean(c(H_inf,H_sup)))
                } else {
                    H <-  max(sub_d_h[,h]) * 2
                }
            } else {
                d_h_inf <- sub_d_h[nb_poly > 1,]
                if(nrow(d_h_inf) > 0) {
                    H_inf <- max(d_h_inf[,h])
                    H_sup <- min(sub_d_h[nb_poly ==  1,h])
                    H <- round(mean(c(H_inf,H_sup)))
                } else {
                    H <- min(sub_d_h[,h]) / 2
                }
            }


            if(H %in% d_h[,h]) {
                get_h <- FALSE
                HH <- min(sub_d_h[nb_poly ==  1,h])
                final_grid <- sub_d_h[h ==  HH,grid]
                NB_poly_final <- sub_d_h[h ==  HH,nb_poly]
                NB_run_h <- sub_d_h[h ==  HH,run]
            } else {

                R <- R+1
            }

        }
        setDT(df_95)
        head(df_95)
        df_95[,group_h := paste0(h,"_",group)]

        gg <- ggplot()  + theme_bw()
        gg <- gg + geom_sf(data =tikei_crop,aes(fill=habitat), colour=NA, size=0.2, alpha=.5)
        gg <- gg +   geom_polygon(data = df_95, aes(x = long, y = lat, color = h, group = group_h),size=1,fill=NA,alpha = 0.8)
        gg <- gg +   geom_polygon(data = df_95[h==HH,], aes(x = long, y = lat,group = group_h),size=1,colour="red",fill=NA,alpha = 0.8)
        gg <- gg + geom_sf(data = subset(dsf_b,bird_id == b),size=0.8) #+ geom_path(data=dd,aes(x=X,y=Y,group=bird_id,colour= bird_id),alpha=0.2,size=0.5)
        gg <- gg + annotation_scale()
        gg <- gg + labs(x="",y="",colour="h",title=paste0("bird: ",b,", h = ",HH))
        gg <- gg + coord_sf(xlim = c(7284148,7288089), ylim = c( -1673693, -1671352))
        gg <- gg + scale_fill_manual(values=vec_colour)
        print(gg)
        ggsave(paste0("output/get_h_kernel_",b,".png"),gg,width = 8 , height = 4)


        d_h_bird[bird_id == b, h := HH];  d_h_bird[bird_id == b, nb_poly := NB_poly_final]; d_h_bird[bird_id == b,grid := final_grid]; d_h_bird[bird_id == b, nb_run_h := NB_run_h]; d_h_bird[bird_id == b, nb_run := R]

        d_h[,bird_id := b]

        df_95_all <- rbind(df_95_all,df_95)
        dim(df_95_all)
        d_h_all <- rbind(d_h_all,d_h)



    }


    df_95_all <- merge(df_95_all,d_h_bird[,.(bird_id,grid,h)],by=c("bird_id","h"),all.x=TRUE)
    df_95_all[,good_h := !is.na(grid)]
    df_95_all[,bird_id := id]

    list_h <- list(d_h_bird,d_h_all,df_95_all)

    gg <- ggplot(d_h_all[nb_poly>0,],aes(x=run,y=h))+ facet_wrap(.~bird_id,scale= "free_y" )
    gg <- gg + geom_point(aes(colour=nb_poly == 1),size=2) + geom_line()
    gg <- gg + geom_hline(data = d_h_bird,  aes(yintercept = h))
    gg <- gg + geom_label_repel(data = d_h_bird, aes(label = h,x=nb_run_h))
    gg
    ggsave(paste0("output/get_h_accumulation_all.png"),gg,width = 9, height = 5)



    gg <- ggplot()  + theme_bw()+ facet_wrap(.~bird_id)
    gg <- gg + geom_sf(data =tikei_crop,aes(fill=habitat), colour=NA, size=0.2, alpha=.5)
    gg <- gg + geom_polygon(data = df_95_all, aes(x = long, y = lat, color = h, group = group_h),size=1,fill=NA,alpha = 0.8)
gg
    gg <- gg +  geom_polygon(data = df_95_all[good_h==TRUE,], aes(x = long, y = lat,group = group_h),size=0.8,colour="red",fill=NA,alpha = 1)
    gg <- gg + geom_sf(data = dsf_b,size=0.8) #+ geom_path(data=dd,aes(x=X,y=Y,group=bird_id,colour= bird_id),alpha=0.2,size=0.5)
    gg <- gg + annotation_scale()
    gg <- gg + labs(x="",y="",colour="h",title="")
    gg <- gg + coord_sf(xlim = c(7284148,7288089), ylim = c( -1673693, -1671352))
    gg <- gg + scale_fill_manual(values=vec_colour)
    print(gg)
    ggsave(paste0("output/get_h_kernel_",b,".png"),gg,width = 10 , height = 6)


    saveRDS(list_h,"output/h_kernel.rds")

    return(list_h)
}









