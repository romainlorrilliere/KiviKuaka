
vecPackage=c("rmarkdown","ff")
ip <- installed.packages()[,1]

for(p in vecPackage){
    if (!(p %in% ip))
        install.packages(pkgs=p,repos = "https://pbil.univ-lyon1.fr/CRAN/",dependencies=TRUE)
    library(p,character.only = TRUE)

}



output.move <- function(rep.out="documentations/",file.out,file.rmd) {
    from <- "rmd/"           #Current path of your folder
    to   <- rep.out            #Path you want to move it.
    rep_fig <- paste0(file.out,"_files")

    path1 <- paste0(from,rep_fig)
    path2 <- paste0(to,rep_fig)

    if(rep_fig %in% dir(to))
       unlink(path2,recursive=TRUE)


    file.copy(from=path1, to=to, overwrite = TRUE, recursive = TRUE, copy.mode = TRUE)
    unlink(path1,recursive=TRUE)


    path1 <- paste0(from,file.out,".html")
    path2 <- paste0(to,file.out,".html")
    file.move(path1,path2)


    path1 <- paste0(from,file.out,".md")
    path2 <- paste0(to,file.out,".md")

    if(paste0(file.out,".md") %in% dir(from))
        file.move(path1,path2)

    path1 <- paste0(from,file_path_sans_ext(file.rmd),".utf8.md")
    file.remove(path1)

    path1 <- paste0(from,file_path_sans_ext(file.rmd),".knit.md")
    file.remove(path1)


}


importing_rmd <- function(file.rmd="importing_data_update.rmd",file.out="importing_dataGPS",rep.out="documentations",format_output="html",file.data="data/data_kivikuaka_events.csv",mb_user = "romainlorrilliere",mb_pw = "xxx",nb_previous_day = 30,id_previous_import="xxx",save.fig=FALSE,render.clean=TRUE) {

    format <- paste0(format_output,"_document")
##    if(!is.null(rep.out)) file.out <- paste0(rep.out,"/",file.out)

    rep <- paste0(getwd(),"/")

    path.rmd <- paste0(rep,"/rmd/",file.rmd)
    cat("rmd :",path.rmd,"\n")
    cat("file.data :",file.data,"\n")
    cat("rep:", rep,"\n")
    cat("mb_user:",mb_user,"\n")
    cat("mb_pw:", mb_pw,"\n")
    cat("nb_previous_day:", nb_previous_day,"\n")
    cat("id_previous_import:", id_previous_import,"\n")
    cat("output :",file.out,"\n")
    cat("format :",format,"\n")

      rmarkdown::render(path.rmd,output_file=file.out,output_format = format,clean=render.clean,encoding="utf-8",params = list(set_rep = rep, set_file_data = file.data,set_mb_user=mb_user,set_mb_pw= mb_pw,set_nb_day_before_fig = nb_previous_day,set_id_previous_import = id_previous_import, set_save_fig = save.fig))

    if(!(rep.out) %in% dir()) {
         cat("\n The output folder",rep.out,"misses\n")
         dir.create(rep.out,showWarnings=FALSE)
         cat("\n Directory created !!\n")
     }

    cat("\n Moving of output to the output folder\n")

   output.move(paste0(rep.out,"/"),file.out,file.rmd)



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


