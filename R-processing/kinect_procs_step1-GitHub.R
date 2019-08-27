############################################################################
#
# First level processing script of Kinect-data. The script reads in
# the exported text file saved from the Matlab-recording routines to extract
# posture data for later processing and statistical analyses. 
#
# This is processing step 3 after the recording was was carried out using Matlab
# (Step 1) and after the text-data was extract from the raw recordings (Step 2). 
#
# Important note: There are still many redundancies, inefficiencies, and 
# idiosynracies in the script. 
# Note also that this script is constantly being improved to increase efficiency and reduce errors.
# Please use with care when adopting it to other 
# data sets!
#
# The output is R-Image-file (produced at the bottom of the script).
#
# This script is written for MacOS. Some commands do not work for Windows/Linux.
#
# Elements that are specific to the study are makred with ##.
#
# The processing of Kinect-data is based on:
#
# Hepach, R., Vaish, A., & Tomasello, M. (2017). The fulfillment of others’ needs elevates children’s body posture. Developmental psychology, 53(1), 100.
#
# Last changes March 2019 by RH
#
# Questions -> robert.hepach@uni-leipzig.de
############################################################################

# Clear workspace and close open graphic windows.
rm(list = ls(all = TRUE))
graphics.off()
getwd()
# Set working directory to the location of the script. 
# The folder "Txt-Data" should be on the same level as the folder that contains the script. 
# Load required functions. 
source("neeco_functions.r")
library(plyr)

# Set directory for plots (optional).
# plot.dir = "../neeco-plots/"

############################################################################
#
# Set variables.
#

# Maximum distance away from the Kinect to be included in processing:
start = 3.2						
# Minimum distance away from the Kinect to be included in processing:
stop = 1.2 							
# Number of distance windows into which data are later binned:
win.dow = (start-stop)*10
# Length of each window:				
win.length = (start-stop)/win.dow;
n.col = 7 		  # First numeric column during Preprocessing 1.
n.skel.col = 3*20 # 20 skeletons with 3 coordinates.

# # Used for processing of forward moving sequence.
# min.frame.length = 10
# max.distance = 0
# min.distance = 1.2		

median.cutoff = 0.1 # see 9.		
child.filter.set = c(-0.4, 0.5) # see 11.

# Maximum number of frames recorded. 
max.col = 10*30 # Assumming 10 seconds with 30 frames each.

#
############################################################################

# The following empty containers are used for storing parts of the processed data.
myData.depth.bin = c()
myData.chest.bin = c()
myData.hip.bin = c()
myData.str = c()
check.bin.den = c()

############################################################################

# Read in data.
flist = list.files("../Txt-Data/")

myData = c()
max.col = 30*10


for(i in 1:length(flist)){ #(1)
	now.myData <- read.table(file= paste("../Txt-Data/", flist[i], collapse="",sep = ""),header=T,sep="\t")
	myData = rbind(myData, now.myData)
	rm("now.myData")
}



# Order by Subject
##
myData = myData[order(myData[,1]),]
##

####
## Pre-Processing Step 1 start
###

##
# Check recording per subject.
table(myData$Subject, myData$Recording)
# Looks good. No more than 8 Recordings.

table(myData$Subject, myData$Trial)
# Suggests that one subject was recorded with string 'Baseline 2' instead of 'Baseline 1'. Rename!
# levels(myData$Trial) <- c("Baseline 1", "Baseline 1")
myData = droplevels(myData)

#! Move the following to a function!
# Change structure of data array for later processing.
myData.mod = c()
unique.subj = unique(myData$Subject) 

