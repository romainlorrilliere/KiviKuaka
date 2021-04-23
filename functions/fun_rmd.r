





importing_rmd <- function(file.rmd="importing_data_update.rmd",file.out="importing_dataGPS",rep.out="output_html",format_output="html",file.data="data/data_kivikuaka_events.csv",mb_user = "romainlorrilliere",mb_pw = "xxx",save.fig=FALSE,render.clean=TRUE) {

    format <- paste0(format_output,"_document")
    if(!is.null(rep.out)) file.out <- paste0(rep.out,"/",file.out)

    rep <- paste0(getwd(),"/")

    file.rmd <- paste0(rep,"/rmd/",file.rmd)
    cat("rmd :",file.rmd,"\n")
    cat("file.data :",file.data,"\n")
    cat("rep:", rep,"\n")
    cat("mb_user:",mb_user,"\n")
    cat("mb_pw:", mb_pw,'\n')
    cat("output :",file.out,"\n")
    if(!(rep.out) %in% dir()) {
         cat("\n Le repertoire de sortie:",rep.out,"est manquant\n")
         dir.create(rep.out,showWarnings=FALSE)
         cat("\n Répertoire créer !!\n")
     }

      rmarkdown::render(file.rmd,output_file=file.out,output_dir=rep.out,output_format = format,clean=render.clean,encoding="utf-8",params = list(set_rep = rep, set_file_data = file.data,set_mb_user=mb_user,set_mb_pw= mb_pw,set_save_fig = save.fig))

     cat("DONE !!!\n")


}






exploration_rmd <- function(file.rmd="exploration_dataGPS.rmd",file.out="exploration_dataGPS",rep.out="output_html",format_output="html",file.data="C:/git/KiviKuaka/",save.fig=FALSE,render.clean=TRUE) {

    format <- paste0(format_output,"_document")
    if(!is.null(rep.out)) file.out <- paste0(rep.out,"/",file.out)

    rep <- getwd()

    cat("rmd :",file.rmd,"\n")
    cat("file.data :",file.data,"\n")
    cat("rep:", rep,"\n")
    cat("output :",file.out,"\n")
    if(!(rep.out) %in% dir()) {
         cat("\n Le repertoire de sortie:",rep.out,"est manquant\n")
         dir.create(rep.out,showWarnings=FALSE)
         cat("\n Répertoire créer !!\n")
     }

      rmarkdown::render(file.rmd,output_file=file.out,output_dir=rep.out,output_format = format,clean=render.clean,encoding="utf-8",params = list(set_rep = rep, set_file_data = file.data,set_save_fig = save.fig))

     cat("DONE !!!\n")


}


