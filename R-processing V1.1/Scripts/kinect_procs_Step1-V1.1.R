############################################################################
#
# First level processing script of Kinect-data. The script reads in
# the exported text file saved from the Matlab-recording routines to extract
# posture data for later processing and statistical analyses. 
#
# Version 2
#
# This is processing step 3 after the recording was was carried out using Matlab
# (Step 1) and after the text-data was extract from the raw recordings (Step 2). 
#
# Important note: There are still many redundancies, inefficiencies, and 
# idiosynracies in the script. Please use with care when adopting it to other 
# datasets!
#
# The output is an R-Image-file (produced at the bottom of the script).
#
# This script is written for MacOS. Some commands do not work for Windows/Linux.
#
# Currently used in:
# Study: ProShame (2018)
# Researchers: 
#
# Elements that are specific to the study are marked with ##.
#
# The processing of Kinect-data is based on:
#
# Hepach, R., Vaish, A., & Tomasello, M. (2017). The fulfillment of others’ needs elevates children’s body posture. Developmental psychology, 53(1), 100.
#
# Hepach, R. & Tomasello, M. (under review). Young children show positive emotions when seeing someone get the help they deserve.
#
# Last changes November 2019 by RH.
#
# Questions -> robert.hepach@uni-leipzig.de
############################################################################
setwd("/Volumes/ERZW/FEUK/HAUN LAB/STUDIEN/STELLA/Involve/Involve-Pilot/Involve R-Posture V1.1")
# Clear workspace and close open graphic windows.
rm(list = ls(all = TRUE))
graphics.off()

# Load packages.
require(plyr)

# Load required functions. 
source("neeco_functions.r")

# Set directory for plots (optional).
plot.dir = "../proshame-plots/"

############################################################################
#
# Set variables.
#
############################################################################

# Maximum distance away from the Kinect to be included in processing:
start = 3.2						
# Minimum distance away from the Kinect to be included in processing:
stop = 1.2 							
# Number of distance windows into which data are later binned:
win.dow = (start-stop)*10
# Length of each window:				
win.length = (start-stop)/win.dow;
# First numeric column of the raw dataset.
n.col = 7 		  
# Maximum number of numeric columns.
fun.max.col = 30*10 
# Used for processing of forward moving sequence.
min.frame.length = 10
max.distance = 0
min.distance = 1.2		
# Value for filter number 10.
median.cutoff = 0.1
crit.val = NA # Used to make decisions for cases where two skeletons are tracked. Set this to NA if the option should not be used.
to.plot = 1 # Should control plots be generated?
del.double = 0 # Should Recordings with two skeletons be removed?

# The following empty containers are used for storing parts of the processed data.
myData.depth.bin = c()
myData.chest.bin = c()
myData.hip.bin = c()
myData.str = c()
check.bin.den = c()

############################################################################

# Processing filters

# USED IN PREPROCESSING:
# 1. In case there are two skeletons tracked per recording remove the larger one (i.e., adult filter).
rel.height = 0

# USED IN PHASE 1 
# 2. Remove data outside tracking range?
data.inside = 1

# 3. Is the center back above the hip center? Remove frame if not.
upright.back = 1

# 4. Is the head above the shoulder? Remove frame if not.
head.above.shoulder = 1

# 5. Is the shoulder above the center back? Remove frame if not.
shoulder.above.back = 1

# 6. Is the center hip between left and right hip? Remove frame if not.
centered.hip = 1

# 7. Is the center shoulder between left and right shoulder? Remove frame if not.
centered.shoulder = 1

# USED IN PHASE 2 

# 8. Collapse across colors?
col.collap = 1

# 9. Remove data before feet crossed. This ensures that children were walking toward the camera.	
feet.crossed = 0

# 10. Remove frame if the head is too low (XX cm below the median, see preamble), i.e., when child is crouching down.
head.too.low = 1

# 11. Interpolate resulting gaps.
interpl = 1

# 12. Remove entire trial if skeleton is likely not mapped on child (too high).
abs.height = 1

# 13. Run an additional forward sequence filter, short version.
add.forward.filter = 1

# 14. Bin data. 	
bin.data = 1

# 15. Interpolate resulting gaps.
interpl = 1

# 16. Warp data at the beginning and end of each data row.
warp.data = 1

# 17. Minimum data points (binned data) to be inlcuded in further analysis.
min.data.bin = 1

############################################################################

