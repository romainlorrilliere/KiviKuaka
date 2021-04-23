---
title: "**Importing Kivikuaka's data from movebank**"
author: Romain Lorrilliere\thanks{\href{mailto:romain.lorrilliere@mnhn.fr}{\textit{romain.lorrilliere@mnhn.fr}}}
date: "23/04/2021 14:21"
output:
  github_document:
    toc: true
    toc_depth: 2
    fig_width: 5
    fig_height: 5
    dev: jpeg    
  html_document:
    df_print: paged
    fig_height: 12
    fig_width: 16
    toc: yes
    toc_depth: 3
    toc_float:
      collapsed: true
      smooth_scroll: false
    number_sections: true
    code_folding: hide
    keep_md: true
pdf_document:
  toc: yes
  toc_depth: '1'
params: 
   set_rep: "C:/git/KiviKuaka/"
   set_file_data: "data/data_kivikuaka_events.csv"
   set_mb_pw: "xxx"
   set_mb_user: "romainlorrilliere"
   set_save_fig: FALSE 
---





```r
rep <- params$set_rep
file_data <- params$set_file_data
pw <- params$set_mb_pw
username <- params$set_mb_user
save.fig <- params$set_save_fig
```





```r
knitr::opts_knit$set(root.dir = rep)
#setwd("..")
```



```r
file_source <- paste0(rep,"functions/fun_rmd_generic.r")
source(file_source)
file_source <- paste0(rep,"functions/fun_importation.r")
source(file_source)
```


# Get data from movebank




```r
if(pw == "xxx"){
    file <- paste0(rep,"data/pw.txt")
    pw <- get_pw(file)
}
log <- movebankLogin(username,pw)
```






```r
last_import_date <- NULL
difftime_last_import <- NULL
txt_last_import <- "This is the first data importing."

if(basename(file_data) %in% dir(paste0(rep,"data/"))) {
  dlast <- fread(paste0(rep,file_data))
  if("db_date" %in% colnames(dlast)) { 
    last_import_date <- dlast[1,db_date] 
    difftime_last_import <- difftime(Sys.time(),last_import_date,units = "day")
    txt_last_import <- paste0("Date of the previous data update: ",last_import_date," (",difftime_last_import," day(s))\n")
  } 
  file_save <- paste0(rep,file_path_sans_ext(file_data),"_last",ifelse(is.null(last_import_date),"",paste0("_",format(last_import_date,"%Y%m%d_%H%M"))),".csv")
  fwrite(dlast,file_save)
}
```


Date of the previous data update: 2021-04-23 12:20:51 (0.000436421966663113 day(s))




```r
ind <- get_birds(log)
d <- get_events(log)
```



## The birds



```r
ind_select <- ind[,.(bird_id,nick_name,taxon,id,ring_id,taxon_eng,taxon_fr,date_start,date_end,number_of_events,nb_day_silence,new,import_date)]
my_kable_print( ind_select,caption="The birds",scroll_width = "600px")
```

