
vecPackage=c("lubridate","ggplot2","data.table","suncalc","rtide")
ip <- installed.packages()[,1]

for(p in vecPackage){
    if (!(p %in% ip))
        install.packages(pkgs=p,repos = "https://pbil.univ-lyon1.fr/CRAN/",dependencies=TRUE)
    library(p,character.only = TRUE)

}


dates <-  as.Date("2022-09-01") +0:90

## Nantes
place_name <- "Nantes France"
the_lat <- 47.214896
the_lon <- -1.618701
tz  <-  "Europe/Paris"

## Rangi
## the_lat <- -15.087761
## the_lon <- -147.900397

m0 <- getMoonTimes(date = dates, lat = the_lat, lon = the_lon, tz = tz)
r1 <- as.POSIXct(paste0(m0$date," 00:00:01"))
r0 <- m0$rise
r0[is.na(r0)] <- r1[is.na(r0)]
m0$rise <-  r0

r1 <- as.POSIXct(paste0(m0$date," 00:00:01"))
set0 <- m0$set
set0[is.na(set0)] <- r1[is.na(set0)]
m0$set <-  set0


m1 <- getMoonTimes(date = dates+1, lat = the_lat, lon = the_lon, tz = tz)

s0 <- getSunlightTimes(date = dates, lat = the_lat, lon = the_lon, tz = tz,keep=c("night"))
s1<- getSunlightTimes(date = dates+1, lat = the_lat, lon = the_lon, tz = tz,keep=c("nightEnd"))


n <- data.frame(date = s0$date, lat= s0$lat, lon = s0$lon, night = s0$night, night_end= s1$nightEnd,moon_rise = m0$rise, moon_set0 = m0$set,moon_set1 = m1$set)

setDT(n)

n[,moon_set :=  moon_set0]
n[moon_set < moon_rise, moon_set := moon_set1]


keep <- colnames(n)[c(1:6,9)]
n <- n[, keep, with = FALSE]


frac <- getMoonIllumination(dates,keep="fraction")
n <- merge(n,frac,by="date")


n[, diff_ref := date - date[1]]
n[ ,gg_night := night - diff_ref]
n[ ,gg_night_end := night_end - diff_ref]
n[ ,gg_moon_rise := moon_rise - diff_ref]
n[ ,gg_moon_set := moon_set - diff_ref]

ymin <- as.POSIXct(paste0(n[1,date]," 16:00:00"))
ymax <- as.POSIXct(paste0(n[1,date]+1," 10:00:00"))

gg <- ggplot(data=n,aes(x=date,y=night))
gg <- gg + geom_errorbar(aes(x=date,ymin=gg_night,ymax=gg_night_end),size=3,width=0)
gg <- gg + geom_errorbar(aes(x=date,ymin=gg_moon_rise,ymax=gg_moon_set,colour=fraction),alpha=0.7,size=2,width=0)
gg <- gg + coord_cartesian( ylim = c(ymin, ymax))
gg






library(ggplot2)
library(scales)
library(gridExtra)
 library(maptools)

# these functions need the lat/lon in an unusual format
portsmouth <- matrix(c(-70.762553, 43.071755), nrow=1)
for_date <- as.POSIXct("2014-12-25", tz="America/New_York")
sunriset(portsmouth, for_date, direction="sunrise", POSIXct.out=TRUE)

# create two formatter functions for the x-axis display

# for graph #1 y-axis
time_format <- function(hrmn) substr(sprintf("%04d", hrmn),1,2)

# for graph #2 y-axis
pad5 <- function(num) sprintf("%2d", num)

ephemeris <- function(lat, lon, date, span=1, tz="UTC") {

  # convert to the format we need
  lon.lat <- matrix(c(lon, lat), nrow=1)

  # make our sequence - using noon gets us around daylight saving time issues
  day <- as.POSIXct(date, tz=tz)
  sequence <- seq(from=day, length.out=span , by="days")

  # get our data
  sunrise <- sunriset(lon.lat, sequence, direction="sunrise", POSIXct.out=TRUE)
  sunset <- sunriset(lon.lat, sequence, direction="sunset", POSIXct.out=TRUE)
  solar_noon <- solarnoon(lon.lat, sequence, POSIXct.out=TRUE)

  # build a data frame from the vectors
  data.frame(date=as.Date(sunrise$time),
             sunrise=as.numeric(format(sunrise$time, "%H%M")),
             solarnoon=as.numeric(format(solar_noon$time, "%H%M")),
             sunset=as.numeric(format(sunset$time, "%H%M")),
             day_length=as.numeric(sunset$time-sunrise$time))

}

daylight <- function(lat, lon, place, start_date, span=2, tz="UTC",
                     show_solar_noon=FALSE, show_now=TRUE, plot=TRUE) {

  stopifnot(span>=2) # really doesn't make much sense to plot 1 value

  srss <- ephemeris(lat, lon, start_date, span, tz)

  x_label = ""

  gg <- ggplot(srss, aes(x=date))
  gg <- gg + geom_ribbon(aes(ymin=sunrise, ymax=sunset), fill="#ffeda0")

  if (show_solar_noon) gg <- gg + geom_line(aes(y=solarnoon), color="#fd8d3c")

  if (show_now) {
    gg <- gg + geom_vline(xintercept=as.numeric(as.Date(Sys.time())), color="#800026", linetype="longdash", size=0.25)
    gg <- gg + geom_hline(yintercept=as.numeric(format(Sys.time(), "%H%M")), color="#800026", linetype="longdash", size=0.25)
    x_label = sprintf("Current Date / Time: %s", format(Sys.time(), "%Y-%m-%d / %H:%M"))
  }

  gg <- gg + scale_x_date(expand=c(0,0), labels=date_format("%b '%y"))
  gg <- gg + scale_y_continuous(labels=time_format, limits=c(0,2400), breaks=seq(0, 2400, 200), expand=c(0,0))
  gg <- gg + labs(x=x_label, y="",
                  title=sprintf("Sunrise/set for %sn%s ", place, paste0(range(srss$date), sep=" ", collapse="to ")))
  gg <- gg + theme_bw()
  gg <- gg + theme(panel.background=element_rect(fill="#525252"))
  gg <- gg + theme(panel.grid=element_blank())

  gg1 <- ggplot(srss, aes(x=date, y=day_length))
  gg1 <- gg1 + geom_area(fill="#ffeda0")
  gg1 <- gg1 + geom_line(color="#525252")

  if (show_now) gg1 <- gg1 + geom_vline(xintercept=as.numeric(as.Date(Sys.time())), color="#800026", linetype="longdash", size=0.25)

  gg1 <- gg1 + scale_x_date(expand=c(0,0), labels=date_format("%b '%y"))
  gg1 <- gg1 + scale_y_continuous(labels=pad5, limits=c(0,24), expand=c(0,0))
  gg1 <- gg1 + labs(x="", y="", title="Day(light) Length (hrs)")
  gg1 <- gg1 + theme_bw()

  if (plot) grid.arrange(gg, gg1, nrow=2)

  arrangeGrob(gg, gg1, nrow=2)

}



daylight(43.071755, -70.762553, "Portsmouth, NH", "2014-09-01", 365, tz="America/New_York")


daylight(the_lat, the_lon, "Nantes, FR", "2020-09-01", 365, tz=tz)
