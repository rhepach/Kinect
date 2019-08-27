############################################################################
#
# Second level processing script of Kinect-data. The script reads in
# the R-image-files resulting from the previous processing step to
# baseline-correct, generate plots, and run statistical analyses.
#
# Important note: There are still many redundancies, inefficiencies, and 
# idiosynracies in the script. Please use with care when adopting it to other 
# data sets!
#
#
# This script is written for MacOS. Some commands do not work for Windows/Linux.
#
# The script, at this level of data processing, is very specific to each study
# and dependent on the number of recordings, experimental conditons, excluded
# participant and trials, etc. It needs to be carefully adapted to each data set. 
# Note also that this script is constantly being improved to increase efficiency and reduce errors.
# At the same time there are 5 steps that are taken from reading in the data to
# running the statistical analyses.
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

# Load required functions and packages.
source("neeco_functions.r")
library(sciplot)
library(lme4)
library(plyr)
library(ggplot2)
library(simr)
library(lattice)
library(reshape2)
library(car)
library(ppcor)


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

# Based on the visual inspection of the density plots, this is the distance bin from which there
# was enough data found (above 0.9*median)
valid.col = 1 # No data columns are dropped.

# For the statisical analyses, this the final column with string values.
f.col = 9

#
############################################################################

#####
# (1) Read in and prepare data frame.
#####

getwd()
#setwd("/Users/stellagerdemann/Google Drive/Stella PhD Studien/Involve/Manuscript/Pilot data and analysis scripts/Body posture/R-Processsing")
# Load image files.
load("./kinect_procs_Step1-Involve-2019-08-26.RData")

# For the entire walking range of 20 bins, check how much data there is.
check.bin.den2 = check.bin.den
check.bin.den2[!is.na(check.bin.den2)] <-1 
# Maximum number of possible samples for each bin
nrow(check.bin.den2)
# Actual number of data points per bin.
apply(check.bin.den2, 2, FUN=sum, na.rm=T)

# Actual number of data points per bin.
plot(apply(check.bin.den2, 2, FUN=sum, na.rm=T)/nrow(check.bin.den), ylim=c(0,1), ylab = "Percentage of found data points", main="Amount of data per bin and median,\n90% median, and 50% median plotted.", xlab="Distance bin from Kinect")
abline(h=median(apply(check.bin.den2, 2, FUN=sum, na.rm=T)/nrow(check.bin.den)))
abline(h=0.9*median(apply(check.bin.den2, 2, FUN=sum, na.rm=T))/nrow(check.bin.den), col="red", lty = 2)
abline(h=0.5*median(apply(check.bin.den2, 2, FUN=sum, na.rm=T))/nrow(check.bin.den), col="red", lty = 2)





hist(check.bin.den, ylim = c(0, nrow(check.bin.den2)), breaks=20,ylab = "Number of found data points", main="Amount of data per bin", xlab="Proximity bin to Kinect",xaxt="n")
axis(side=1, at=c(1.2,1.7,2.2,2.7,3.2))

#####
# Subject exclusions
#####


# This is how individual subjects can be excluded.

#myData.chest.bin = myData.chest.bin[myData.str$Subject!="20190307T151839_Involve_pilot_9_f_social_8&9_8.991101985_unequal_equal",]
#myData.hip.bin = myData.hip.bin[myData.str$Subject!="20190307T151839_Involve_pilot_9_f_social_8&9_8.991101985_unequal_equal",]
# myData.str = myData.str[myData.str$Subject!="20190307T151839_Involve_pilot_9_f_social_8&9_8.991101985_unequal_equal",]
 myData.str = droplevels(myData.str)

#####
# (2) Perfrom phase merging (within baseline and within each test trial)
#####
myData.str 

myData.hip.condensed = c()
myData.chest.condensed = c()
myData.str.condensed = c()
subjects = unique(myData.str$Subject)


