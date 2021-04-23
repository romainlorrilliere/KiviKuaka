
### {r param_test}

rep <- "C:/git/KiviKuaka/"
file_data <-"data/data_kivikuaka_envents.csv"
pw <-"xxx"
username <-"romainlorrilliere"
save.fig <- FALSE
study_id=1381110575



### {r source}

file_source <- paste0(rep,"functions/fun_rmd_generic.r")
source(file_source)
file_source <- paste0(rep,"functions/fun_importation.r")
source(file_source)



### {r movebank_log}

if(pw == "xxx"){
    file <- paste0(rep,"data/pw.txt")
    pw <- get_pw(file)
}
log <- movebankLogin(username,pw)




### {r movebank_import}

ind <- get_birds(log)
d <- get_events(log)

ind_select <- ind[,.(bird_id,nick_name,taxon,id,ring_id,taxon_eng,taxon_fr,date_start,date_end,number_of_events,nb_day_silence,new,import_date)]

### {r summary_ind}
summary_ind <- summary_new_ind(ind)
print(summary_ind)

nb_birds <- sum(summary_ind$nb_birds)

nb_birds_5days <- sum(summary_ind$nb_birds_5days)
nb_birds_10days <- sum(summary_ind$nb_birds_10days)

prop_5days <-  round(nb_birds_5days/nb_birds,2)
prop_10days <- round(nb_birds_10days/nb_birds,2)


### {r silence}
ggplot_silence(ind)



###{r summary_events}
nbline <- nrow(d)
nbloc <- nrow(d[!(is.na(location_lat))])
d_tax <- fread(paste0(rep,"data/taxon.csv"))
vec_tax_eng <- d_tax[taxon %in% unique(d$taxon),taxon_eng]
vec_tax<- d_tax[taxon %in% unique(d$taxon),taxon]


###{r summary_new_events}
  sne <- summary_new_events(d)

###{r summary_new_events_table}
##my_kable_print(dsne,caption="The new events",scroll_width = "600px")




### {r bird_day}
data_by_day(d,ind,vec_tax)




## tracks birds
