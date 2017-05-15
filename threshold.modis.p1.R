## This code figures out what the threshold sst value should be at each grid point.
## threshold.part2.R then takes that matrix of values and sees when the heat wave days are
## by seeing when the values exceed the thresholds calculated here. Since files so big
## need to chop the file up into lon bins and run them all seperately.


suppressMessages(library(fields))
suppressMessages(library(ncdf4))
suppressMessages(library(abind))

args=(commandArgs(TRUE)) #read in command line prompt index (args will equal, say '6'), indicating which model to run this on
args=as.numeric(args)
print(args)

dir.data='/scratch/PI/omramom/MODIS/daily/sst/'
dir.out='/scratch/users/tballard/sst/modis/sst.data/'
yr.start=2003
yr.end=2015
n.years=yr.end-yr.start+1
lon.start=args[1]
lon.end=args[2]
n.lon=lon.end-lon.start+1
n.lat=2160


#############################################################
###########          Read in the Data         ###############
############################################################# 

#### Read in the first for a demo ####
sst=readRDS(paste(dir.data,'sst.',yr.start,'.rds',sep=""))
sst=sst[lon.start:lon.end,,] #clip data #n.lonxn.latx365
missing.value=sst[1,1,1] #45.0071714.....
sst[sst==missing.value]=NA
sst=array(sst,c(dim(sst),1)) #initialize the array to come next n.lonxn.latx365xn.years
print('Building sst array')
#### Read in the files, clipping them directly after reading in by the lon specifications
year=c(yr.start:yr.end)
for (i in (yr.start+1):yr.end){
  print(i)
  a=readRDS(paste(dir.data,'sst.',i,'.rds',sep=""))
  a=a[lon.start:lon.end,,]
  a[a==missing.value]=NA
  sst=abind(sst,a)
}
rm(a)
print('Built sst array')
print(dim(sst))
saveRDS(sst,paste(dir.data,'sst.',lon.start,'.',lon.end,'.rds',sep=""))
print('Saved sst array')


#### Figure out when leap years are #####
n.days=rep(365,n.years) #no leap years


##### Compute the 90th percentile threshold for 7 days forward + back distribution #####
##### Note this is like a moving average where the first 7 days and last 7 days    #####
##### are cut. These two tails are calculated in the code directly after this and  #####
##### instead use years 1980-2014 for e.g. the first 7 days values.                #####

#Note skt is n.lonxn.latx13149
time.start=8 #29
time.end= 365-7#1460-28
threshold.fxn=function(data,n.days,time.start,time.end){
  for (i in time.start:time.end){
  preceding.days=(i-7):(i-1)
  #preceding.days=preceding.days[c(TRUE,rep(FALSE,3))] #length=7
  following.days=(i+1):(i+7)
  #following.days=following.days[c(rep(FALSE,3),TRUE)] #length=7
  index=c(preceding.days,i,following.days) #length=15
  days.index=c()
  for (i in 1:(length(n.days)-1)){
    b=index+sum(n.days[1:i]) #sequence above, but for all the 1,2,3,4...36 years forward
    days.index=c(days.index,b)
  }
  days.index=c(index,days.index) #length = 540 = 15days*36years
  
  #Now subset the data by those days, and find the 90th percentile of that distribution
  x=data[days.index]
  threshold=quantile(x, .9, names=F,na.rm=T)
  thresholds=c(thresholds,threshold) #vector length=1404
  #print(length(thresholds))
  }
  return(thresholds)
}
thresholds=c()
threshold=apply(sst,c(1,2),threshold.fxn, n.days=n.days, time.start=time.start, time.end=time.end) #7xn.lonxn.lat
#saveRDS(thresh,"/scratch/users/tballard/shum/percentile.threshold/threshold")
#threshold=readRDS("/scratch/users/tballard/shum/percentile.threshold/threshold")
print('threshold p1 done')

#### Compute for the first 7 days #####
time.start=366 #jan 1 1980
time.end=372 #jan 7 1980
threshold.fxn=function(data,n.days,time.start,time.end){
  for (i in time.start:time.end){
  preceding.days=(i-7):(i-1)
  #preceding.days=preceding.days[c(TRUE,rep(FALSE,3))] #length=7
  following.days=(i+1):(i+7)
  #following.days=following.days[c(rep(FALSE,3),TRUE)] #length=7
  index=c(preceding.days,i,following.days) #length=15
  days.index=c()
  for (i in 1:(length(n.days)-1)){
    b=index+sum(n.days[2:i]) #sequence above, but for all the 1,2,3,4...36 years forward
    #note this line above changes compared to the original one for all dates
    days.index=c(days.index,b)
  }
  days.index=c(index,days.index) #length = 540 = 15days*36years
  
  #Now subset the data by those hours, and find the 90th percentile of that distribution
  x=data[days.index]
  threshold=quantile(x, .9, names=F,na.rm=T)
  thresholds=c(thresholds,threshold) #vector length=1404
  #print(length(thresholds))
  }
  return(thresholds)
}
thresholds=c()
threshold1=apply(sst,c(1,2),threshold.fxn, n.days=n.days, time.start=time.start, time.end=time.end)
#saveRDS(thresh,"/scratch/users/tballard/shum/percentile.threshold/threshold.part1")
#threshold1=readRDS("/scratch/users/tballard/shum/percentile.threshold/threshold.part1")
print('threshold p2 done')


##### Compute for the last 7 days of the year #####
time.start=365-6
time.end=365
threshold.fxn=function(data,n.days,time.start,time.end){
  for (i in time.start:time.end){
    preceding.days=(i-7):(i-1)
    #preceding.days=preceding.days[c(TRUE,rep(FALSE,3))] #length=7
    following.days=(i+1):(i+7)
    #following.days=following.days[c(rep(FALSE,3),TRUE)] #length=7
    index=c(preceding.days,i,following.days) #length=15
    days.index=c()
    for (i in 1:(length(n.days)-1)){
      b=index+sum(n.days[2:i]) #sequence above, but for all the 1,2,3,4...36 years forward
      #note this line above changes compared to the original one for all dates
      days.index=c(days.index,b)
    }
    days.index=c(index,days.index) #length = 540 = 15days*36years
    
    #Now subset the data by those hours, and find the 90th percentile of that distribution
    x=data[days.index]
    threshold=quantile(x, .9, names=F,na.rm=T)
    thresholds=c(thresholds,threshold) #vector length=1404
    #print(length(thresholds))
  }
  return(thresholds)
}
thresholds=c()
threshold2=apply(sst,c(1,2),threshold.fxn, n.days=n.days, time.start=time.start, time.end=time.end)
#saveRDS(thresh2,"/scratch/users/tballard/shum/percentile.threshold/threshold.part2")
#threshold2=readRDS("/scratch/users/tballard/shum/percentile.threshold/threshold.part2")
print('threshold p3 done')

#### First rearrange the dimensions ####
threshold1=aperm(threshold1,c(2,3,1)); threshold=aperm(threshold,c(2,3,1)); threshold2=aperm(threshold2,c(2,3,1)); 
threshold4=abind(threshold1,threshold,threshold2) #dim=n.lonxn.latx1460
saveRDS(threshold4, paste(dir.out,'threshold.final.',lon.start,'.',lon.end,'.90.rds',sep=""))
#threshold.final=readRDS("/scratch/users/tballard/sst/reanalysis.2/threshold.final")
print('Done. Phew.')


