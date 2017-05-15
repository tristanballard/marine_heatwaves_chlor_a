suppressMessages(library(ncdf4))
## Saves the threshold.final.rds (lonxlatx365) to a netcdf file. First opens a template .nc file to get the correct lat/lon/time dimensions
threshold.final=readRDS("/scratch/users/tballard/sst/reanalysis.2/threshold.final.95")

   fileName=paste("/scratch/PI/omramom/reanalysis/ncep-doe-r2/daily/skt/skt.sfc.gauss.",'1979.copy',".nc",sep="")
   nc=nc_open(fileName,write=TRUE)

   lon=ncvar_get(nc, "lon")
   londim=ncdim_def("lon",'degrees_east',lon)
   lat=ncvar_get(nc, "lat")
   latdim=ncdim_def("lat",'degrees_north',lat)
   time=ncvar_get(nc,"time")
   timedim=ncdim_def("time",'hours since 1800-1-1 00:00:0.0',time)
   fillvalue = 1e32
   var_def = ncvar_def("skt_thresh","deg_C",list(londim,latdim,timedim),fillvalue,
                       longname="skt threshold calculated from heatwave metric",prec="float")

   outnc=nc_create('test.nc',var_def,force_v4=TRUE) #force_v4 makes it netcdf4 format
   #put.var.ncdf(nc,"skt",threshold.final)
   ncvar_put(outnc,var_def,threshold.final) #put the threshold.final values into the blank variable you created
   nc_close(outnc) 
   

 
     
   
   hw.index.duration=readRDS("/scratch/users/tballard/sst/reanalysis.2/hw.index.duration.95") #365x192x94x37
   hw.index.duration=aperm(hw.index.duration,c(2,3,1,4)) #change dimensions to n.lonxn.latx365xn.years
   hw.index.duration=hw.index.duration[,,1:31,25:37]
   
   fileName=paste("/scratch/PI/omramom/reanalysis/ncep-doe-r2/daily/skt/skt.sfc.gauss.",'1979.copy',".nc",sep="")
   nc=nc_open(fileName)

   lon=ncvar_get(nc, "lon")
   londim=ncdim_def("lon",'degrees_east',lon)
   lat=ncvar_get(nc, "lat")
   latdim=ncdim_def("lat",'degrees_north',lat)
   #time=ncvar_get(nc,"time")
   time=c(1:31)
   timedim=ncdim_def("time_days",'days',time)
   time2=c(1:13)
   timedim2=ncdim_def("time_years",'years',time2)
   fillvalue = 0
   var_def = ncvar_def("hw_index_duration","duration (days)",list(londim,latdim,timedim,timedim2),fillvalue,
                       longname="Length of heatwaves",prec="integer")

   outnc=nc_create('hw.index.duration.nc',var_def,force_v4=TRUE) #force_v4 makes it netcdf4 format
   #put.var.ncdf(nc,"skt",threshold.final)
   ncvar_put(outnc,var_def,hw.index.duration) #put the actual values into the blank variable you created
   nc_close(outnc) 
   