for(s in 1:length(unique.subj)){

	now.subj = subset(myData, Subject== unique.subj[s])
	now.subj = droplevels(now.subj)
	unique.trial = unique(now.subj $Trial) 

	for(a in 1:length(unique.trial)){
	
		now.trial = subset(now.subj, Trial== unique.trial[a])
		now.trial = droplevels(now.trial)
		unique.rec = unique(now.trial$Recording) 
	
		for(b in 1:length(unique.rec)){

			now.rec = subset(now.trial, Recording == unique.rec[b])
			Skeleton = names(now.rec[, n.col:(n.skel.col+(n.col-1))])
			unique.skel = unique(now.rec$Sk_color)
		
			for(c in 1:length(unique.skel)){

				now.skel = subset(now.rec, Sk_color == unique.skel[c])
				now.dataframe = c()
				
				for(d in 1:length(Skeleton)){
			
					now.dataframe = rbind(now.dataframe, as.numeric(t(subset(now.rec, select= Skeleton[d]))))
				}
				
				now.dataframe  = data.frame(now.dataframe)
				
				if(ncol(now.dataframe)<max.col){now.dataframe = cbind(now.dataframe, matrix(NA, nrow= nrow(now.dataframe), ncol= (max.col-ncol(now.dataframe))))}else if(ncol(now.dataframe)>=max.col){
				now.dataframe = now.dataframe[,1: max.col]	
				}
				
				names(now.dataframe) <- c(1:max.col)
				rep.line = now.rec[1,1:(n.col-1)]
				rep.line = rep.line[rep(seq_len(nrow(rep.line)), length(Skeleton)), ]
				temp.frame = data.frame(cbind(rep.line ,data.frame(Skeleton), now.dataframe), row.names = NULL)

				myData.mod  = rbind(myData.mod, temp.frame)
			}
		}	
	}	
}	
	
myData = myData.mod
rm("myData.mod")
				
for(a in (n.col+1):ncol(myData)){		
myData[,a] = as.numeric(as.character(myData[,a]))
}

# Check structure.
str(myData)

##
# myData = rename(myData, c("Number.of.Frames"="Trial"))

# Shorten data columns
myData.colWithdata = as.numeric(apply(myData[,(n.col+1):ncol(myData)],2,FUN=mean,na.rm=T))
myData.colWithdata[myData.colWithdata>0] <- 1
plot(myData.colWithdata)
foo.counter = c(1:length(myData.colWithdata))
max(foo.counter[myData.colWithdata==1], na.rm=T)
# Trim data set to speed up processing
myData = myData[,1:((n.col+1)+max(foo.counter[myData.colWithdata==1], na.rm=T))]
rm("myData.colWithdata", "foo.counter")
##

# Selects the relevant X-,Y-, and Z-coordinates for the specific skeletal points. Only these skeletal points will be used for later processing.

myData $Recording <- do.call(paste, c(myData[c("Trial", "Recording")], sep = "-"))

# Chest height
myData.chest = subset(myData, Skeleton=="Shoulder_Center_Y")
myData.chest = droplevels(myData.chest)

# Hip depth
myData.depth = subset(myData, Skeleton=="Hip_Center_Z")
myData.depth = droplevels(myData.depth)

# Head Y
myData.head.y = subset(myData, Skeleton=="Head_Y")
myData.head.y = droplevels(myData.head.y)

# Spine Y
myData.spine.y = subset(myData, Skeleton=="Spine_Y")
myData.spine.y = droplevels(myData.spine.y)

# Hip Y
myData.hip.y = subset(myData, Skeleton=="Hip_Center_Y")
myData.hip.y = droplevels(myData.hip.y)

# Hip X
myData.hipL.x = subset(myData, Skeleton=="Hip_Left_X")
myData.hipL.x = droplevels(myData.hipL.x)

myData.hipC.x = subset(myData, Skeleton=="Hip_Center_X")
myData.hipC.x = droplevels(myData.hipC.x)

myData.hipR.x = subset(myData, Skeleton=="Hip_Right_X")
myData.hipR.x = droplevels(myData.hipR.x)

# Shoulder X
myData.shoL.x = subset(myData, Skeleton=="Shoulder_Left_X")
myData.shoL.x = droplevels(myData.shoL.x)

myData.shoC.x = subset(myData, Skeleton=="Shoulder_Center_X")
myData.shoC.x = droplevels(myData.shoC.x)

myData.shoR.x = subset(myData, Skeleton=="Shoulder_Right_X")
myData.shoR.x = droplevels(myData.shoR.x)

# Elbow X
myData.elbL.x = subset(myData, Skeleton =="Elbow_Left_X")
myData.elbL.x = droplevels(myData.elbL.x)