## Here multiple files are read in.
# Read in data.
flist = list.files("../Involve-Pilot-txt/geschnitten")

myData = c()

for(i in 1:length(flist)){ #(1)
	now.myData <- read.table(file= paste("../Involve-Pilot-txt/geschnitten/", flist[i], collapse="",sep = ""),header=T,sep="\t")
	myData = rbind(myData, now.myData)
	rm("now.myData")
}

myData  = myData[ , -which(names(myData) %in% c("X"))]
##

####
## Pre-Processing start
###

# The following function indexes specific columns, i.e., Trial, Recording. 
# (1) Filter: rel.height and crit.val.
# Note that the crit.val is still idiosyncratic for issue of additional skeletons tracked on the right side of childen's skeletons.
myData = fun.change.structure(myData, unique(myData$Subject), (n.col-1), fun.max.col, rel.height, crit.val)

# Shorten dataset and remove empty columns.
myData.colWithdata = as.numeric(apply(myData[,(n.col+1):ncol(myData)],2,FUN=mean,na.rm=T))
myData.colWithdata[myData.colWithdata>0] <- 1
plot(myData.colWithdata)
foo.counter = c(1:length(myData.colWithdata))
max(foo.counter[myData.colWithdata==1], na.rm=T)
myData = myData[,1:(((n.col+1)-1)+max(foo.counter[myData.colWithdata==1], na.rm=T))] # This needs to be optimized.
rm("myData.colWithdata", "foo.counter")

##
# This combines the info for trial and recording for the next processing step.
myData$Recording <- do.call(paste, c(myData[c("Trial", "Recording")], sep = "-"))
##

# Selects the relevant X-,Y-, and Z-coordinates for the specific skeletal points. Only these skeletal points will be used for later processing.

# Select those skeletons that are relevant for the processing.
myData.chest = subset(myData, Skeleton=="Shoulder_Center_Y"); myData.chest = droplevels(myData.chest)
myData.depth = subset(myData, Skeleton=="Hip_Center_Z"); myData.depth = droplevels(myData.depth)
myData.head.y = subset(myData, Skeleton=="Head_Y"); myData.head.y = droplevels(myData.head.y)
myData.spine.y = subset(myData, Skeleton=="Spine_Y"); myData.spine.y = droplevels(myData.spine.y)
myData.hip.y = subset(myData, Skeleton=="Hip_Center_Y"); myData.hip.y = droplevels(myData.hip.y)
myData.hipL.x = subset(myData, Skeleton=="Hip_Left_X"); myData.hipL.x = droplevels(myData.hipL.x)
myData.hipC.x = subset(myData, Skeleton=="Hip_Center_X"); myData.hipC.x = droplevels(myData.hipC.x)
myData.hipR.x = subset(myData, Skeleton=="Hip_Right_X"); myData.hipR.x = droplevels(myData.hipR.x)
myData.shoL.x = subset(myData, Skeleton=="Shoulder_Left_X"); myData.shoL.x = droplevels(myData.shoL.x)
myData.shoC.x = subset(myData, Skeleton=="Shoulder_Center_X"); myData.shoC.x = droplevels(myData.shoC.x)
myData.shoR.x = subset(myData, Skeleton=="Shoulder_Right_X"); myData.shoR.x = droplevels(myData.shoR.x)
myData.elbL.x = subset(myData, Skeleton =="Elbow_Left_X"); myData.elbL.x = droplevels(myData.elbL.x)
myData.elbR.x = subset(myData, Skeleton =="Elbow_Right_X"); myData.elbR.x = droplevels(myData.elbR.x)
myData.footL.z = subset(myData, Skeleton =="Foot_Left_Z"); myData.footL.z = droplevels(myData.footL.z)
myData.footR.z = subset(myData, Skeleton =="Foot_Right_Z"); myData.footR.z = droplevels(myData.footR.z)

# Check that all dataframes have the same number of rows.
nrow(myData.chest)
nrow(myData.depth)
nrow(myData.head.y)
nrow(myData.spine.y)
nrow(myData.hipL.x)
nrow(myData.hipC.x)
nrow(myData.hipR.x)
nrow(myData.shoL.x)
nrow(myData.shoC.x)
nrow(myData.shoR.x)
nrow(myData.elbL.x)
nrow(myData.elbR.x)
nrow(myData.footL.z)
nrow(myData.footR.z)

