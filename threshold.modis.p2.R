suppressMessages(library(fields))
suppressMessages(library(ncdf4))
suppressMessages(library(RColorBrewer))
suppressMessages(library(abind))
suppressMessages(library(base))

#request 150, 12+hr
### So here I'm importing the threshold sst values calculated earlier (for particular longitude sections) and then
### creating a array of 1's and 0's for if the observed sst exceeded those
### thresholds. I then multiply that "hw.index" matrix by the observed sst
### (leap days removed) to get the values on  heat wave days,
### with values on non-heat wave days set to NA "sst.hw" and vice versa. 

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


#Read in threshold values 
threshold.final=readRDS(paste(dir.out,'threshold.final.',lon.start,'.',lon.end,'.90.rds',sep=""))

#Read in sst values (no leap years anyways in the dataset fyi)
sst.no.leap=readRDS(paste(dir.data,'sst.',lon.start,'.',lon.end,'.rds',sep="")) #n.lonxn.latx365xn.years

###### if sst exceeds threshold, set = to TRUE #####
hw.index=array(rep(NA,n.lon*n.lat*365*n.years),c(n.lon,n.lat,365,n.years)) #initialize
for (i in 1:n.years){ 
  hw.index[,,,i]=sst.no.leap[,,,i]>=threshold.final 
}  
#Now convert array of T/F to 1/0's
hw.index=hw.index+0

##### Now satisfy the constraint that you need 3+ days of 1's in a row. (12 values for 6hr data) #####
#the if statement is saying if it currently exceeds the threshold and the next 2 days do as well,
#keep it as a 1, else turn it to 0. But, if you do that the 2nd day in a 3 day event will fail and 
#be turned to a 0. So you have to include an OR clause that if it's a 1 and the preceding and following
#days are 1's, then it's a heatwave, and likewise if it's a 1 and the previous 2 days are 1's then
#it's also a heat wave. The simple example below shows it works.
#For now ignore heat waves that span December 27-Jan 2nd
#   is.hw=function(a){
#     for (i in 3:(length(a)-11)){
#       if (a[i]==1 & a[i+1]==1 & a[i+2]==1 
#           | a[i]==1 & a[i-1]==1 & a[i+1]==1 
#           | a[i]==1 & a[i-1]==1 & a[i-2]==1 
#           ){
#         a[i]=1 #keep it as a heat wave
#       }
#       else {
#         a[i]=0 #set as a non-event
#       }
#     }
#     return(a)
#   }
  #much faster code that works for all days of the year:
  is.hw=function(a){
      m=rle(a) #counts how many consective numbers there are (n.reps is in 'lengths')
      nn=m$lengths>=3+0 #if a value repeated 3+ times, nn=1, else nn=0
      #m$values=nn*m$values #keep values if nn=1, otherwise convert to 0 (3+ consecutive 0's remain 0's)
      #mm=inverse.rle(m) #convert the rle data type back to vector
      mm=rep(nn*m$values,m$lengths) #same as inverse.rle(m); this is a little faster than doing the above two lines
      return(mm)
  }
print('Seeing whats a heatwave')
  hw.index.2.0=apply(hw.index,c(1,2,4),is.hw)
  saveRDS(hw.index.2.0,paste(dir.out,'hw.index.',lon.start,'.',lon.end,'.90',sep=""))
  hw.index=hw.index.2.0
print('done. now applying to sst.')
# hw.index=readRDS("/scratch/users/tballard/sst/reanalysis.2/hw.index") #365xn.lonxn.latxn.years
 hw.index=aperm(hw.index,c(2,3,1,4)) #change dimensions to n.lonxn.latx365xn.years


### Now apply the hw.index array of 1's and 0's to the observed sst   
sst.hw=sst.no.leap*hw.index
sst.hw[sst.hw==0]=NA
saveRDS(sst.hw,paste(dir.out,'sst.hw.',lon.start,'.',lon.end,'.90',sep=""))
rm(sst.hw)

### Now do the same, but record the sst if it wasn't a heatwave, NA's if it was (not sure how useful since so much is NA already)
hw.index.not=hw.index
hw.index.not[hw.index.not==0]=2 #there is probably a more clever way to swap 0's and 1's but w/e
hw.index.not[hw.index.not==1]=0
hw.index.not[hw.index.not==2]=1

sst.hw.not=sst.no.leap*hw.index.not
sst.hw.not[sst.hw.not==0]=NA
saveRDS(sst.hw.not,paste(dir.out,'sst.hw.not.',lon.start,'.',lon.end,'.90',sep=""))
rm(sst.hw.not)
print('Creating duration index')
### Now make an hw.index that gives duration, eg from 0,0,1,1,1,1,0,0 to 0,0,1,2,3,4,0,0 ###
  duration.hw=function(a){
  m=unlist(sapply(rle(a)$lengths,seq))
  #a=m*a
  return(m*a)
}
 hw.index.duration=apply(hw.index,c(1,2,4),duration.hw)
 saveRDS(hw.index.duration, paste(dir.out,'hw.index.duration.',lon.start,'.',lon.end,'.90',sep=""))
 #rm(hw.index.duration)  
 print('All done yall')



# shum.hw=shum.no.leap*hw.index
# shum.hw[shum.hw==0]=NA #set all days that arent heat waves to NA instead of 0
# saveRDS(shum.hw,"/scratch/users/tballard/sst/reanalysis.2/shum.hw")
# 
# ### Now do the same thing for shum, but create a matrix where it's NA's during
# ### the heat waves and observed values for non-heat wave days

# shum.hw.not=shum.no.leap*hw.index.not
# saveRDS(shum.hw.not,"/scratch/users/tballard/sst/reanalysis.2/shum.hw.not")
# 