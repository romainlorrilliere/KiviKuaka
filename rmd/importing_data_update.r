
### {r param_test}

rep <- "C:/git/KiviKuaka/"
file_data <-"data/data_kivikuaka_events.csv"
pw <-"xxx"
username <-"romainlorrilliere"
save.fig <- FALSE
nb_day_before_fig   <- 30
id_previous_import <- "20210423_2017"
if(id_previous_import == "xxx") id_previous_import <- NULL

#study_id=1381110575








###{r changeRep}

## knitr::opts_knit$set(root.dir = rep)
#setwd("..")

###


###{r source}

file_source <- paste0(rep,"functions/fun_rmd_generic.r")
source(file_source)
file_source <- paste0(rep,"functions/fun_importation.r")
source(file_source)



###


# Get data from movebank



###{r movebank_log}

if(pw == "xxx"){
    file <- paste0(rep,"data/pw.txt")
    pw <- get_pw(file)
}
log <- movebankLogin(username,pw)
###



###{r last_date_import, echo=FALSE,warning=FALSE, message=FALSE}

last_import_date <- id_previous_import
difftime_last_import <- NULL
txt_last_import <- "This is the first data importing."
if(!is.null(id_previous_import)) {
  previous_file <- paste0(rep,file_path_sans_ext(file_data),"_",id_previous_import,".csv")
  new_previous_file <- paste0(rep,file_data)
  file.copy(previous_file,new_previous_file,overwrite = TRUE, copy.date = TRUE)
}


if(basename(file_data) %in% dir(paste0(rep,"data/"))) {
  dlast <- fread(paste0(rep,file_data))
  if("db_date" %in% colnames(dlast)) {
    last_import_date <- dlast[1,db_date]
    difftime_last_import <- trunc(as.numeric(difftime(Sys.time(),last_import_date,units = "day")))
    txt_last_import <- paste0("Date of the previous data update: ",last_import_date," (",difftime_last_import," day(s))\n")
  }
  file_save <- paste0(rep,file_path_sans_ext(file_data),ifelse(is.null(last_import_date),"",paste0("_",format(last_import_date,"%Y%m%d_%H%M"))),".csv")
  fwrite(dlast,file_save)
}

###



###{r movebank_import}
ind <- get_birds(con=log)
d <- get_events(con=log,id_previous_import = id_previous_import)
###

# Summary of update

## The birds




###{r summary_ind}
summary_ind <- summary_new_ind(ind)

nb_birds <- sum(summary_ind$nb_birds)

nb_birds_5days <- sum(summary_ind$nb_birds_5days)
nb_birds_10days <- sum(summary_ind$nb_birds_10days)
nb_birds_15days <- sum(summary_ind$nb_birds_15days)

prop_5days <-  round(nb_birds_5days/nb_birds,2)
prop_10days <- round(nb_birds_10days/nb_birds,2)
prop_15days <- round(nb_birds_15days/nb_birds,2)

##my_kable_print(summary_ind,caption="The summary of number of birds",scroll_width = "600px",scroll=FALSE)

print(summary_ind)

###



###{r fig.silence, fig.width=7, fig.height=7,eval=TRUE,fig.align = 'center', out.width='70%',fig.cap="Distrubiton of the number of days before after location by species",fig.scap="number of days before after location"}
ggplot_silence(ind)
###


## The new events


###{r summary_events}
nbline <- nrow(d)
nbloc <- nrow(d[!(is.na(location_lat))])

d_tax <- fread(paste0(rep,"data/taxon.csv"))
vec_tax_eng <- d_tax[taxon %in% unique(d$taxon),taxon_eng]
vec_tax<- d_tax[taxon %in% unique(d$taxon),taxon]

###


###{r summary_new_events}
  sne <- summary_new_events(d)
if(is.null(sne)) nb_new <- 0 else nb_new <- sum(sne$nb_new_events)
###


###{r summary_new_events_table,eval=FALSE, include=FALSE}
if(!(is.null(sne)))
  print(sne)#my_kable_print(sne,caption="The new events",scroll_width = "600px")
###

## The events by day

###{r title_fig_bird_day}
  cap_txt <- paste0("The bird locations by day for the ",vec_tax_eng," during the last 30 days")
print(cap_txt)
###


###{r bird_day,echo=FALSE,warning=FALSE, message=FALSE,fig.width=9, fig.height=12,eval=TRUE,fig.align = 'center', out.width='100%', fig.cap=cap_txt}

data_by_day(d=d,ind=ind,vec_tax=vec_tax,nb_last_day=30,last_update_date = as.Date(last_import_date))

###

# The recent moves


###{r title_fig_bird_tracks}


dld <- d[difftime(date,as.Date(Sys.time()) - nb_day_before_fig  )> 0 & !is.na(location_lat),]

t_indld <- unique(dld[,.(bird_id,nick_name,taxon_eng)])
setorder(t_indld,bird_id)

txt_nn <- paste0(ifelse(t_indld[,nick_name] == "",""," named "),t_indld[,nick_name])

cap_txt <- paste0("The last ten days moves of the ",t_indld[,taxon_eng]," ",t_indld[,bird_id],txt_nn,". Yellow dots for the new locations")


###

print(cap_txt)



### {r tracks_birds,eval=TRUE ,echo=FALSE,warning=FALSE, message=FALSE, fig.width=7, fig.height=7,fig.align = 'center', out.width='100%', fig.cap=cap_txt}
bird_tracks_new(d,nb_last_day=nb_day_before_fig ,date_last_update = as.Date(last_import_date),margin=.5)
###