<div style="border: 1px solid #ddd; padding: 0px; overflow-y: scroll; height:300px; overflow-x: scroll; width:600px; "><table class="table table-hover" style="font-size: 11px; width: auto !important; margin-left: auto; margin-right: auto;">
<caption style="font-size: initial !important;">The birds</caption>
 <thead>
  <tr>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;position: sticky; top:0; background-color: #FFFFFF;"> bird_id </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;position: sticky; top:0; background-color: #FFFFFF;"> nick_name </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;position: sticky; top:0; background-color: #FFFFFF;"> taxon </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;position: sticky; top:0; background-color: #FFFFFF;"> id </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;position: sticky; top:0; background-color: #FFFFFF;"> ring_id </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;position: sticky; top:0; background-color: #FFFFFF;"> taxon_eng </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;position: sticky; top:0; background-color: #FFFFFF;"> taxon_fr </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;position: sticky; top:0; background-color: #FFFFFF;"> date_start </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;position: sticky; top:0; background-color: #FFFFFF;"> date_end </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;position: sticky; top:0; background-color: #FFFFFF;"> number_of_events </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;position: sticky; top:0; background-color: #FFFFFF;"> nb_day_silence </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;position: sticky; top:0; background-color: #FFFFFF;"> new </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;position: sticky; top:0; background-color: #FFFFFF;"> import_date </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> C00_red </td>
   <td style="text-align:left;"> Bruce </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:right;"> 1427024022 </td>
   <td style="text-align:left;"> [FRP-FS114751] </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> [FRP-EC110531] </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> 2021-02-23 </td>
   <td style="text-align:left;"> 2021-04-17 </td>
   <td style="text-align:right;"> 89 </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> C02_red </td>
   <td style="text-align:left;"> Temanu </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:right;"> 1427025368 </td>
   <td style="text-align:left;"> [FRP-EC110532] </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> 2021-03-24 </td>
   <td style="text-align:left;"> 2021-04-19 </td>
   <td style="text-align:right;"> 45 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> C03_red </td>
   <td style="text-align:left;"> Manurere </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:right;"> 1427025571 </td>
   <td style="text-align:left;"> [FRP-EC110533] </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> 2021-02-24 </td>
   <td style="text-align:left;"> 2021-04-21 </td>
   <td style="text-align:right;"> 106 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> C04_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:right;"> 1427025900 </td>
   <td style="text-align:left;"> [FRP-EC110534] </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> 2021-02-27 </td>
   <td style="text-align:left;"> 2021-04-21 </td>
   <td style="text-align:right;"> 69 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> C05_red </td>
   <td style="text-align:left;"> Heirua </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:right;"> 1427026113 </td>
   <td style="text-align:left;"> [FRP-EC110535] </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> 2021-02-14 </td>
   <td style="text-align:left;"> 2021-04-20 </td>
   <td style="text-align:right;"> 83 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> C06_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:right;"> 1427026804 </td>
   <td style="text-align:left;"> [FRP-EC110536] </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> 2021-02-26 </td>
   <td style="text-align:left;"> 2021-04-21 </td>
   <td style="text-align:right;"> 76 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> C07_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:right;"> 1427027383 </td>
   <td style="text-align:left;"> [FRP-EC110537] </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> 2021-03-01 </td>
   <td style="text-align:left;"> 2021-04-21 </td>
   <td style="text-align:right;"> 89 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> C08_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:right;"> 1427028220 </td>
   <td style="text-align:left;"> [FRP-EC110538] </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> 2021-02-27 </td>
   <td style="text-align:left;"> 2021-04-21 </td>
   <td style="text-align:right;"> 92 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> C09_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:right;"> 1427028910 </td>
   <td style="text-align:left;"> [FRP-EC110539] </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> 2021-02-25 </td>
   <td style="text-align:left;"> 2021-04-19 </td>
   <td style="text-align:right;"> 99 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> C10_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:right;"> 1427029163 </td>
   <td style="text-align:left;"> FRP-EC110540 </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> C11_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:right;"> 1427030305 </td>
   <td style="text-align:left;"> FRP-EC110541 </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> 2021-03-25 </td>
   <td style="text-align:left;"> 2021-04-21 </td>
   <td style="text-align:right;"> 39 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> C12_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:right;"> 1427030482 </td>
   <td style="text-align:left;"> FRP-EC110542 </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> 2021-03-01 </td>
   <td style="text-align:left;"> 2021-04-21 </td>
   <td style="text-align:right;"> 70 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> S01_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Onychoprion fuscatus </td>
   <td style="text-align:right;"> 1427079626 </td>
   <td style="text-align:left;"> FRP-M86802 </td>
   <td style="text-align:left;"> Sooty tern </td>
   <td style="text-align:left;"> Sterne fuligineuse </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> S02_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Onychoprion fuscatus </td>
   <td style="text-align:right;"> 1427080028 </td>
   <td style="text-align:left;"> FRP-M86803 </td>
   <td style="text-align:left;"> Sooty tern </td>
   <td style="text-align:left;"> Sterne fuligineuse </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> S03_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Onychoprion fuscatus </td>
   <td style="text-align:right;"> 1427080447 </td>
   <td style="text-align:left;"> FRP-M86804 </td>
   <td style="text-align:left;"> Sooty tern </td>
   <td style="text-align:left;"> Sterne fuligineuse </td>
   <td style="text-align:left;"> 2021-03-25 </td>
   <td style="text-align:left;"> 2021-04-02 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 21 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> S04_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Onychoprion fuscatus </td>
   <td style="text-align:right;"> 1427080684 </td>
   <td style="text-align:left;"> FRP-M86805 </td>
   <td style="text-align:left;"> Sooty tern </td>
   <td style="text-align:left;"> Sterne fuligineuse </td>
   <td style="text-align:left;"> 2021-02-11 </td>
   <td style="text-align:left;"> 2021-04-18 </td>
   <td style="text-align:right;"> 53 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> S05_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Onychoprion fuscatus </td>
   <td style="text-align:right;"> 1427081105 </td>
   <td style="text-align:left;"> FRP-M86806 </td>
   <td style="text-align:left;"> Sooty tern </td>
   <td style="text-align:left;"> Sterne fuligineuse </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> S06_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Onychoprion fuscatus </td>
   <td style="text-align:right;"> 1427081220 </td>
   <td style="text-align:left;"> FRP-M86807 </td>
   <td style="text-align:left;"> Sooty tern </td>
   <td style="text-align:left;"> Sterne fuligineuse </td>
   <td style="text-align:left;"> 2021-02-12 </td>
   <td style="text-align:left;"> 2021-04-12 </td>
   <td style="text-align:right;"> 35 </td>
   <td style="text-align:right;"> 11 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> S07_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Onychoprion fuscatus </td>
   <td style="text-align:right;"> 1427081443 </td>
   <td style="text-align:left;"> FRP-M86808 </td>
   <td style="text-align:left;"> Sooty tern </td>
   <td style="text-align:left;"> Sterne fuligineuse </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> S08_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Onychoprion fuscatus </td>
   <td style="text-align:right;"> 1427082111 </td>
   <td style="text-align:left;"> FRP-M86809 </td>
   <td style="text-align:left;"> Sooty tern </td>
   <td style="text-align:left;"> Sterne fuligineuse </td>
   <td style="text-align:left;"> 2021-02-05 </td>
   <td style="text-align:left;"> 2021-04-14 </td>
   <td style="text-align:right;"> 44 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> S09_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Onychoprion fuscatus </td>
   <td style="text-align:right;"> 1427082950 </td>
   <td style="text-align:left;"> FRP-M86810 </td>
   <td style="text-align:left;"> Sooty tern </td>
   <td style="text-align:left;"> Sterne fuligineuse </td>
   <td style="text-align:left;"> 2021-01-29 </td>
   <td style="text-align:left;"> 2021-04-20 </td>
   <td style="text-align:right;"> 30 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> S10_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Onychoprion fuscatus </td>
   <td style="text-align:right;"> 1427083089 </td>
   <td style="text-align:left;"> FRP-M86811 </td>
   <td style="text-align:left;"> Sooty tern </td>
   <td style="text-align:left;"> Sterne fuligineuse </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> S11_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Onychoprion fuscatus </td>
   <td style="text-align:right;"> 1427083579 </td>
   <td style="text-align:left;"> FRP-M86812 </td>
   <td style="text-align:left;"> Sooty tern </td>
   <td style="text-align:left;"> Sterne fuligineuse </td>
   <td style="text-align:left;"> 2021-01-27 </td>
   <td style="text-align:left;"> 2021-04-16 </td>
   <td style="text-align:right;"> 40 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> S12_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Onychoprion fuscatus </td>
   <td style="text-align:right;"> 1427083709 </td>
   <td style="text-align:left;"> FRP-M86813 </td>
   <td style="text-align:left;"> Sooty tern </td>
   <td style="text-align:left;"> Sterne fuligineuse </td>
   <td style="text-align:left;"> 2021-02-21 </td>
   <td style="text-align:left;"> 2021-04-20 </td>
   <td style="text-align:right;"> 53 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> P00_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Pluvialis fulva </td>
   <td style="text-align:right;"> 1427030763 </td>
   <td style="text-align:left;"> FRP-M86801 </td>
   <td style="text-align:left;"> Pacific golden plover </td>
   <td style="text-align:left;"> Pluvier fauve </td>
   <td style="text-align:left;"> 2021-03-01 </td>
   <td style="text-align:left;"> 2021-04-21 </td>
   <td style="text-align:right;"> 92 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> P01_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Pluvialis fulva </td>
   <td style="text-align:right;"> 1427031329 </td>
   <td style="text-align:left;"> FRP-M86814 </td>
   <td style="text-align:left;"> Pacific golden plover </td>
   <td style="text-align:left;"> Pluvier fauve </td>
   <td style="text-align:left;"> 2021-02-11 </td>
   <td style="text-align:left;"> 2021-04-21 </td>
   <td style="text-align:right;"> 67 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> P03_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Pluvialis fulva </td>
   <td style="text-align:right;"> 1427031617 </td>
   <td style="text-align:left;"> FRP-M86816 </td>
   <td style="text-align:left;"> Pacific golden plover </td>
   <td style="text-align:left;"> Pluvier fauve </td>
   <td style="text-align:left;"> 2021-03-08 </td>
   <td style="text-align:left;"> 2021-03-31 </td>
   <td style="text-align:right;"> 40 </td>
   <td style="text-align:right;"> 23 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> P04_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Pluvialis fulva </td>
   <td style="text-align:right;"> 1427031920 </td>
   <td style="text-align:left;"> FRP-M86817 </td>
   <td style="text-align:left;"> Pacific golden plover </td>
   <td style="text-align:left;"> Pluvier fauve </td>
   <td style="text-align:left;"> 2021-02-28 </td>
   <td style="text-align:left;"> 2021-04-09 </td>
   <td style="text-align:right;"> 72 </td>
   <td style="text-align:right;"> 14 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> P05_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Pluvialis fulva </td>
   <td style="text-align:right;"> 1427032205 </td>
   <td style="text-align:left;"> FRP-M86818 </td>
   <td style="text-align:left;"> Pacific golden plover </td>
   <td style="text-align:left;"> Pluvier fauve </td>
   <td style="text-align:left;"> 2021-03-07 </td>
   <td style="text-align:left;"> 2021-04-19 </td>
   <td style="text-align:right;"> 74 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> P06_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Pluvialis fulva </td>
   <td style="text-align:right;"> 1427032392 </td>
   <td style="text-align:left;"> FRP-M86819 </td>
   <td style="text-align:left;"> Pacific golden plover </td>
   <td style="text-align:left;"> Pluvier fauve </td>
   <td style="text-align:left;"> 2021-03-06 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:right;"> 94 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> P07_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Pluvialis fulva </td>
   <td style="text-align:right;"> 1427033130 </td>
   <td style="text-align:left;"> FRP-M86820 </td>
   <td style="text-align:left;"> Pacific golden plover </td>
   <td style="text-align:left;"> Pluvier fauve </td>
   <td style="text-align:left;"> 2021-02-27 </td>
   <td style="text-align:left;"> 2021-04-19 </td>
   <td style="text-align:right;"> 99 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> P08_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Pluvialis fulva </td>
   <td style="text-align:right;"> 1427033927 </td>
   <td style="text-align:left;"> FRP-M86821 </td>
   <td style="text-align:left;"> Pacific golden plover </td>
   <td style="text-align:left;"> Pluvier fauve </td>
   <td style="text-align:left;"> 2021-02-26 </td>
   <td style="text-align:left;"> 2021-04-14 </td>
   <td style="text-align:right;"> 80 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> T00_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Tringa incana </td>
   <td style="text-align:right;"> 1427035145 </td>
   <td style="text-align:left;"> FRP-GE43201 </td>
   <td style="text-align:left;"> Wandering tattler </td>
   <td style="text-align:left;"> Chevalier errant </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> T02_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Tringa incana </td>
   <td style="text-align:right;"> 1427036090 </td>
   <td style="text-align:left;"> FRP-GE43203 </td>
   <td style="text-align:left;"> Wandering tattler </td>
   <td style="text-align:left;"> Chevalier errant </td>
   <td style="text-align:left;"> 2021-02-22 </td>
   <td style="text-align:left;"> 2021-04-20 </td>
   <td style="text-align:right;"> 86 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> T03_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Tringa incana </td>
   <td style="text-align:right;"> 1427036786 </td>
   <td style="text-align:left;"> FRP-GE43204 </td>
   <td style="text-align:left;"> Wandering tattler </td>
   <td style="text-align:left;"> Chevalier errant </td>
   <td style="text-align:left;"> 2021-03-09 </td>
   <td style="text-align:left;"> 2021-03-28 </td>
   <td style="text-align:right;"> 38 </td>
   <td style="text-align:right;"> 26 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> T04_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Tringa incana </td>
   <td style="text-align:right;"> 1427037148 </td>
   <td style="text-align:left;"> FRP-GE43205 </td>
   <td style="text-align:left;"> Wandering tattler </td>
   <td style="text-align:left;"> Chevalier errant </td>
   <td style="text-align:left;"> 2021-02-26 </td>
   <td style="text-align:left;"> 2021-04-20 </td>
   <td style="text-align:right;"> 63 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> T05_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Tringa incana </td>
   <td style="text-align:right;"> 1427037306 </td>
   <td style="text-align:left;"> FRP-GE43206 </td>
   <td style="text-align:left;"> Wandering tattler </td>
   <td style="text-align:left;"> Chevalier errant </td>
   <td style="text-align:left;"> 2021-03-15 </td>
   <td style="text-align:left;"> 2021-04-20 </td>
   <td style="text-align:right;"> 45 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> T06_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Tringa incana </td>
   <td style="text-align:right;"> 1427037483 </td>
   <td style="text-align:left;"> FRP-GE43209 </td>
   <td style="text-align:left;"> Wandering tattler </td>
   <td style="text-align:left;"> Chevalier errant </td>
   <td style="text-align:left;"> 2021-03-09 </td>
   <td style="text-align:left;"> 2021-04-19 </td>
   <td style="text-align:right;"> 34 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> T08_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Tringa incana </td>
   <td style="text-align:right;"> 1427037701 </td>
   <td style="text-align:left;"> FRP-GE43208 </td>
   <td style="text-align:left;"> Wandering tattler </td>
   <td style="text-align:left;"> Chevalier errant </td>
   <td style="text-align:left;"> 2021-03-02 </td>
   <td style="text-align:left;"> 2021-04-16 </td>
   <td style="text-align:right;"> 72 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> T09_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Tringa incana </td>
   <td style="text-align:right;"> 1427062016 </td>
   <td style="text-align:left;"> FRP-GE43211 </td>
   <td style="text-align:left;"> Wandering tattler </td>
   <td style="text-align:left;"> Chevalier errant </td>
   <td style="text-align:left;"> 2021-02-26 </td>
   <td style="text-align:left;"> 2021-04-07 </td>
   <td style="text-align:right;"> 60 </td>
   <td style="text-align:right;"> 16 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> T10_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Tringa incana </td>
   <td style="text-align:right;"> 1427062324 </td>
   <td style="text-align:left;"> FRP-GE43212 </td>
   <td style="text-align:left;"> Wandering tattler </td>
   <td style="text-align:left;"> Chevalier errant </td>
   <td style="text-align:left;"> 2021-02-27 </td>
   <td style="text-align:left;"> 2021-04-20 </td>
   <td style="text-align:right;"> 84 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> T11_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Tringa incana </td>
   <td style="text-align:right;"> 1427062799 </td>
   <td style="text-align:left;"> FRP-GE43213 </td>
   <td style="text-align:left;"> Wandering tattler </td>
   <td style="text-align:left;"> Chevalier errant </td>
   <td style="text-align:left;"> 2021-02-24 </td>
   <td style="text-align:left;"> 2021-04-20 </td>
   <td style="text-align:right;"> 69 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> T12_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Tringa incana </td>
   <td style="text-align:right;"> 1427063248 </td>
   <td style="text-align:left;"> FRP-GE43214 </td>
   <td style="text-align:left;"> Wandering tattler </td>
   <td style="text-align:left;"> Chevalier errant </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> T13_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Tringa incana </td>
   <td style="text-align:right;"> 1427063693 </td>
   <td style="text-align:left;"> FRP-GE43215 </td>
   <td style="text-align:left;"> Wandering tattler </td>
   <td style="text-align:left;"> Chevalier errant </td>
   <td style="text-align:left;"> 2021-02-27 </td>
   <td style="text-align:left;"> 2021-04-16 </td>
   <td style="text-align:right;"> 72 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> T14_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Tringa incana </td>
   <td style="text-align:right;"> 1427063998 </td>
   <td style="text-align:left;"> FRP-GE43216 </td>
   <td style="text-align:left;"> Wandering tattler </td>
   <td style="text-align:left;"> Chevalier errant </td>
   <td style="text-align:left;"> 2021-02-28 </td>
   <td style="text-align:left;"> 2021-04-08 </td>
   <td style="text-align:right;"> 67 </td>
   <td style="text-align:right;"> 15 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> T15_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Tringa incana </td>
   <td style="text-align:right;"> 1427076616 </td>
   <td style="text-align:left;"> FRP-GE43217 </td>
   <td style="text-align:left;"> Wandering tattler </td>
   <td style="text-align:left;"> Chevalier errant </td>
   <td style="text-align:left;"> 2021-03-06 </td>
   <td style="text-align:left;"> 2021-04-20 </td>
   <td style="text-align:right;"> 83 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> T16_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Tringa incana </td>
   <td style="text-align:right;"> 1427076894 </td>
   <td style="text-align:left;"> FRP-GE43218 </td>
   <td style="text-align:left;"> Wandering tattler </td>
   <td style="text-align:left;"> Chevalier errant </td>
   <td style="text-align:left;"> 2021-03-09 </td>
   <td style="text-align:left;"> 2021-04-12 </td>
   <td style="text-align:right;"> 61 </td>
   <td style="text-align:right;"> 11 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> T18_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Tringa incana </td>
   <td style="text-align:right;"> 1427085442 </td>
   <td style="text-align:left;"> FRP-GE43220 </td>
   <td style="text-align:left;"> Wandering tattler </td>
   <td style="text-align:left;"> Chevalier errant </td>
   <td style="text-align:left;"> 2021-03-16 </td>
   <td style="text-align:left;"> 2021-04-20 </td>
   <td style="text-align:right;"> 51 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> T19_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Tringa incana </td>
   <td style="text-align:right;"> 1427077109 </td>
   <td style="text-align:left;"> FRP-GE43221 </td>
   <td style="text-align:left;"> Wandering tattler </td>
   <td style="text-align:left;"> Chevalier errant </td>
   <td style="text-align:left;"> 2021-02-19 </td>
   <td style="text-align:left;"> 2021-04-03 </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> T20_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Tringa incana </td>
   <td style="text-align:right;"> 1427077281 </td>
   <td style="text-align:left;"> FRP-GE43222 </td>
   <td style="text-align:left;"> Wandering tattler </td>
   <td style="text-align:left;"> Chevalier errant </td>
   <td style="text-align:left;"> 2021-03-15 </td>
   <td style="text-align:left;"> 2021-04-08 </td>
   <td style="text-align:right;"> 47 </td>
   <td style="text-align:right;"> 15 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> T21_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Tringa incana </td>
   <td style="text-align:right;"> 1427077398 </td>
   <td style="text-align:left;"> FRP-GE43223 </td>
   <td style="text-align:left;"> Wandering tattler </td>
   <td style="text-align:left;"> Chevalier errant </td>
   <td style="text-align:left;"> 2021-03-23 </td>
   <td style="text-align:left;"> 2021-04-16 </td>
   <td style="text-align:right;"> 45 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> T22_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Tringa incana </td>
   <td style="text-align:right;"> 1427077690 </td>
   <td style="text-align:left;"> FRP-GE43224 </td>
   <td style="text-align:left;"> Wandering tattler </td>
   <td style="text-align:left;"> Chevalier errant </td>
   <td style="text-align:left;"> 2021-03-07 </td>
   <td style="text-align:left;"> 2021-04-12 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:right;"> 11 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> T23_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Tringa incana </td>
   <td style="text-align:right;"> 1427077967 </td>
   <td style="text-align:left;"> FRP-GE43225 </td>
   <td style="text-align:left;"> Wandering tattler </td>
   <td style="text-align:left;"> Chevalier errant </td>
   <td style="text-align:left;"> 2021-02-26 </td>
   <td style="text-align:left;"> 2021-04-18 </td>
   <td style="text-align:right;"> 78 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> T24_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Tringa incana </td>
   <td style="text-align:right;"> 1427078483 </td>
   <td style="text-align:left;"> FRP-GE43226 </td>
   <td style="text-align:left;"> Wandering tattler </td>
   <td style="text-align:left;"> Chevalier errant </td>
   <td style="text-align:left;"> 2021-03-03 </td>
   <td style="text-align:left;"> 2021-04-20 </td>
   <td style="text-align:right;"> 86 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> T25_red </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Tringa incana </td>
   <td style="text-align:right;"> 1427078811 </td>
   <td style="text-align:left;"> FRP-GE43227 </td>
   <td style="text-align:left;"> Wandering tattler </td>
   <td style="text-align:left;"> Chevalier errant </td>
   <td style="text-align:left;"> 2021-02-22 </td>
   <td style="text-align:left;"> 2021-04-20 </td>
   <td style="text-align:right;"> 79 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:left;"> 2021-04-23 </td>
  </tr>