# Determine setting for Filter: abs.height.
data.shoulder.height = apply(myData.chest[,(n.col+1):ncol(myData.chest)], FUN= mean, 2, na.rm=T)
abs.height.crit = c(-0.4, (mean(data.shoulder.height)+2*sd(data.shoulder.height)))

####
## Pre-Processing stop
###

####
## Main Processing start PHASE 1
###

unique.subj  = unique(myData.chest$Subject)
count.length = rep(NA, nrow(myData.chest))


# Processing Loop 1. Loop through color, each recoridng, each trial, each subject.
for(a in 1:nrow(myData.chest)){
			
		foo.row.chest = as.numeric(myData.chest[a,(n.col+1):ncol(myData.chest)])
		foo.row.depth = as.numeric(myData.depth[a,(n.col+1):ncol(myData.depth)])
		foo.row.head.y = as.numeric(myData.head.y[a,(n.col+1):ncol(myData.head.y)])
		foo.row.spine.y = as.numeric(myData.spine.y[a,(n.col+1):ncol(myData.spine.y)])
		foo.row.hip.y = as.numeric(myData.hip.y[a,(n.col+1):ncol(myData.hip.y)])
		foo.row.hipC.x = as.numeric(myData.hipC.x[a,(n.col+1):ncol(myData.hipC.x)])
		foo.row.hipL.x = as.numeric(myData.hipL.x[a,(n.col+1):ncol(myData.hipL.x)])
		foo.row.hipR.x = as.numeric(myData.hipR.x[a,(n.col+1):ncol(myData.hipR.x)])
		foo.row.shoC.x = as.numeric(myData.shoC.x[a,(n.col+1):ncol(myData.shoC.x)])
		foo.row.shoL.x = as.numeric(myData.shoL.x[a,(n.col+1):ncol(myData.shoL.x)])
		foo.row.shoR.x = as.numeric(myData.shoR.x[a,(n.col+1):ncol(myData.shoR.x)])
		foo.row.elbL.x = as.numeric(myData.elbL.x[a,(n.col+1):ncol(myData.elbL.x)])
		foo.row.elbR.x = as.numeric(myData.elbR.x[a,(n.col+1):ncol(myData.elbR.x)])
		foo.row.footL.z = as.numeric(myData.footL.z[a,(n.col+1):ncol(myData.footL.z)])
		foo.row.footR.z = as.numeric(myData.footR.z[a,(n.col+1):ncol(myData.footR.z)])
		
		# Continue if there is data.
		if(sum(!is.na(foo.row.depth))>0){

			# Later processing steps use the x-coordinate. This makes sure that the correct perspective is taken, i.e., from left (<0) to right (>0) 
			if(mean(foo.row.hipL.x-foo.row.hipR.x, na.rm =T) > 0){
				temp.left = foo.row.hipL.x
				temp.right = foo.row.hipR.x
				foo.row.hipL.x <- temp.right
				foo.row.hipR.x <- temp.left
			}

			if(mean(foo.row.shoL.x-foo.row.shoR.x, na.rm =T) > 0){
				temp.left = foo.row.shoL.x
				temp.right = foo.row.shoR.x
				foo.row.shoL.x <- temp.right
				foo.row.shoR.x <- temp.left
			}
	
			###
			# 13.
			if(add.forward.filter == 1){
				
				control.depth <- get.forward.seq.short(foo.row.depth)				
				foo.row.depth.dummy <- foo.row.depth
				
				if(sum(!is.na(control.depth))<sum(!is.na(foo.row.depth.dummy)) && foo.row.depth.dummy[!is.na(foo.row.depth.dummy)][1] < 2.2){
					
				foo.row.chest[!is.na(foo.row.depth.dummy)][1] <- NA
				foo.row.depth[!is.na(foo.row.depth.dummy)][1] <- NA
				foo.row.hip.y[!is.na(foo.row.depth.dummy)][1] <- NA
	
				}

				if(sum(!is.na(control.depth))<sum(!is.na(foo.row.depth.dummy)) && foo.row.depth.dummy[!is.na(foo.row.depth.dummy)][length(foo.row.depth.dummy[!is.na(foo.row.depth.dummy)])] > 2.2){
					
				foo.row.chest[length(foo.row.depth.dummy[!is.na(foo.row.depth.dummy)])] <- NA
				foo.row.depth[length(foo.row.depth.dummy[!is.na(foo.row.depth.dummy)])] <- NA
				foo.row.hip.y[length(foo.row.depth.dummy[!is.na(foo.row.depth.dummy)])] <- NA
	
				}

				foo.row.chest[is.na(control.depth)] <- NA
				foo.row.depth[is.na(control.depth)] <- NA
				foo.row.hip.y[is.na(control.depth)] <- NA
				
				rm("control.depth")
			
			}
	
			###
			# 2.
			if(data.inside == 1){

				control.depth = foo.row.depth
	
				# Delete all data after the last 1m frame.
				foo.count = c(1:length(control.depth))
				foo.control.depth = as.numeric(rep(NA, length(control.depth)))
				foo.control.depth[control.depth <=stop] <- 1
				foo.count = foo.count[!is.na(foo.control.depth)]
				if(length(!is.na(foo.count))==0){foo.count<-(length(control.depth)-1)}
										
						foo.row.chest <- data.inside.procs(foo.row.chest, start, stop, foo.count, control.depth)
						foo.row.depth <- data.inside.procs(foo.row.depth, start, stop, foo.count, control.depth)
						foo.row.head.y <- data.inside.procs(foo.row.head.y, start, stop, foo.count, control.depth)
						foo.row.spine.y <- data.inside.procs(foo.row.spine.y, start, stop, foo.count, control.depth)
						foo.row.hip.y <- data.inside.procs(foo.row.hip.y, start, stop, foo.count, control.depth)
						foo.row.hipC.x <- data.inside.procs(foo.row.hipC.x, start, stop, foo.count, control.depth)
						foo.row.hipL.x <- data.inside.procs(foo.row.hipL.x, start, stop, foo.count, control.depth)
						foo.row.hipR.x <- data.inside.procs(foo.row.hipR.x, start, stop, foo.count, control.depth)
						foo.row.shoC.x <- data.inside.procs(foo.row.shoC.x, start, stop, foo.count, control.depth)
						foo.row.shoL.x <- data.inside.procs(foo.row.shoL.x, start, stop, foo.count, control.depth)
						foo.row.shoR.x <- data.inside.procs(foo.row.shoR.x, start, stop, foo.count, control.depth)
						foo.row.elbL.x <- data.inside.procs(foo.row.elbL.x, start, stop, foo.count, control.depth)
						foo.row.elbR.x <- data.inside.procs(foo.row.elbR.x, start, stop, foo.count, control.depth)
						foo.row.footL.z <- data.inside.procs(foo.row.footL.z, start, stop, foo.count, control.depth)
						foo.row.footR.z <- data.inside.procs(foo.row.footR.z, start, stop, foo.count, control.depth)
	
						rm("foo.control.depth", "foo.count", "control.depth")
			}
			
			###		
			# 3.
			if(upright.back == 1){
				
				temp.hip = foo.row.hip.y
				foo.row.chest[foo.row.spine.y <= temp.hip] <- NA
				foo.row.depth[foo.row.spine.y <= temp.hip] <- NA
				foo.row.hip.y[foo.row.spine.y <= temp.hip] <- NA
				rm("temp.hip")

			}
	
			###
			# 4.
			if(head.above.shoulder == 1){
				
				temp.chest = foo.row.chest
				foo.row.chest[foo.row.head.y <= temp.chest] <- NA
				foo.row.depth[foo.row.head.y <= temp.chest] <- NA		
				foo.row.hip.y[foo.row.head.y <= temp.chest] <- NA		
				rm("temp.chest")
				
			}
	
			###
			# 5.
			if(shoulder.above.back == 1){
				
				temp.chest = foo.row.chest
				foo.row.chest[foo.row.spine.y >= temp.chest] <- NA
				foo.row.depth[foo.row.spine.y >= temp.chest] <- NA	
				foo.row.hip.y[foo.row.spine.y >= temp.chest] <- NA	
				rm("temp.chest")
				
			}

			###
			# 6.
			if(centered.hip == 1){
				
				foo.row.chest[foo.row.hipC.x < foo.row.hipL.x] <- NA
				foo.row.depth[foo.row.hipC.x < foo.row.hipL.x] <- NA		
				foo.row.hip.y[foo.row.hipC.x < foo.row.hipL.x] <- NA
				foo.row.chest[foo.row.hipC.x > foo.row.hipR.x] <- NA
				foo.row.depth[foo.row.hipC.x > foo.row.hipR.x] <- NA		
				foo.row.hip.y[foo.row.hipC.x > foo.row.hipR.x] <- NA		
				
			}

			###
			# 7.
			if(centered.shoulder == 1){
				
				foo.row.chest[foo.row.shoC.x < foo.row.shoL.x] <- NA
				foo.row.depth[foo.row.shoC.x < foo.row.shoL.x] <- NA	
				foo.row.hip.y[foo.row.shoC.x < foo.row.shoL.x] <- NA		
				foo.row.chest[foo.row.shoC.x > foo.row.shoR.x] <- NA
				foo.row.depth[foo.row.shoC.x > foo.row.shoR.x] <- NA		
				foo.row.hip.y[foo.row.shoC.x > foo.row.shoR.x] <- NA		
				
			}

	# Write processed data back into container.
    myData.chest[a,(n.col+1):ncol(myData.chest)] <- foo.row.chest[1:length((n.col+1):ncol(myData.chest))]
    myData.depth[a,(n.col+1):ncol(myData.depth)] <- foo.row.depth[1:length((n.col+1):ncol(myData.depth))]
    myData.hip.y[a,(n.col+1):ncol(myData.hip.y)] <- foo.row.hip.y[1:length((n.col+1):ncol(myData.hip.y))]
    myData.head.y[a,(n.col+1):ncol(myData.head.y)] <- foo.row.head.y[1:length((n.col+1):ncol(myData.head.y))]
    myData.spine.y[a,(n.col+1):ncol(myData.spine.y)] <- foo.row.spine.y[1:length((n.col+1):ncol(myData.spine.y))]
    myData.hipC.x[a,(n.col+1):ncol(myData.hipC.x)] <- foo.row.hipC.x[1:length((n.col+1):ncol(myData.hipC.x))]
	myData.hipL.x[a,(n.col+1):ncol(myData.hipL.x)] <- foo.row.hipL.x[1:length((n.col+1):ncol(myData.hipC.x))]
	myData.hipR.x[a,(n.col+1):ncol(myData.hipR.x)] <- foo.row.hipR.x[1:length((n.col+1):ncol(myData.hipC.x))]
	myData.shoC.x[a,(n.col+1):ncol(myData.shoC.x)] <- foo.row.shoC.x[1:length((n.col+1):ncol(myData.hipC.x))]
	myData.shoL.x[a,(n.col+1):ncol(myData.shoL.x)] <- foo.row.shoL.x[1:length((n.col+1):ncol(myData.hipC.x))]
	myData.shoR.x[a,(n.col+1):ncol(myData.shoR.x)] <- foo.row.shoR.x[1:length((n.col+1):ncol(myData.hipC.x))]
	myData.elbL.x[a,(n.col+1):ncol(myData.elbL.x)] <- foo.row.elbL.x[1:length((n.col+1):ncol(myData.hipC.x))]
	myData.elbR.x[a,(n.col+1):ncol(myData.elbR.x)] <- foo.row.elbR.x[1:length((n.col+1):ncol(myData.hipC.x))]
	myData.footL.z[a,(n.col+1):ncol(myData.footL.z)] <-	foo.row.footL.z[1:length((n.col+1):ncol(myData.hipC.x))]
	myData.footR.z[a,(n.col+1):ncol(myData.footR.z)] <- foo.row.footR.z[1:length((n.col+1):ncol(myData.hipC.x))]
	  	
	}else if(sum(!is.na(foo.row.depth))==0){
		
	# Write empty array back into container.	
    myData.chest[a,(n.col+1):ncol(myData.chest)] <- NA
    myData.depth[a,(n.col+1):ncol(myData.depth)] <- NA
    myData.hip.y[a,(n.col+1):ncol(myData.hip.y)] <- NA

	}

count.length[a] <- length(foo.row.depth)
}