myData.elbR.x = subset(myData, Skeleton =="Elbow_Right_X")
myData.elbR.x = droplevels(myData.elbR.x)

# Feet Z
myData.footL.z = subset(myData, Skeleton =="Foot_Left_Z")
myData.footL.z = droplevels(myData.footL.z)

myData.footR.z = subset(myData, Skeleton =="Foot_Right_Z")
myData.footR.z = droplevels(myData.footR.z)

# Check that all dataframes has the same number of rows.
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

####
## Pre-Processing Step 1 stop
###

# We now have one data frame for each skeletal point, i.e., those skeletal points that are needed for later processing. Each row represents a forward movement per trial.

####
## Main Processing start
###

###
# This carries out the main processing for each movement. The individual steps are as follows:

# 1. Collapse across colors?
col.collap = 1

# 2. Remove data outside tracking range?
data.inside = 1

# 3. Remove data before feet crossed. This ensures that children were walking toward the camera.	
feet.crossed = 1

# 4. Is the center back above the hip center? Remove frame if not.
upright.back = 1

# 5. Is the head above the shoulder? Remove frame if not.
head.above.shoulder = 1

# 6. Is the shoulder above the center back? Remove frame if not.
shoulder.above.back = 1

# 7. Is the center hip between left and right hip? Remove frame if not.
centered.hip = 1

# 8. Is the center shoulder between left and right shoulder? Remove frame if not.
centered.shoulder = 1

# 9. Remove frame if the head is too low (XX cm below the median, see preamble), i.e., when child is crouching down.
head.too.low = 1

# 10. Interpolate resulting gaps.
interpl = 1

# 11. Remove entire trial if skeleton is likely not mapped on child (if chest height is greater than XX cm above the Kinect or lower than YY cm below the Kinect; see preamble).
child.filter = 0

# 12. Run an additional forward sequence filter, short version.
add.forward.filter = 1

# 13. Bin data. 	
bin.data = 1

# 14. Interpolate resulting gaps.
interpl = 1

# 15. Warp data at the beginning and end of each data row.
warp.data = 1

###

unique.subj  = unique(myData.chest$Subject)