</tbody>
</table></div>

## The events

The events correspond to the whole bird's location get from movebank. 


```r
my_kable_print(d[1:100,],caption="The event data",scroll_width = "600px")
```

<div style="border: 1px solid #ddd; padding: 0px; overflow-y: scroll; height:300px; overflow-x: scroll; width:600px; "><table class="table table-hover" style="font-size: 11px; width: auto !important; margin-left: auto; margin-right: auto;">
<caption style="font-size: initial !important;">The event data</caption>
 <thead>
  <tr>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;position: sticky; top:0; background-color: #FFFFFF;"> event_id </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;position: sticky; top:0; background-color: #FFFFFF;"> individual_id </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;position: sticky; top:0; background-color: #FFFFFF;"> bird_id </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;position: sticky; top:0; background-color: #FFFFFF;"> nick_name </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;position: sticky; top:0; background-color: #FFFFFF;"> taxon </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;position: sticky; top:0; background-color: #FFFFFF;"> timestamp </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;position: sticky; top:0; background-color: #FFFFFF;"> location_lat </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;position: sticky; top:0; background-color: #FFFFFF;"> location_long </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;position: sticky; top:0; background-color: #FFFFFF;"> tag_id </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;position: sticky; top:0; background-color: #FFFFFF;"> taxon_fr </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;position: sticky; top:0; background-color: #FFFFFF;"> taxon_eng </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;position: sticky; top:0; background-color: #FFFFFF;"> date </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;position: sticky; top:0; background-color: #FFFFFF;"> julian </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;position: sticky; top:0; background-color: #FFFFFF;"> hour </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;position: sticky; top:0; background-color: #FFFFFF;"> hour_float </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;position: sticky; top:0; background-color: #FFFFFF;"> import_date </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;position: sticky; top:0; background-color: #FFFFFF;"> new </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;position: sticky; top:0; background-color: #FFFFFF;"> db_date </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 1427025072_20210223220200 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-02-23 22:02:00.000 </td>
   <td style="text-align:right;"> -15.10084 </td>
   <td style="text-align:right;"> -147.9408 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-02-23 </td>
   <td style="text-align:right;"> 54 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.03 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210224000800 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-02-24 00:08:00.000 </td>
   <td style="text-align:right;"> -15.11363 </td>
   <td style="text-align:right;"> -147.9413 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-02-24 </td>
   <td style="text-align:right;"> 55 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.03 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210224220200 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-02-24 22:02:00.000 </td>
   <td style="text-align:right;"> -15.09659 </td>
   <td style="text-align:right;"> -147.9376 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-02-24 </td>
   <td style="text-align:right;"> 55 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.03 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210225220100 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-02-25 22:01:00.000 </td>
   <td style="text-align:right;"> -15.11462 </td>
   <td style="text-align:right;"> -147.9408 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-02-25 </td>
   <td style="text-align:right;"> 56 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.03 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210226000800 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-02-26 00:08:00.000 </td>
   <td style="text-align:right;"> -15.11350 </td>
   <td style="text-align:right;"> -147.9413 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-02-26 </td>
   <td style="text-align:right;"> 57 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.03 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210226100100 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-02-26 10:01:00.000 </td>
   <td style="text-align:right;"> -15.13037 </td>
   <td style="text-align:right;"> -147.9367 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-02-26 </td>
   <td style="text-align:right;"> 57 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:right;"> 10.03 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210226220100 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-02-26 22:01:00.000 </td>
   <td style="text-align:right;"> -15.09917 </td>
   <td style="text-align:right;"> -147.9411 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-02-26 </td>
   <td style="text-align:right;"> 57 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.03 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210226232000 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-02-26 23:20:00.000 </td>
   <td style="text-align:right;"> -15.09912 </td>
   <td style="text-align:right;"> -147.9410 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-02-26 </td>
   <td style="text-align:right;"> 57 </td>
   <td style="text-align:right;"> 23 </td>
   <td style="text-align:right;"> 23.03 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210227091400 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-02-27 09:14:00.000 </td>
   <td style="text-align:right;"> -15.10466 </td>
   <td style="text-align:right;"> -147.9396 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-02-27 </td>
   <td style="text-align:right;"> 58 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 9.03 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210228220100 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-02-28 22:01:00.000 </td>
   <td style="text-align:right;"> -15.11075 </td>
   <td style="text-align:right;"> -147.9410 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-02-28 </td>
   <td style="text-align:right;"> 59 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.03 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210301220000 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-01 22:00:00.000 </td>
   <td style="text-align:right;"> -15.11226 </td>
   <td style="text-align:right;"> -147.9402 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-01 </td>
   <td style="text-align:right;"> 60 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210302074800 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-02 07:48:00.000 </td>
   <td style="text-align:right;"> -15.12123 </td>
   <td style="text-align:right;"> -147.9390 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-02 </td>
   <td style="text-align:right;"> 61 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 7.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210302211300 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-02 21:13:00.000 </td>
   <td style="text-align:right;"> -15.10342 </td>
   <td style="text-align:right;"> -147.9425 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-02 </td>
   <td style="text-align:right;"> 61 </td>
   <td style="text-align:right;"> 21 </td>
   <td style="text-align:right;"> 21.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210303204900 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-03 20:49:00.000 </td>
   <td style="text-align:right;"> -15.10968 </td>
   <td style="text-align:right;"> -147.9421 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-03 </td>
   <td style="text-align:right;"> 62 </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:right;"> 20.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210304202600 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-04 20:26:00.000 </td>
   <td style="text-align:right;"> -15.10196 </td>
   <td style="text-align:right;"> -147.9423 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-04 </td>
   <td style="text-align:right;"> 63 </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:right;"> 20.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210305063700 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-05 06:37:00.000 </td>
   <td style="text-align:right;"> -15.11397 </td>
   <td style="text-align:right;"> -147.9413 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-05 </td>
   <td style="text-align:right;"> 64 </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 6.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210306061300 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-06 06:13:00.000 </td>
   <td style="text-align:right;"> -15.12080 </td>
   <td style="text-align:right;"> -147.9390 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-06 </td>
   <td style="text-align:right;"> 65 </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 6.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210307055000 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-07 05:50:00.000 </td>
   <td style="text-align:right;"> -15.11402 </td>
   <td style="text-align:right;"> -147.9413 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-07 </td>
   <td style="text-align:right;"> 66 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 5.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210308052800 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-08 05:28:00.000 </td>
   <td style="text-align:right;"> -15.11397 </td>
   <td style="text-align:right;"> -147.9411 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-08 </td>
   <td style="text-align:right;"> 67 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 5.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210308220100 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-08 22:01:00.000 </td>
   <td style="text-align:right;"> -15.11093 </td>
   <td style="text-align:right;"> -147.9411 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-08 </td>
   <td style="text-align:right;"> 67 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210309050400 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-09 05:04:00.000 </td>
   <td style="text-align:right;"> -15.11397 </td>
   <td style="text-align:right;"> -147.9412 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-09 </td>
   <td style="text-align:right;"> 68 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 5.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210310044000 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-10 04:40:00.000 </td>
   <td style="text-align:right;"> -15.11273 </td>
   <td style="text-align:right;"> -147.9415 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-10 </td>
   <td style="text-align:right;"> 69 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 4.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210311041600 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-11 04:16:00.000 </td>
   <td style="text-align:right;"> -15.11462 </td>
   <td style="text-align:right;"> -147.9426 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-11 </td>
   <td style="text-align:right;"> 70 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 4.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210311135300 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-11 13:53:00.000 </td>
   <td style="text-align:right;"> -15.11465 </td>
   <td style="text-align:right;"> -147.9426 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-11 </td>
   <td style="text-align:right;"> 70 </td>
   <td style="text-align:right;"> 13 </td>
   <td style="text-align:right;"> 13.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210312220100 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-12 22:01:00.000 </td>
   <td style="text-align:right;"> -15.09663 </td>
   <td style="text-align:right;"> -147.9374 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-12 </td>
   <td style="text-align:right;"> 71 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210313220100 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-13 22:01:00.000 </td>
   <td style="text-align:right;"> -15.09736 </td>
   <td style="text-align:right;"> -147.9374 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-13 </td>
   <td style="text-align:right;"> 72 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210314040900 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-14 04:09:00.000 </td>
   <td style="text-align:right;"> -15.11470 </td>
   <td style="text-align:right;"> -147.9429 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-14 </td>
   <td style="text-align:right;"> 73 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 4.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210314172800 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-14 17:28:00.000 </td>
   <td style="text-align:right;"> -15.10968 </td>
   <td style="text-align:right;"> -147.9422 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-14 </td>
   <td style="text-align:right;"> 73 </td>
   <td style="text-align:right;"> 17 </td>
   <td style="text-align:right;"> 17.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210314220200 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-14 22:02:00.000 </td>
   <td style="text-align:right;"> -15.09668 </td>
   <td style="text-align:right;"> -147.9374 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-14 </td>
   <td style="text-align:right;"> 73 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210315032300 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-15 03:23:00.000 </td>
   <td style="text-align:right;"> -15.10105 </td>
   <td style="text-align:right;"> -147.9420 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-15 </td>
   <td style="text-align:right;"> 74 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 3.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210315032400 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-15 03:24:00.000 </td>
   <td style="text-align:right;"> -15.10108 </td>
   <td style="text-align:right;"> -147.9420 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-15 </td>
   <td style="text-align:right;"> 74 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 3.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210315220000 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-15 22:00:00.000 </td>
   <td style="text-align:right;"> -15.10342 </td>
   <td style="text-align:right;"> -147.9426 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-15 </td>
   <td style="text-align:right;"> 74 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210316155400 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-16 15:54:00.000 </td>
   <td style="text-align:right;"> -15.12050 </td>
   <td style="text-align:right;"> -147.9383 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-16 </td>
   <td style="text-align:right;"> 75 </td>
   <td style="text-align:right;"> 15 </td>
   <td style="text-align:right;"> 15.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210316220200 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-16 22:02:00.000 </td>
   <td style="text-align:right;"> -15.09676 </td>
   <td style="text-align:right;"> -147.9377 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-16 </td>
   <td style="text-align:right;"> 75 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210317220400 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-17 22:04:00.000 </td>
   <td style="text-align:right;"> -15.09663 </td>
   <td style="text-align:right;"> -147.9374 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-17 </td>
   <td style="text-align:right;"> 76 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210318155600 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-18 15:56:00.000 </td>
   <td style="text-align:right;"> -15.11457 </td>
   <td style="text-align:right;"> -147.9417 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-18 </td>
   <td style="text-align:right;"> 77 </td>
   <td style="text-align:right;"> 15 </td>
   <td style="text-align:right;"> 15.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210318220100 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-18 22:01:00.000 </td>
   <td style="text-align:right;"> -15.09702 </td>
   <td style="text-align:right;"> -147.9382 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-18 </td>
   <td style="text-align:right;"> 77 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210319014800 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-19 01:48:00.000 </td>
   <td style="text-align:right;"> -15.11350 </td>
   <td style="text-align:right;"> -147.9415 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-19 </td>
   <td style="text-align:right;"> 78 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210319014900 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-19 01:49:00.000 </td>
   <td style="text-align:right;"> -15.11351 </td>
   <td style="text-align:right;"> -147.9415 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-19 </td>
   <td style="text-align:right;"> 78 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210319220100 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-19 22:01:00.000 </td>
   <td style="text-align:right;"> -15.09706 </td>
   <td style="text-align:right;"> -147.9376 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-19 </td>
   <td style="text-align:right;"> 78 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210320142200 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-20 14:22:00.000 </td>
   <td style="text-align:right;"> -15.12054 </td>
   <td style="text-align:right;"> -147.9387 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-20 </td>
   <td style="text-align:right;"> 79 </td>
   <td style="text-align:right;"> 14 </td>
   <td style="text-align:right;"> 14.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210320220200 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-20 22:02:00.000 </td>
   <td style="text-align:right;"> -15.09646 </td>
   <td style="text-align:right;"> -147.9380 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-20 </td>
   <td style="text-align:right;"> 79 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210322220000 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-22 22:00:00.000 </td>
   <td style="text-align:right;"> -15.10187 </td>
   <td style="text-align:right;"> -147.9425 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-22 </td>
   <td style="text-align:right;"> 81 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210323001500 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-23 00:15:00.000 </td>
   <td style="text-align:right;"> -15.11346 </td>
   <td style="text-align:right;"> -147.9415 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-23 </td>
   <td style="text-align:right;"> 82 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210323001600 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-23 00:16:00.000 </td>
   <td style="text-align:right;"> -15.11347 </td>
   <td style="text-align:right;"> -147.9415 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-23 </td>
   <td style="text-align:right;"> 82 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210323220100 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-23 22:01:00.000 </td>
   <td style="text-align:right;"> -15.10204 </td>
   <td style="text-align:right;"> -147.9426 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-23 </td>
   <td style="text-align:right;"> 82 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210324124900 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-24 12:49:00.000 </td>
   <td style="text-align:right;"> -15.12058 </td>
   <td style="text-align:right;"> -147.9385 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-24 </td>
   <td style="text-align:right;"> 83 </td>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:right;"> 12.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210325220000 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-25 22:00:00.000 </td>
   <td style="text-align:right;"> -15.10174 </td>
   <td style="text-align:right;"> -147.9427 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-25 </td>
   <td style="text-align:right;"> 84 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210326125100 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-26 12:51:00.000 </td>
   <td style="text-align:right;"> -15.12088 </td>
   <td style="text-align:right;"> -147.9393 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-26 </td>
   <td style="text-align:right;"> 85 </td>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:right;"> 12.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210326220200 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-26 22:02:00.000 </td>
   <td style="text-align:right;"> -15.09689 </td>
   <td style="text-align:right;"> -147.9372 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-26 </td>
   <td style="text-align:right;"> 85 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210327220300 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-27 22:03:00.000 </td>
   <td style="text-align:right;"> -15.09788 </td>
   <td style="text-align:right;"> -147.9380 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-27 </td>
   <td style="text-align:right;"> 86 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210328111500 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-28 11:15:00.000 </td>
   <td style="text-align:right;"> -15.12148 </td>
   <td style="text-align:right;"> -147.9394 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-28 </td>
   <td style="text-align:right;"> 87 </td>
   <td style="text-align:right;"> 11 </td>
   <td style="text-align:right;"> 11.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210328220000 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-28 22:00:00.000 </td>
   <td style="text-align:right;"> -15.09771 </td>
   <td style="text-align:right;"> -147.9380 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-28 </td>
   <td style="text-align:right;"> 87 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210329220200 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-29 22:02:00.000 </td>
   <td style="text-align:right;"> -15.09676 </td>
   <td style="text-align:right;"> -147.9375 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-29 </td>
   <td style="text-align:right;"> 88 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210330211800 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-30 21:18:00.000 </td>
   <td style="text-align:right;"> -15.09758 </td>
   <td style="text-align:right;"> -147.9381 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-30 </td>
   <td style="text-align:right;"> 89 </td>
   <td style="text-align:right;"> 21 </td>
   <td style="text-align:right;"> 21.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210330220100 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-30 22:01:00.000 </td>
   <td style="text-align:right;"> -15.09775 </td>
   <td style="text-align:right;"> -147.9380 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-30 </td>
   <td style="text-align:right;"> 89 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210331102900 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-31 10:29:00.000 </td>
   <td style="text-align:right;"> -15.12174 </td>
   <td style="text-align:right;"> -147.9385 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-31 </td>
   <td style="text-align:right;"> 90 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:right;"> 10.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210331103000 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-31 10:30:00.000 </td>
   <td style="text-align:right;"> -15.12175 </td>
   <td style="text-align:right;"> -147.9385 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-31 </td>
   <td style="text-align:right;"> 90 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:right;"> 10.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210331220100 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-31 22:01:00.000 </td>
   <td style="text-align:right;"> -15.09651 </td>
   <td style="text-align:right;"> -147.9372 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-31 </td>
   <td style="text-align:right;"> 90 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210401220000 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-04-01 22:00:00.000 </td>
   <td style="text-align:right;"> -15.10208 </td>
   <td style="text-align:right;"> -147.9425 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-04-01 </td>
   <td style="text-align:right;"> 91 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.07 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210402220200 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-04-02 22:02:00.000 </td>
   <td style="text-align:right;"> -15.09668 </td>
   <td style="text-align:right;"> -147.9374 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-04-02 </td>
   <td style="text-align:right;"> 92 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.07 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210403094500 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-04-03 09:45:00.000 </td>
   <td style="text-align:right;"> -15.11397 </td>
   <td style="text-align:right;"> -147.9413 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-04-03 </td>
   <td style="text-align:right;"> 93 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 9.07 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210403193700 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-04-03 19:37:00.000 </td>
   <td style="text-align:right;"> -15.09775 </td>
   <td style="text-align:right;"> -147.9375 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-04-03 </td>
   <td style="text-align:right;"> 93 </td>
   <td style="text-align:right;"> 19 </td>
   <td style="text-align:right;"> 19.07 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210403193800 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-04-03 19:38:00.000 </td>
   <td style="text-align:right;"> -15.09775 </td>
   <td style="text-align:right;"> -147.9376 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-04-03 </td>
   <td style="text-align:right;"> 93 </td>
   <td style="text-align:right;"> 19 </td>
   <td style="text-align:right;"> 19.07 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210403220100 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-04-03 22:01:00.000 </td>
   <td style="text-align:right;"> -15.10457 </td>
   <td style="text-align:right;"> -147.9396 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-04-03 </td>
   <td style="text-align:right;"> 93 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.07 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210404220300 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-04-04 22:03:00.000 </td>
   <td style="text-align:right;"> -15.09672 </td>
   <td style="text-align:right;"> -147.9374 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-04-04 </td>
   <td style="text-align:right;"> 94 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.07 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210405081100 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-04-05 08:11:00.000 </td>
   <td style="text-align:right;"> -15.11410 </td>
   <td style="text-align:right;"> -147.9407 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-04-05 </td>
   <td style="text-align:right;"> 95 </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 8.07 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210406220200 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-04-06 22:02:00.000 </td>
   <td style="text-align:right;"> -15.09702 </td>
   <td style="text-align:right;"> -147.9380 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-04-06 </td>
   <td style="text-align:right;"> 96 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.07 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210407081100 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-04-07 08:11:00.000 </td>
   <td style="text-align:right;"> -15.11393 </td>
   <td style="text-align:right;"> -147.9412 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-04-07 </td>
   <td style="text-align:right;"> 97 </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 8.07 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210407180600 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-04-07 18:06:00.000 </td>
   <td style="text-align:right;"> -15.09672 </td>
   <td style="text-align:right;"> -147.9373 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-04-07 </td>
   <td style="text-align:right;"> 97 </td>
   <td style="text-align:right;"> 18 </td>
   <td style="text-align:right;"> 18.07 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210407180700 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-04-07 18:07:00.000 </td>
   <td style="text-align:right;"> -15.09675 </td>
   <td style="text-align:right;"> -147.9373 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-04-07 </td>
   <td style="text-align:right;"> 97 </td>
   <td style="text-align:right;"> 18 </td>
   <td style="text-align:right;"> 18.07 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210407220100 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-04-07 22:01:00.000 </td>
   <td style="text-align:right;"> -15.09659 </td>
   <td style="text-align:right;"> -147.9375 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-04-07 </td>
   <td style="text-align:right;"> 97 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.07 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210409063800 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-04-09 06:38:00.000 </td>
   <td style="text-align:right;"> -15.11402 </td>
   <td style="text-align:right;"> -147.9412 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-04-09 </td>
   <td style="text-align:right;"> 99 </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 6.07 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210409220100 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-04-09 22:01:00.000 </td>
   <td style="text-align:right;"> -15.09689 </td>
   <td style="text-align:right;"> -147.9377 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-04-09 </td>
   <td style="text-align:right;"> 99 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.07 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210410220100 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-04-10 22:01:00.000 </td>
   <td style="text-align:right;"> -15.09668 </td>
   <td style="text-align:right;"> -147.9373 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-04-10 </td>
   <td style="text-align:right;"> 100 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.07 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210411064100 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-04-11 06:41:00.000 </td>
   <td style="text-align:right;"> -15.11402 </td>
   <td style="text-align:right;"> -147.9411 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-04-11 </td>
   <td style="text-align:right;"> 101 </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 6.07 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210411163300 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-04-11 16:33:00.000 </td>
   <td style="text-align:right;"> -15.09779 </td>
   <td style="text-align:right;"> -147.9371 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-04-11 </td>
   <td style="text-align:right;"> 101 </td>
   <td style="text-align:right;"> 16 </td>
   <td style="text-align:right;"> 16.07 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210411163400 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-04-11 16:34:00.000 </td>
   <td style="text-align:right;"> -15.09782 </td>
   <td style="text-align:right;"> -147.9371 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-04-11 </td>
   <td style="text-align:right;"> 101 </td>
   <td style="text-align:right;"> 16 </td>
   <td style="text-align:right;"> 16.07 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210411220100 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-04-11 22:01:00.000 </td>
   <td style="text-align:right;"> -15.09672 </td>
   <td style="text-align:right;"> -147.9374 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-04-11 </td>
   <td style="text-align:right;"> 101 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.07 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210412220000 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-04-12 22:00:00.000 </td>
   <td style="text-align:right;"> -15.11389 </td>
   <td style="text-align:right;"> -147.9423 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-04-12 </td>
   <td style="text-align:right;"> 102 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.07 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210413220200 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-04-13 22:02:00.000 </td>
   <td style="text-align:right;"> -15.09668 </td>
   <td style="text-align:right;"> -147.9374 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-04-13 </td>
   <td style="text-align:right;"> 103 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.07 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210414220200 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-04-14 22:02:00.000 </td>
   <td style="text-align:right;"> -15.09689 </td>
   <td style="text-align:right;"> -147.9375 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-04-14 </td>
   <td style="text-align:right;"> 104 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.07 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210415050900 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-04-15 05:09:00.000 </td>
   <td style="text-align:right;"> -15.11389 </td>
   <td style="text-align:right;"> -147.9411 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-04-15 </td>
   <td style="text-align:right;"> 105 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 5.07 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210415150000 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-04-15 15:00:00.000 </td>
   <td style="text-align:right;"> -15.11389 </td>
   <td style="text-align:right;"> -147.9411 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-04-15 </td>
   <td style="text-align:right;"> 105 </td>
   <td style="text-align:right;"> 15 </td>
   <td style="text-align:right;"> 15.07 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210415150100 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-04-15 15:01:00.000 </td>
   <td style="text-align:right;"> -15.11388 </td>
   <td style="text-align:right;"> -147.9411 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-04-15 </td>
   <td style="text-align:right;"> 105 </td>
   <td style="text-align:right;"> 15 </td>
   <td style="text-align:right;"> 15.07 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210415220100 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-04-15 22:01:00.000 </td>
   <td style="text-align:right;"> -15.09694 </td>
   <td style="text-align:right;"> -147.9375 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-04-15 </td>
   <td style="text-align:right;"> 105 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.07 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210416220100 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-04-16 22:01:00.000 </td>
   <td style="text-align:right;"> -15.09681 </td>
   <td style="text-align:right;"> -147.9375 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-04-16 </td>
   <td style="text-align:right;"> 106 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.07 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210417033200 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-04-17 03:32:00.000 </td>
   <td style="text-align:right;"> -15.10998 </td>
   <td style="text-align:right;"> -147.9422 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-04-17 </td>
   <td style="text-align:right;"> 107 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 3.07 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210417033300 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-04-17 03:33:00.000 </td>
   <td style="text-align:right;"> -15.11000 </td>
   <td style="text-align:right;"> -147.9422 </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-04-17 </td>
   <td style="text-align:right;"> 107 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 3.07 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210312100000 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-12 10:00:00.000 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-12 </td>
   <td style="text-align:right;"> 71 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:right;"> 10.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210312220000 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-12 22:00:00.000 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-12 </td>
   <td style="text-align:right;"> 71 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210313100000 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-13 10:00:00.000 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-13 </td>
   <td style="text-align:right;"> 72 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:right;"> 10.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210313220000 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-13 22:00:00.000 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-13 </td>
   <td style="text-align:right;"> 72 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210314100000 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-14 10:00:00.000 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-14 </td>
   <td style="text-align:right;"> 73 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:right;"> 10.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210314220000 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-14 22:00:00.000 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-14 </td>
   <td style="text-align:right;"> 73 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210315100000 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-15 10:00:00.000 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-15 </td>
   <td style="text-align:right;"> 74 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:right;"> 10.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210315220000 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-15 22:00:00.000 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-15 </td>
   <td style="text-align:right;"> 74 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210316100000 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-16 10:00:00.000 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-16 </td>
   <td style="text-align:right;"> 75 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:right;"> 10.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210316220000 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-16 22:00:00.000 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-16 </td>
   <td style="text-align:right;"> 75 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 22.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1427025072_20210317100000 </td>
   <td style="text-align:right;"> 1427025072 </td>
   <td style="text-align:left;"> C01_red </td>
   <td style="text-align:left;"> Teraimarama </td>
   <td style="text-align:left;"> Numenius tahitiensis </td>
   <td style="text-align:left;"> 2021-03-17 10:00:00.000 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 1387222390 </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> 2021-03-17 </td>
   <td style="text-align:right;"> 76 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:right;"> 10.05 </td>
   <td style="text-align:left;"> 2021-04-22 </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> 2021-04-23 14:21:31 </td>
  </tr>