# Why is one skeleton array longer? plot(count.length)

####
## Main Processing start PHASE 2
###


#Chest 20190311T082107_Involve_pilot_1_f_nonsocial_4&5_4.824093087_unequal_equal_4_0 - Test 1 - Test 1-2 
myData.chest[myData.chest $Subject=="20190311T082107_Involve_pilot_1_f_nonsocial_4&5_4.824093087_unequal_equal_4_0" & myData.chest $Recording=="Test 1-2" & myData.chest$Sk_color =="red", (n.col+1):ncol(myData.chest)] <- NA


#Hip 
myData.hip.y[myData.hip.y $Subject=="20190311T082107_Involve_pilot_1_f_nonsocial_4&5_4.824093087_unequal_equal_4_0" & myData.hip.y $Recording=="Test 1-2" & myData.hip.y$Sk_color =="red", (n.col+1):ncol(myData.hip.y)] <- NA


for(a in 1:length(unique.subj)){

	# Select chest point data for current subject.
	now.subj = subset(myData.chest, Subject ==unique.subj[a])
	# Select recorded trials for each subject.
	unique.trial = unique(now.subj$Recording)
	
	# Loop through each trial for each subject.
	for(b in 1:length(unique.trial)){

		foo.row.chest = myData.chest[myData.chest$Subject==unique.subj[a] & myData.chest$Recording == unique.trial[b],]
		foo.row.hipC.x = myData.hipC.x[myData.hipC.x $Subject==unique.subj[a] & myData.hipC.x$Recording == unique.trial[b],]
		foo.row.depth = myData.depth[myData.depth $Subject==unique.subj[a] & myData.depth$Recording == unique.trial[b],]

		if(to.plot==1 && sum(!is.na(as.numeric(apply(foo.row.chest[,(n.col+1):ncol(foo.row.chest)], FUN=mean,1, na.rm=T))))>1){
			
			quartz(width=11, height=6)
			par(mfrow=c(1,3))
			
			# CHEST
			plot(as.numeric(foo.row.chest[1, (n.col+1):length(foo.row.chest)]), ylim=c(-1,2), ylab = "Change", xlab="Sample", main="Chest Height", type="n")
			
			for(c in 1:nrow(foo.row.chest)){
				points(as.numeric(foo.row.chest[c, (n.col+1):length(foo.row.chest)]), pch=19, col=as.character(foo.row.chest[c,]$Sk_color))
			}
			
			# HIP
			plot(as.numeric(foo.row.hipC.x[1, (n.col+1):length(foo.row.hipC.x)]), ylim=c(-2,2), pch=19, col=as.character(foo.row.hipC.x[1,]$Sk_color), ylab = "Change", xlab="Sample", main="Hip Center X-coordinate")

			for(c in 1:nrow(foo.row.chest)){
				points(as.numeric(foo.row.hipC.x[c, (n.col+1):length(foo.row.hipC.x)]), pch=19, col=as.character(foo.row.hipC.x[c,]$Sk_color))
			}

			# DEPTH
			plot(as.numeric(foo.row.depth[1, (n.col+1):length(foo.row.depth)]), ylim=c(0,4), pch=19, col=as.character(foo.row.depth[1,]$Sk_color), ylab = "Change", xlab="Sample", main="Hip Center Depth")

			for(c in 1:nrow(foo.row.depth)){
				points(as.numeric(foo.row.depth[c, (n.col+1):length(foo.row.depth)]), pch=19, col=as.character(foo.row.depth[c,]$Sk_color))
			}

			dev.copy(pdf,paste("../diagnostic_plots/",as.character(foo.row.chest[1,1]), "-", as.character(foo.row.chest[1,2]), "-", as.character(foo.row.chest[1,3]), '.pdf'), width=11, height=6)
			dev.off()

			graphics.off()
			
			if(del.double == 1){
			myData.chest[myData.chest$Subject==unique.subj[a] & myData.chest$Recording == unique.trial[b],(n.col+1):ncol(myData.chest)] <- NA
			myData.hipC.x[myData.hipC.x $Subject==unique.subj[a] & myData.hipC.x$Recording == unique.trial[b],(n.col+1):ncol(myData.chest)] <- NA
			myData.depth[myData.depth $Subject==unique.subj[a] & myData.depth$Recording == unique.trial[b],(n.col+1):ncol(myData.chest)] <- NA
			}
				
		}

		# From here on the data are collapsed and processing is finished. 

		###
		# 8. 	
		if(col.collap == 1){
		
			# Apply trimming function (see neeco_functions.r for details).	
			foo.row.chest = collaps.across.skels(myData.chest[myData.chest$Subject==unique.subj[a] & myData.chest$Recording == unique.trial[b],], (n.col+1))
			foo.row.depth = collaps.across.skels(myData.depth[myData.depth $Subject==unique.subj[a] & myData.depth$Recording == unique.trial[b],], (n.col+1))			
			foo.row.hip.y = collaps.across.skels(myData.hip.y[myData.hip.y $Subject==unique.subj[a] & myData.hip.y$Recording == unique.trial[b],], (n.col+1))
			foo.row.head.y = collaps.across.skels(myData.head.y[myData.head.y $Subject==unique.subj[a] & myData.head.y $Recording == unique.trial[b],], (n.col+1))
			foo.row.footL.z = collaps.across.skels(myData.footL.z[myData.footL.z $Subject==unique.subj[a] & myData.footL.z $Recording == unique.trial[b],], (n.col+1))
			foo.row.footR.z = collaps.across.skels(myData.footR.z[myData.footR.z $Subject==unique.subj[a] & myData.footR.z $Recording == unique.trial[b],], (n.col+1))
		}
		#
		###
		
		# Continue if there is data.
		if(sum(!is.na(foo.row.depth))>0){

			###
			# 9.
			if(feet.crossed == 1){
				foo.row.chest <- left.right.crossed(foo.row.chest, foo.row.footL.z, foo.row.footR.z)
				foo.row.depth <- left.right.crossed(foo.row.depth, foo.row.footL.z, foo.row.footR.z)
				foo.row.hip.y <- left.right.crossed(foo.row.hip.y, foo.row.footL.z, foo.row.footR.z)			
			}	

			###
			# 10.
			if(head.too.low == 1){
				
				foo_med_down = (median(foo.row.head.y, na.rm=T) - median.cutoff) 
				foo.row.chest[foo.row.head.y < foo_med_down] <- NA
				foo.row.depth[foo.row.head.y < foo_med_down] <- NA
				foo.row.hip.y[foo.row.head.y < foo_med_down] <- NA
				
			}

			###
			# 11.
			if(interpl == 1){
				
				foo.row.chest = interpol.eyes(foo.row.chest, win.dow)
				foo.row.depth = interpol.eyes(foo.row.depth, win.dow)
				foo.row.hip.y = interpol.eyes(foo.row.hip.y, win.dow)
				
			}

			###
			# 12.
			if(abs.height == 1){

				if(!is.na(mean(foo.row.chest, na.rm = T))){
					if(mean(foo.row.chest, na.rm = T) >= abs.height.crit[2] || mean(foo.row.chest, na.rm = T) <= abs.height.crit[1]){
						foo.row.chest[1:length(foo.row.chest)] <- NA
						foo.row.depth[1:length(foo.row.depth)] <- NA
						foo.row.hip.y[1:length(foo.row.hip.y)] <- NA
					}
				}
			}
	
			###
			# 13.
			if(add.forward.filter == 1){
				
				control.depth <- get.forward.seq.short(foo.row.depth)				
				foo.row.depth.dummy <- foo.row.depth
				
				if(sum(!is.na(control.depth))<sum(!is.na(foo.row.depth.dummy)) && foo.row.depth.dummy[!is.na(foo.row.depth.dummy)][1] < 2.2){
					
				foo.row.chest[!is.na(foo.row.depth.dummy)][1] <- NA
				foo.row.depth[!is.na(foo.row.depth.dummy)][1] <- NA
				foo.row.hip.y[!is.na(foo.row.depth.dummy)][1] <- NA
	
				}

				if(sum(!is.na(control.depth))<sum(!is.na(foo.row.depth.dummy)) && foo.row.depth.dummy[!is.na(foo.row.depth.dummy)][length(foo.row.depth.dummy[!is.na(foo.row.depth.dummy)])] > 2.2){
					
				foo.row.chest[length(foo.row.depth.dummy[!is.na(foo.row.depth.dummy)])] <- NA
				foo.row.depth[length(foo.row.depth.dummy[!is.na(foo.row.depth.dummy)])] <- NA
				foo.row.hip.y[length(foo.row.depth.dummy[!is.na(foo.row.depth.dummy)])] <- NA
	
				}

				foo.row.chest[is.na(control.depth)] <- NA
				foo.row.depth[is.na(control.depth)] <- NA
				foo.row.hip.y[is.na(control.depth)] <- NA
				
				rm("control.depth")
			
			}
	
			###
			# 14. 	
			if(bin.data == 1){
			
			this.hip.z.bin = rep(NA, 1, win.dow)
    		this.hip.y.bin = rep(NA, 1, win.dow)
    		this.chest.y.bin = rep(NA, 1, win.dow)
            
    		for(d in 1:win.dow){
       			this.chest.y.bin[d] =  median(foo.row.chest[foo.row.depth <= start-win.length*(d-1) &   foo.row.depth > start-win.length*d], na.rm=T);
       			this.hip.z.bin[d] =  median(foo.row.depth[foo.row.depth <= start-win.length*(d-1) &   foo.row.depth > start-win.length*d], na.rm=T);
       			this.hip.y.bin[d] =  median(foo.row.hip.y[foo.row.depth <= start-win.length*(d-1) &   foo.row.depth > start-win.length*d], na.rm=T);
    		}
         
    		check.bin.den = rbind(check.bin.den, this.hip.z.bin)
      
    		}
         
    		###
			# 15. 	
			if(interpl == 1){
 			this.chest.y.bin = interpol.eyes(this.chest.y.bin,win.dow)   
    		this.hip.z.bin = interpol.eyes(this.hip.z.bin,win.dow)   
   			this.hip.y.bin = interpol.eyes(this.hip.y.bin,win.dow)   	
		}

    		###
			# 16. 	
			if(warp.data == 1){
    		if(sum(!is.na(this.chest.y.bin))>=min.data.bin){
    			this.chest.y.bin = warp.by.median(this.chest.y.bin, times=NULL, win.dow)
    			this.chest.y.bin = this.chest.y.bin$measure
    			this.hip.z.bin = warp.by.median(this.hip.z.bin, times=NULL, win.dow)
    			this.hip.z.bin = this.hip.z.bin $measure
    			this.hip.y.bin = warp.by.median(this.hip.y.bin, times=NULL, win.dow)
    			this.hip.y.bin = this.hip.y.bin $measure
  
				# Merge info
    			myData.depth.bin = rbind(myData.depth.bin, this.hip.z.bin)      	
    			myData.chest.bin = rbind(myData.chest.bin, this.chest.y.bin)
    			myData.hip.bin = rbind(myData.hip.bin, this.hip.y.bin)
    
    		}else if(sum(!is.na(this.chest.y.bin))<min.data.bin){
    			myData.depth.bin = rbind(myData.depth.bin, rep(NA, win.dow))      	
    			myData.chest.bin = rbind(myData.chest.bin, rep(NA, win.dow))
    			myData.hip.bin = rbind(myData.hip.bin, rep(NA, win.dow))
    
    		}    
 			}
	
	    ##     
  		# Get strings and add to dataframe.
	  	foo.str = myData.chest[myData.chest $Subject==unique.subj[a] & myData.chest $Recording == unique.trial[b],]
    	myData.str = rbind(myData.str, foo.str[1,1:((n.col+1)-1)])
		##

		}else if(sum(!is.na(foo.row.depth))==0){
		
    	##     
  		# Get strings and add to dataframe.		
  		foo.str = myData.chest[myData.chest $Subject==unique.subj[a] & myData.chest $Recording == unique.trial[b],]
    	myData.str = rbind(myData.str, foo.str[1,1:((n.col+1)-1)])
	
		myData.depth.bin = rbind(myData.depth.bin, rep(NA, win.dow))      	
    	myData.chest.bin = rbind(myData.chest.bin, rep(NA, win.dow))
    	myData.hip.bin = rbind(myData.hip.bin, rep(NA, win.dow))

		check.bin.den = rbind(check.bin.den, rep(NA, 20))
		##	
		}
	}
}