# Loop through data array. Merge data within baseline and all test phases (given that there could be multiple walks per baseline).
for(a in 1:length(subjects)){

	foo.str = myData.str[myData.str $Subject==subjects[a],]
	foo.chest = myData.chest.bin[myData.str $Subject==subjects[a], ]
	foo.hip = myData.hip.bin[myData.str $Subject==subjects[a], ]
				
	# Baseline
	if(sum(!is.na(as.numeric(apply(foo.chest[foo.str$Trial  =="Baseline 1",],2, FUN=mean, na.rm=T))))>0){
		
		# Chest data
		foo.bl = apply(foo.chest[foo.str$Trial  =="Baseline 1",], 2, mean, na.rm=T)		
		foo.bl = as.numeric(foo.bl)
		foo.bl[foo.bl =="NaN"] <- NA
		foo.bl = as.numeric(foo.bl)
    	myData.chest.condensed = rbind(myData.chest.condensed, t(foo.bl))
		rm("foo.bl")
		
		# Hip data
		foo.bl = apply(foo.hip[foo.str$Trial  =="Baseline 1",], 2, mean, na.rm=T)
		foo.bl = as.numeric(foo.bl)
		foo.bl[foo.bl =="NaN"] <- NA
		foo.bl = as.numeric(foo.bl)
		myData.hip.condensed = rbind(myData.hip.condensed, t(foo.bl))
		rm("foo.bl")

		# String data.
		foo.bl.str = foo.str[foo.str$Trial  =="Baseline 1",]
		foo.bl.str = foo.bl.str[1,]
		myData.str.condensed = rbind(myData.str.condensed, foo.bl.str)
		rm("foo.bl.str")
		
	}else if(sum(!is.na(as.numeric(apply(foo.chest[foo.str$Trial  =="Baseline 1",],2, FUN=mean, na.rm=T))))==0){
		
		##
		foo.bl.str = foo.str[1,]
		foo.bl.str$Trial  <- "Baseline 1"
		##
		myData.str.condensed = rbind(myData.str.condensed, foo.bl.str)
		rm("foo.bl.str")

		temp.array = rep(NA, win.dow)
		colnames(temp.array) = colnames(myData.chest.condensed)
		myData.chest.condensed = rbind(myData.chest.condensed, temp.array)
		rm("temp.array")

		temp.array = rep(NA, win.dow)
		colnames(temp.array) = colnames(myData.hip.condensed)
		myData.hip.condensed = rbind(myData.hip.condensed, temp.array)
		rm("temp.array")

	}	
	
	
		# Block 1
	if(sum(!is.na(as.numeric(apply(foo.chest[foo.str$Recording =="Test 1-1",],2, FUN=mean, na.rm=T))))>0){
		
		# Chest data
		foo.bl = apply(foo.chest[foo.str$Recording =="Test 1-1",], 2, mean, na.rm=T)		
		foo.bl = as.numeric(foo.bl)
		foo.bl[foo.bl =="NaN"] <- NA
		foo.bl = as.numeric(foo.bl)
    	myData.chest.condensed = rbind(myData.chest.condensed, t(foo.bl))
		rm("foo.bl")
		
		# Hip data
		foo.bl = apply(foo.hip[foo.str$Recording =="Test 1-1",], 2, mean, na.rm=T)
		foo.bl = as.numeric(foo.bl)
		foo.bl[foo.bl =="NaN"] <- NA
		foo.bl = as.numeric(foo.bl)
		myData.hip.condensed = rbind(myData.hip.condensed, t(foo.bl))
		rm("foo.bl")

		# String data.
		foo.bl.str = foo.str[foo.str$Recording =="Test 1-1",]
		foo.bl.str = foo.bl.str[1,]
		myData.str.condensed = rbind(myData.str.condensed, foo.bl.str)
		rm("foo.bl.str")
		
	}else if(sum(!is.na(as.numeric(apply(foo.chest[foo.str$Recording =="Test 1-1",],2, FUN=mean, na.rm=T))))==0){
		
		##
		foo.bl.str = foo.str[1,]
		foo.bl.str$Recording <-"Test 1-1"
		##
		myData.str.condensed = rbind(myData.str.condensed, foo.bl.str)
		rm("foo.bl.str")

		temp.array = rep(NA, win.dow)
		colnames(temp.array) = colnames(myData.chest.condensed)
		myData.chest.condensed = rbind(myData.chest.condensed, temp.array)
		rm("temp.array")

		temp.array = rep(NA, win.dow)
		colnames(temp.array) = colnames(myData.hip.condensed)
		myData.hip.condensed = rbind(myData.hip.condensed, temp.array)
		rm("temp.array")

	}	

	
	# Block 1
	if(sum(!is.na(as.numeric(apply(foo.chest[foo.str$Recording =="Test 1-2",],2, FUN=mean, na.rm=T))))>0){
		
		# Chest data
		foo.bl = apply(foo.chest[foo.str$Recording =="Test 1-2",], 2, mean, na.rm=T)		
		foo.bl = as.numeric(foo.bl)
		foo.bl[foo.bl =="NaN"] <- NA
		foo.bl = as.numeric(foo.bl)
    	myData.chest.condensed = rbind(myData.chest.condensed, t(foo.bl))
		rm("foo.bl")
		
		# Hip data
		foo.bl = apply(foo.hip[foo.str$Recording =="Test 1-2",], 2, mean, na.rm=T)
		foo.bl = as.numeric(foo.bl)
		foo.bl[foo.bl =="NaN"] <- NA
		foo.bl = as.numeric(foo.bl)
		myData.hip.condensed = rbind(myData.hip.condensed, t(foo.bl))
		rm("foo.bl")

		# String data.
		foo.bl.str = foo.str[foo.str$Recording =="Test 1-2",]
		foo.bl.str = foo.bl.str[1,]
		myData.str.condensed = rbind(myData.str.condensed, foo.bl.str)
		rm("foo.bl.str")
		
	}else if(sum(!is.na(as.numeric(apply(foo.chest[foo.str$Recording =="Test 1-2",],2, FUN=mean, na.rm=T))))==0){
		
		##
		foo.bl.str = foo.str[1,]
		foo.bl.str$Recording <-"Test 1-2"
		##
		myData.str.condensed = rbind(myData.str.condensed, foo.bl.str)
		rm("foo.bl.str")

		temp.array = rep(NA, win.dow)
		colnames(temp.array) = colnames(myData.chest.condensed)
		myData.chest.condensed = rbind(myData.chest.condensed, temp.array)
		rm("temp.array")

		temp.array = rep(NA, win.dow)
		colnames(temp.array) = colnames(myData.hip.condensed)
		myData.hip.condensed = rbind(myData.hip.condensed, temp.array)
		rm("temp.array")

	}	

	
	

}