</tbody>
</table></div>


# Summary of data

## The birds


In French Polynesia, we deployed Icarus GPS 5g beacon on 56 birds of four species, three shorebirds (13 Bristle-thighed Curlew, 8 Pacific Golden Plover, 23 Wandering Tattler), and 12 Sooty Tern. 




```r
summary_ind <- summary_new_ind(ind)

nb_birds <- sum(summary_ind$nb_birds)

nb_birds_5days <- sum(summary_ind$nb_birds_5days)
nb_birds_10days <- sum(summary_ind$nb_birds_10days)

prop_5days <-  round(nb_birds_5days/nb_birds,2)
prop_10days <- round(nb_birds_10days/nb_birds,2)

my_kable_print(summary_ind,caption="The summary of number of birds",scroll_width = "600px",scroll=FALSE)
```

<table class="table table-hover" style="font-size: 11px; width: auto !important; margin-left: auto; margin-right: auto;">
<caption style="font-size: initial !important;">The summary of number of birds</caption>
 <thead>
  <tr>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> taxon_eng </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> taxon_fr </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> nb_birds </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> nb_birds_5days </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> prop_5days </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> nb_birds_10days </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> prop_10days </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Bristle-thighed curlew </td>
   <td style="text-align:left;"> Courlis d'Alaska </td>
   <td style="text-align:right;"> 11 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:right;"> 0.91 </td>
   <td style="text-align:right;"> 11 </td>
   <td style="text-align:right;"> 1.00 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Sooty tern </td>
   <td style="text-align:left;"> Sterne fuligineuse </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 0.43 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 0.71 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Pacific golden plover </td>
   <td style="text-align:left;"> Pluvier fauve </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 0.62 </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 0.75 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Wandering tattler </td>
   <td style="text-align:left;"> Chevalier errant </td>
   <td style="text-align:right;"> 21 </td>
   <td style="text-align:right;"> 11 </td>
   <td style="text-align:right;"> 0.52 </td>
   <td style="text-align:right;"> 14 </td>
   <td style="text-align:right;"> 0.67 </td>
  </tr>