# Loop through each subject.
for(a in 1:length(unique.subj)){

	# Select chest point data for current subject.
	now.subj = subset(myData.chest, Subject ==unique.subj[a])
	
	# Select recorded trials for each subject.
	unique.trial = unique(now.subj$Recording)

	# Loop through each trial for each subject.
	for(b in 1:length(unique.trial)){
		
		###
		# 1.
		if(col.collap == 1){
		
			# Apply trimming function (see neeco_functions.r for details).	
			foo.row.chest = collaps.across.skels(myData.chest[myData.chest$Subject ==unique.subj[a] & myData.chest$Recording == unique.trial[b],], (n.col+1))
			foo.row.depth = collaps.across.skels(myData.depth[myData.depth $Subject ==unique.subj[a] & myData.depth$Recording == unique.trial[b],], (n.col+1))
			foo.row.head.y = collaps.across.skels(myData.head.y[myData.head.y $Subject ==unique.subj[a] & myData.head.y $Recording == unique.trial[b],], (n.col+1))
			foo.row.spine.y = collaps.across.skels(myData.spine.y[myData.spine.y$Subject ==unique.subj[a] & myData.spine.y$Recording == unique.trial[b],], (n.col+1))
			foo.row.hip.y = collaps.across.skels(myData.hip.y[myData.hip.y $Subject ==unique.subj[a] & myData.hip.y$Recording == unique.trial[b],], (n.col+1))
			foo.row.hipC.x = collaps.across.skels(myData.hipC.x[myData.hipC.x $Subject ==unique.subj[a] & myData.hipC.x$Recording == unique.trial[b],], (n.col+1))
			foo.row.hipL.x = collaps.across.skels(myData.hipL.x[myData.hipL.x$Subject ==unique.subj[a] & myData.hipL.x$Recording == unique.trial[b],], (n.col+1))
			foo.row.hipR.x = collaps.across.skels(myData.hipR.x[myData.hipR.x $Subject ==unique.subj[a] & myData.hipR.x$Recording == unique.trial[b],], (n.col+1))
			foo.row.shoC.x = collaps.across.skels(myData.shoC.x[myData.shoC.x $Subject ==unique.subj[a] & myData.shoC.x$Recording == unique.trial[b],], (n.col+1))
			foo.row.shoL.x = collaps.across.skels(myData.shoL.x[myData.shoL.x $Subject ==unique.subj[a] & myData.shoL.x $Recording == unique.trial[b],], (n.col+1))
			foo.row.shoR.x = collaps.across.skels(myData.shoR.x[myData.shoR.x $Subject ==unique.subj[a] & myData.shoR.x $Recording == unique.trial[b],], (n.col+1))
			foo.row.elbL.x = collaps.across.skels(myData.elbL.x[myData.elbL.x $Subject ==unique.subj[a] & myData.elbL.x $Recording == unique.trial[b],], (n.col+1))
			foo.row.elbR.x = collaps.across.skels(myData.elbR.x[myData.elbR.x $Subject ==unique.subj[a] & myData.elbR.x $Recording == unique.trial[b],], (n.col+1))
			foo.row.footL.z = collaps.across.skels(myData.footL.z[myData.footL.z $Subject ==unique.subj[a] & myData.footL.z $Recording == unique.trial[b],], (n.col+1))
			foo.row.footR.z= collaps.across.skels(myData.footR.z[myData.footR.z $Subject ==unique.subj[a] & myData.footR.z $Recording == unique.trial[b],], (n.col+1))
		
		}
		#
		###
		
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
			# 2.
			if(data.inside == 1){

				control.depth = foo.row.depth
	
				# Delete all data after the last 1m frame
				foo.count = c(1:length(control.depth))
				foo.control.depth = as.numeric(rep(NA, length(control.depth)))
				foo.control.depth[foo.row.depth<=stop] <- 1
				foo.count = foo.count[!is.na(foo.control.depth)]
				foo.control.depth = foo.control.depth[!is.na(foo.control.depth)]

				if(length(!is.na(foo.count))>0){
						
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
			}
			#
			###
		
			###
			# 3.
			if(feet.crossed == 1){
				
				foo.row.chest <- left.right.crossed(foo.row.chest, foo.row.footL.z, foo.row.footR.z)
				foo.row.depth <- left.right.crossed(foo.row.depth, foo.row.footL.z, foo.row.footR.z)
				foo.row.hip.y <- left.right.crossed(foo.row.hip.y, foo.row.footL.z, foo.row.footR.z)		
				
				# This already focusses on the three final arrays of interest: The chest height, the hip height, and the distance of the subject.
			}	
			
			###
			# 4.
			if(upright.back == 1){
				
				temp.hip = foo.row.hip.y
				foo.row.chest[foo.row.spine.y <= temp.hip] <- NA
				foo.row.depth[foo.row.spine.y <= temp.hip] <- NA
				foo.row.hip.y[foo.row.spine.y <= temp.hip] <- NA
				rm("temp.hip")

			}
	
			###
			# 5.
			if(head.above.shoulder == 1){
				
				temp.chest = foo.row.chest
				foo.row.chest[foo.row.head.y <= temp.chest] <- NA
				foo.row.depth[foo.row.head.y <= temp.chest] <- NA		
				foo.row.hip.y[foo.row.head.y <= temp.chest] <- NA		
				rm("temp.chest")
				
			}
	
			###
			# 6.
			if(shoulder.above.back == 1){
				
				temp.chest = foo.row.chest
				foo.row.chest[foo.row.spine.y >= temp.chest] <- NA
				foo.row.depth[foo.row.spine.y >= temp.chest] <- NA	
				foo.row.hip.y[foo.row.spine.y >= temp.chest] <- NA	
				rm("temp.chest")
				
			}

			###
			# 7.
			if(centered.hip == 1){
				
				foo.row.chest[foo.row.hipC.x < foo.row.hipL.x] <- NA
				foo.row.depth[foo.row.hipC.x < foo.row.hipL.x] <- NA		
				foo.row.chest[foo.row.hipC.x > foo.row.hipR.x] <- NA
				foo.row.depth[foo.row.hipC.x > foo.row.hipR.x] <- NA		
				
			}

			###
			# 8.
			if(centered.shoulder == 1){
				
				foo.row.chest[foo.row.shoC.x < foo.row.shoL.x] <- NA
				foo.row.depth[foo.row.shoC.x < foo.row.shoL.x] <- NA		
				foo.row.chest[foo.row.shoC.x > foo.row.shoR.x] <- NA
				foo.row.depth[foo.row.shoC.x > foo.row.shoR.x] <- NA		
				
			}

			###
			# 9.
			if(head.too.low == 1){
				
				foo_med_down = (median(foo.row.head.y, na.rm=T) - median.cutoff) 
				foo.row.chest[foo.row.head.y < foo_med_down] <- NA
				foo.row.depth[foo.row.head.y < foo_med_down] <- NA
				foo.row.hip.y[foo.row.head.y < foo_med_down] <- NA
				
			}

			###
			# 10.
			if(interpl == 1){
				
				foo.row.chest = interpol.eyes(foo.row.chest, win.dow)
				foo.row.depth = interpol.eyes(foo.row.depth, win.dow)
				foo.row.hip.y = interpol.eyes(foo.row.hip.y, win.dow)
				
			}

			###
			# 11.
			if(child.filter == 1){

				if(!is.na(mean(foo.row.chest, na.rm = T))){
					if(mean(foo.row.chest, na.rm = T) >= child.filter.set[2] || mean(foo.row.chest, na.rm = T) <= child.filter.set[1]){
						foo.row.chest[1:length(foo.row.chest)] <- NA
						foo.row.depth[1:length(foo.row.depth)] <- NA
						foo.row.hip.y[1:length(foo.row.hip.y)] <- NA
					}
				}
			}
		
			###
			# 12.
			if(add.forward.filter == 1){
				
				control.depth <- get.forward.seq.short(foo.row.depth)
				foo.row.chest[is.na(control.depth)] <- NA
				foo.row.depth[is.na(control.depth)] <- NA
				foo.row.hip.y[is.na(control.depth)] <- NA
				rm("control.depth")

			}

			###
			# 13. 	
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
         s
         }
         
         ###
		 # 14. 	
		if(interpl == 1){
				
 			this.chest.y.bin = interpol.eyes(this.chest.y.bin,win.dow)   
    		this.hip.z.bin = interpol.eyes(this.hip.z.bin,win.dow)   
   			this.hip.y.bin = interpol.eyes(this.hip.y.bin,win.dow)   
				
		}

         ###
		 # 15. 	
		if(warp.data == 1){
    		if(sum(!is.na(this.chest.y.bin))>1){
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
    
    		}else if(sum(!is.na(this.chest.y.bin))<=1){
    			myData.depth.bin = rbind(myData.depth.bin, rep(NA, win.dow))      	
    			myData.chest.bin = rbind(myData.chest.bin, rep(NA, win.dow))
    			myData.hip.bin = rbind(myData.hip.bin, rep(NA, win.dow))
    
    		}else{
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
  	foo.str = myData.chest[myData.chest $Subject_ID==unique.subj[a] & myData.chest $Recording == unique.trial[b],]
    myData.str = rbind(myData.str, foo.str[1,1:((n.col+1)-1)])
	
	myData.depth.bin = rbind(myData.depth.bin, rep(NA, win.dow))      	
    myData.chest.bin = rbind(myData.chest.bin, rep(NA, win.dow))
    myData.hip.bin = rbind(myData.hip.bin, rep(NA, win.dow))

	check.bin.den = rbind(check.bin.den, NA)
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


##This function identifies recording folders, in which no skelton could be found by the script. 
myData.str[is.na(myData.chest.bin[,1]),]

# Clean workspace.
rm(list= ls()[!(ls() %in% c('myData.str','myData.chest.bin','myData.hip.bin','myData.depth.bin','check.bin.den'))])

# Save R-image file.
save.image(file=paste("../kinect_procs_Step1-GitHub-",Sys.Date(),".RData",collapse="",sep = ""))

###############################################################################################################
#
# Bugs and improvements. 
#
###############################################################################################################

# Add info how much data per subject was dropped following which processing step.