myData.hip.condensed = data.frame(myData.hip.condensed, row.names=NULL)
myData.chest.condensed = data.frame(myData.chest.condensed, row.names=NULL)
myData.str.condensed = droplevels(myData.str.condensed)

#####
# (3) Perfrom baseline correction for final dataframe.
#####

table(myData.str.condensed $Subject, myData.str.condensed $Recording)
table(myData.str.condensed $Recording, myData.str.condensed $Recording) #! Check whether this is an issue. 

myData.chest.blcorrected = c()
myData.hip.blcorrected = c()

subj.unique = unique(myData.str.condensed $Subject)



for(a in 1:length(subj.unique)){

	foo.str = myData.str.condensed[myData.str.condensed $Subject == subj.unique[a],]
	
	# Chest data.
	foo.data.chest = myData.chest.condensed[myData.str.condensed $Subject== subj.unique[a],]
	foo.bl.chest = as.numeric(foo.data.chest[foo.str$Recording =="Baseline 1-1",])
	foo.data.chest = foo.data.chest[-1,]
	
	for(b in 1:nrow(foo.data.chest)){
		foo.data.chest[b,] = foo.data.chest[b,]-foo.bl.chest 
	}
	
	myData.chest.blcorrected = rbind(myData.chest.blcorrected, foo.data.chest)

	# Hip data.
	foo.data.hip = myData.hip.condensed[myData.str.condensed $Subject== subj.unique[a],]
	foo.bl.hip = as.numeric(foo.data.hip[foo.str$Recording =="Baseline 1-1",])
	foo.data.hip = foo.data.hip[-1,]
	
	for(b in 1:nrow(foo.data.hip)){
		foo.data.hip[b,] = foo.data.hip[b,]-foo.bl.hip 
	}
	
	myData.hip.blcorrected = rbind(myData.hip.blcorrected, foo.data.hip)

	rm("foo.str", "foo.data.hip", "foo.data.chest", "foo.bl.hip", "foo.bl.chest")
}

