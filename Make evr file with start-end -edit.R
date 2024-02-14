# Script to generate a .evr region definition file based on given start and end times
# Last modified 2 March 2020 by Haley Viehman

# User definitions:
dive.times = read.csv('C:/Users/Aerd/Documents/R/EchoviewR_work/AMLR01_down_profile.csv',stringsAsFactors=F,header=T) #  generate the data frame with the start and end dates & times of each dive
  dive.times$start.time=lubridate::dmy_hms(dive.times$start.time)
  dive.times$end.time=lubridate::dmy_hms(dive.times$end.time)
reg.class = 'Dive' # region class name to assign to the dive regions
start.depth = -1 # starting depth for the regions
end.depth = 1000 # ending depth for the regions (make sure it spans the water column)
save.path = 'C:/Users/Aerd/Documents/R/EchoviewR_work/echoview/' # path to save the resulting .evr region file to

# Number of regions to create
n.reg = nrow(dive.times) 

# Vector for storing region definition strings
# (Note: user may need to adjust version number accordingly)
region.vec = c('EVRG 7 10.0.298.38422',as.character(n.reg))

# Add the necessary lines for defining a region in Echoview
for(i in 1:n.reg){
  date.start = format(dive.times$start.time[i],'%Y%m%d')
  time.start = format(dive.times$start.time[i],'%H%M%S0000')
  date.end = format(dive.times$end.time[i],'%Y%m%d') 
  time.end = format(dive.times$end.time[i],'%H%M%S0000')
  line1 = paste0(c(13,4,i,0,3,-1,1,date.start,time.start,start.depth,date.end,time.end,end.depth),collapse=' ')
  line5 = paste0(c(date.start,time.start,end.depth,date.end,time.end,end.depth,date.end,time.end,start.depth,date.start,time.start,start.depth,1),collapse=' ')
  reg.name=paste('Region',dive.times$profile[i])
  region.vec = c(region.vec,'',line1,'0','0',reg.class,line5,reg.name)
}

# Save the regions in a .evr file at the specified destination
write.table(region.vec,file=paste0(save.path,'Dive regions.evr'),
            sep='\n',eol='\n',quote=F,row.names=F,col.names=F)
