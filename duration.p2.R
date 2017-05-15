suppressMessages(library(fields))
suppressMessages(library(ncdf4))
suppressMessages(library(RColorBrewer))
suppressMessages(library(abind))
suppressMessages(library(base))

#This creates files, still binned by lon, that are the median chlor values (map) when, say, duration ==1. Or duration==2, etc.
#Next step is to combine all the lon bins into individual maps showing median chlor for different days/duration in the heatwave
#62GB and 2hr
# args=(commandArgs(TRUE)) #read in command line prompt index (args will equal, say '6'), indicating which model to run this on
# args=as.numeric(args)
# print(args)
args=c(1,200)
dir.data='/scratch/PI/omramom/MODIS/daily/chlor_a/'
dir.out='/scratch/users/tballard/sst/modis/sst.data/'
yr.start=2003
yr.end=2015
n.years=yr.end-yr.start+1
lon.start=args[1]
lon.end=args[2]
n.lon=lon.end-lon.start+1
n.lat=2160

c0=array(rep(NA,n.lat))
for (i in 1:14){
  saveRDS(chlor.med,paste(dir.out,'chlor.med.',lon.start,'.',lon.end,'.90','.duration.',i,sep=""))
  rm(chlor.med)
}