myData.str.condensed = subset(myData.str.condensed, Recording!="Baseline 1-1")
myData.str.condensed = droplevels(myData.str.condensed)

nrow(myData.str.condensed)
nrow(myData.chest.blcorrected)
nrow(myData.hip.blcorrected)

table(myData.str.condensed$Subject, myData.str.condensed$Recording)


names(myData.str.condensed) <- c("Subject", "Trial", "Condition", "Frame", "Kinect", "Sk_color",  "Skeleton")

#####
# (4) Generate plots.
#####

myData.chest.4plot = myData.chest.blcorrected[, valid.col:ncol(myData.chest.blcorrected)]
myData.hip.4plot = myData.hip.blcorrected[, valid.col:ncol(myData.hip.blcorrected)]




# Chest data.



Test_1 = myData.chest.4plot[ myData.str.condensed $Condition =="Test 1-1"   ,]
Test_1.m = apply(Test_1,2, mean, na.rm=T )
Test_1.se = apply(Test_1,2, se, na.rm=T )
Test_1.se = as.numeric(Test_1.se)


Test_2 = myData.chest.4plot[ myData.str.condensed $Condition =="Test 1-2"   ,]
Test_2.m = apply(Test_2,2, mean, na.rm=T )
Test_2.se = apply(Test_2,2, se, na.rm=T )
Test_2.se = as.numeric(Test_2.se)

# Line plot 
quartz(width=11, height=6)
par(mfrow=c(1,2))

# Plot 4&5-year-olds
plot(Test_2.m, type="n", ylim=c(-0.1, 0.1), xlab="Time", axes=T,ylab="Change in Chest Height (m)", main = "Example Data (Chest Height)")
lines(Test_1.m, col = "lightskyblue", lwd=6, lty=1)
lines(Test_2.m, col = "salmon", lwd=6, lty=1)



myData.chest.4plot = myData.chest.blcorrected[, valid.col:ncol(myData.chest.blcorrected)]
myData.hip.4plot = myData.hip.blcorrected[, valid.col:ncol(myData.hip.blcorrected)]

# Hip data.

Test_1 = myData.hip.4plot[ myData.str.condensed $Condition =="Test 1-1"   ,]
Test_1.m = apply(Test_1,2, mean, na.rm=T )
Test_1.se = apply(Test_1,2, se, na.rm=T )
Test_1.se = as.numeric(Test_1.se)


Test_2 = myData.hip.4plot[ myData.str.condensed $Condition =="Test 1-2"   ,]
Test_2.m = apply(Test_2,2, mean, na.rm=T )
Test_2.se = apply(Test_2,2, se, na.rm=T )
Test_2.se = as.numeric(Test_2.se)

# Plot 4&5-year-olds
plot(Test_2.m, type="n", ylim=c(-0.1, 0.1), xlab="Time", axes=T,ylab="Change in Hip Height (m)", main = "Example Data (Hip Height)")
lines(Test_1.m, col = "lightskyblue", lwd=6, lty=1)
lines(Test_2.m, col = "salmon", lwd=6, lty=1)



#####
# (5) Statistical analyses.
#####

model.data = cbind(myData.str.condensed,  myData.chest.blcorrected)

head(model.data)

model.data.t <- melt(model.data, id.vars=c("Subject","Trial", "Condition","Frame", "Kinect", "Sk_color",          "Skeleton"))

names(model.data.t )[names(model.data.t ) == "variable"] <- "Time"
names(model.data.t )[names(model.data.t ) == "value"] <- "Change"

table(model.data.t$Condition)
str(model.data.t)
head(model.data.t)

model.data.t$Time = as.numeric(model.data.t $Time)
model.data.t$z.time=as.vector(scale(model.data.t $Time))

model.data.t$Condition=as.factor(model.data.t$Condition)

Model.1a = lmer(Change ~ Condition+ (1|Subject)+ (0+ z.time |Subject), data= model.data.t, REML=F)
summary(Model.1a)
drop1(Model.1a, test="Chisq")


sessionInfo()