</tbody>
</table>



Among these 56 birds, __$47$__ birds with Icarus GPS beacons sent to at least one location. In the last five days, __$36$__ beacons ($77\%$) sent data, and for the last five days, __$29$__ beacons ($62\%$).

There would seem to be a species effect on the time since the last location. 



```r
ggplot_silence(ind)
```

<div class="figure" style="text-align: center">
<img src="importing_dataGPS_files/figure-html/fig.silence-1.png" alt="Distrubiton of the number of days before after location by species" width="70%" />
<p class="caption">Distrubiton of the number of days before after location by species</p>
</div>


## The new events



```r
nbline <- nrow(d)
nbloc <- nrow(d[!(is.na(location_lat))])

d_tax <- fread(paste0(rep,"data/taxon.csv"))
vec_tax_eng <- d_tax[taxon %in% unique(d$taxon),taxon_eng]
vec_tax<- d_tax[taxon %in% unique(d$taxon),taxon]
```

In the events database, there are $4934$ data, but some do not have a valid location. 
There are __$3001$__ data with location, that corresponds to $61\%$.



```r
  sne <- summary_new_events(d)
if(is.null(sne)) nb_new <- 0 else nb_new <- sum(sne$nb_new_events)
```

There is __$0$__ new data since the last update NA. 




## The events by day


```r
  cap_txt <- paste0("The bird locations by day for the ",vec_tax_eng)
```



```r
data_by_day(d,ind,vec_tax)
```

<div class="figure" style="text-align: center">
<img src="importing_dataGPS_files/figure-html/bird_day-1.png" alt="The bird locations by day for the Wandering tattler" width="100%" />
<p class="caption">The bird locations by day for the Wandering tattler</p>
</div><div class="figure" style="text-align: center">
<img src="importing_dataGPS_files/figure-html/bird_day-2.png" alt="The bird locations by day for the Bristle-thighed curlew" width="100%" />
<p class="caption">The bird locations by day for the Bristle-thighed curlew</p>
</div><div class="figure" style="text-align: center">
<img src="importing_dataGPS_files/figure-html/bird_day-3.png" alt="The bird locations by day for the Pacific golden plover" width="100%" />
<p class="caption">The bird locations by day for the Pacific golden plover</p>
</div><div class="figure" style="text-align: center">
<img src="importing_dataGPS_files/figure-html/bird_day-4.png" alt="The bird locations by day for the Sooty tern" width="100%" />
<p class="caption">The bird locations by day for the Sooty tern</p>
</div>