####
## Main Processing stop
###

# Make sure that each column in each new dataframe has the correct format.
myData.depth.bin = data.frame(myData.depth.bin, row.names=NULL)
myData.chest.bin = data.frame(myData.chest.bin, row.names=NULL)
myData.hip.bin = data.frame(myData.hip.bin, row.names=NULL)
myData.str = data.frame(myData.str, row.names=NULL)

# The results are 5 data frames, each should have the same number of rows:
# myData.str contains the string information.
nrow(myData.str)
# myData.chest.bin contain the chest height information.
nrow(myData.chest.bin)
# myData.hip.bin contain the hip height information.
nrow(myData.hip.bin)
# myData.depth.bin contain the distance (from the Kinect) information.
nrow(myData.depth.bin)
# check.bin.den is later used to determine how much data was captures per bin
nrow(check.bin.den)

# Clean workspace.
rm(list= ls()[!(ls() %in% c('myData.str','myData.chest.bin','myData.hip.bin','myData.depth.bin','check.bin.den'))])

# Save R-image file.
save.image(file=paste("../RImages/kinect_procs_Step1-",Sys.Date(),".RData",collapse="",sep = ""))

##############################################################################################################
#
# Bugs and improvements. 
#
##############################################################################################################

# Add info how much data per subject was dropped following which processing step.
myData.str[is.na(myData.chest.bin[,1]),]
nrow(myData.str[is.na(myData.chest.bin[,1]),])

