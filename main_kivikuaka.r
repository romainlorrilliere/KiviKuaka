source("functions/fun_generic.r")
source("functions/fun_rmd.r")
source("functions/fun_importation.r")



main_exploration_rmd <- function(importing=TRUE,exploration=FALSE,importing_file.rmd="importing_data_update.rmd",importing_file.out="importing_dataGPS",exploration_file.rmd="importing_data_update.rmd",exploration_file.out="importing_dataGPS",rep.out="output_md",format_output="html",file.data="data/data_kivikuaka_envents.csv",user = "romainlorrilliere",pw="xxx",save.fig=FALSE,render.clean=FALSE) {

    if(importing)
        importing_rmd(file.rmd=importing_file.rmd,file.out=importing_file.out,rep.out=rep.out,format_output=format_output,file.data=,mb_user = user,mb_pw = pw,save.fig=save.fig,render.clean=render.clean)

    if(exploration)
        exploration_rmd(file.rmd=exploration_file.rmd,output_file=exploration_output.file,rep.out=rep.out,format_output=format_output,file.data=,save.fig=save.fig,render.clean=render.clean)


}
