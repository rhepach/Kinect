############################################################################
#
# Support functions for Kinect-data processing
# 
# Currently used in:
# Study: Neeco (2015 - 2019)
# Researchers: Robert Hepach and Michael Tomasello
#
# The processing of Kinect-data is based on:
#
# Hepach, R., Vaish, A., & Tomasello, M. (2017). The fulfillment of others’ needs elevates children’s body posture. Developmental psychology, 53(1), 100.
#
# Last changes November 2019 by RH
#
# Questions -> robert.hepach@uni-leipzig.de
############################################################################

####
# Function fun.change.structure
####

fun.change.structure <- function(myData, unique.subj, func.col, fun.max.col, foo.rel.height, crit.valX){

# unique.subj = unique(myData$Subject)
# func.col = (n.col-1)
# fun.max.col = fun.max.col
# foo.rel.height = 1
# crit.val = 0.4

# Create empty container.
myData.mod = c()

for(s in 1:length(unique.subj)){

	now.subj = subset(myData, Subject== unique.subj[s])
	now.subj = droplevels(now.subj)
	unique.trial = unique(now.subj$Trial) 

	for(a in 1:length(unique.trial)){
	
		now.trial = subset(now.subj, Trial== unique.trial[a])
		now.trial = droplevels(now.trial)
		unique.rec = unique(now.trial$Recording) 
	
		for(b in 1:length(unique.rec)){

			now.rec = subset(now.trial, Recording == unique.rec[b])
			now.rec = droplevels(now.rec)
			unique.col = unique(now.rec $Sk_color) 

			# Here apply relative height filter.
			if(length(unique.col)==3 && foo.rel.height ==1){
				now.rec.skel1 = now.rec[now.rec$Sk_color== unique.col[1],]
				now.rec.skel2 = now.rec[now.rec$Sk_color== unique.col[2],]
				now.rec.skel3 = now.rec[now.rec$Sk_color== unique.col[3],]
				now.rec.skel1.mean = median(now.rec.skel1$Shoulder_Center_Y, na.rm=T)
				now.rec.skel2.mean = median(now.rec.skel2$Shoulder_Center_Y, na.rm=T)
				now.rec.skel3.mean = median(now.rec.skel3$Shoulder_Center_Y, na.rm=T)
				now.rec.skel1.X = median(now.rec.skel1$Hip_Center_X, na.rm=T)
				now.rec.skel2.X = median(now.rec.skel2$Hip_Center_X, na.rm=T)
				now.rec.skel3.X = median(now.rec.skel3$Hip_Center_X, na.rm=T)
				if(now.rec.skel1.mean == max(c(now.rec.skel1.mean, now.rec.skel2.mean, now.rec.skel3.mean)) && now.rec.skel1.X == max(c(now.rec.skel1.X, now.rec.skel2.X, now.rec.skel3.X))){now.rec = subset(now.rec, Sk_color!= unique.col[1])}
				else if(now.rec.skel2.mean == max(c(now.rec.skel1.mean, now.rec.skel2.mean, now.rec.skel3.mean)) && now.rec.skel2.X == max(c(now.rec.skel1.X, now.rec.skel2.X, now.rec.skel3.X))){now.rec = subset(now.rec, Sk_color!= unique.col[2])}
				else if(now.rec.skel3.mean == max(c(now.rec.skel1.mean, now.rec.skel2.mean, now.rec.skel3.mean)) && now.rec.skel3.X == max(c(now.rec.skel1.X, now.rec.skel2.X, now.rec.skel3.X))){now.rec = subset(now.rec, Sk_color!= unique.col[3])}
			rm("now.rec.skel1", "now.rec.skel2", "now.rec.skel3", "now.rec.skel1.mean", "now.rec.skel2.mean", "now.rec.skel3.mean", "now.rec.skel1.X", "now.rec.skel2.X", "now.rec.skel3.X")
			
			now.rec = droplevels(now.rec)
			unique.col = unique(now.rec $Sk_color) 
			}else if(length(unique.col)==2 && foo.rel.height ==1){
				now.rec.skel1 = now.rec[now.rec$Sk_color== unique.col[1],]
				now.rec.skel2 = now.rec[now.rec$Sk_color== unique.col[2],]
				now.rec.skel1.mean = median(now.rec.skel1$Shoulder_Center_Y, na.rm=T)
				now.rec.skel2.mean = median(now.rec.skel2$Shoulder_Center_Y, na.rm=T)
				now.rec.skel1.X = median(now.rec.skel1$Hip_Center_X, na.rm=T)
				now.rec.skel2.X = median(now.rec.skel2$Hip_Center_X, na.rm=T)
				X.abs = abs(now.rec.skel1.X-now.rec.skel2.X)
				Y.abs = abs(now.rec.skel1.mean-now.rec.skel2.mean)
				# rm("now.rec")
				
				if(!is.na(crit.valX)){
				
				if(now.rec.skel1.mean < now.rec.skel2.mean && (now.rec.skel2.X - now.rec.skel1.X) > crit.valX){now.rec[now.rec$Sk_color==unique.col[2], (func.col+1):ncol(now.rec)] <- NA}
				else if(now.rec.skel1.mean > now.rec.skel2.mean && (now.rec.skel1.X - now.rec.skel2.X) > crit.valX){now.rec[now.rec$Sk_color==unique.col[1], (func.col+1):ncol(now.rec)] <- NA}
				
				}else if(is.na(crit.valX)){
					
				if(now.rec.skel1.mean < now.rec.skel2.mean){now.rec[now.rec$Sk_color==unique.col[2], (func.col+1):ncol(now.rec)] <- NA}
				else if(now.rec.skel1.mean > now.rec.skel2.mean){now.rec[now.rec$Sk_color==unique.col[1], (func.col+1):ncol(now.rec)] <- NA}
				
				}
				
				rm("now.rec.skel1", "now.rec.skel2", "now.rec.skel1.mean", "now.rec.skel2.mean","now.rec.skel1.X", "now.rec.skel2.X", "X.abs", "Y.abs")
			}				
				
			now.rec = droplevels(now.rec)
			unique.col = unique(now.rec $Sk_color) 
			Skeleton = names(now.rec[, (func.col+1):ncol(now.rec)])
			now.dataframe = c()
			now.dataframe = data.frame(now.dataframe)
			now.col = t(now.rec[,1:func.col]$Sk_color)

			for(d in 1:length(Skeleton)){

				now.skel = subset(now.rec, select= Skeleton[d])
				now.skel = t(now.skel)
				new.data = matrix(rep(NA,ncol(now.skel)*length(unique.col)), nrow=length(unique.col))
				now.frame = data.frame(rep(NA, length(unique.col)))	
				
				for(r in 1:length(unique.col)){
				new.data[r, now.col== unique.col[r]] <- now.skel[now.col== unique.col[r]]
				new.data[r, now.col== unique.col[r]] <- now.skel[now.col== unique.col[r]]
				temp.frame = now.rec[now.rec$Sk_color==unique.col[r],] 
				now.frame[r,1] <- as.character(temp.frame[1,]$Frame)
				}
				
				temp.now.rec = now.rec[1:length(unique.col),1:func.col]
				temp.now.rec$Frame <- as.vector(now.frame[,1])
				temp.now.rec$Sk_color <- unique.col
				temp.now.rec = data.frame(temp.now.rec)
				temp.now.rec = cbind(temp.now.rec, Skeleton[d], new.data)

				now.dataframe  = rbind.fill(now.dataframe, temp.now.rec)

			}	
		
			now.dataframe$Frame = as.factor(now.dataframe$Frame)
	
			if(ncol(now.dataframe)<fun.max.col){now.dataframe = cbind(now.dataframe, matrix(NA, nrow= nrow(now.dataframe), ncol= (fun.max.col-ncol(now.dataframe))))}else if(ncol(now.dataframe) >= fun.max.col){
		now.dataframe = now.dataframe[,1: fun.max.col]}
		
			names(now.dataframe) <- c(1: fun.max.col)

			myData.mod  = rbind(myData.mod, now.dataframe)
			
		}
	}
}

for(a in (func.col+2):ncol(myData.mod)){		
myData.mod[,a] = as.numeric(as.character(myData.mod[,a]))
}

names(myData.mod)[1: func.col] <-  names(myData)[1: func.col]
names(myData.mod)[func.col+1] <- "Skeleton"

return(myData.mod)

}

####
# Function process.dataframe.shorten
####

process.dataframe.shorten <- function(data.array, keep.array, count.array, data.subj, foo.col, foo.str.frame){
	
trimmed.array = c()

for(b in 1:length(data.subj)){

	foo.subj = data.array[data.array $Subject== data.subj[b],]
	foo.trials = unique(foo.subj$Trial)
	
	for(k in 1:length(foo.trials)){
	now.str = foo.subj[foo.subj$Trial== foo.trials[k],1:(n.col-1)] 
	now.data = as.numeric(foo.subj[foo.subj$Trial== foo.trials[k],n.col:ncol(data.array)])
	now.keep = as.numeric(keep.array[data.array $Subject==unique.subj[b] & data.array $Trial==foo.trials[k],])
	now.keep = now.keep[!is.na(now.keep)]
	now.uni = as.numeric(count.array[data.array$Subject==unique.subj[b] & data.array $Trial==foo.trials[k],])
	now.uni = now.uni[!is.na(now.uni)]
	now.data = now.data[now.keep]
	
	if(sum(!is.na(now.data))>0){
    foo.unique = unique(now.uni)

  	for(e in 1: length(foo.unique)){
  		  		
	trimmed.array = rbind(trimmed.array, cbind(as.character(now.str[1,1]),as.character(now.str[1,2]),as.character(now.str[1,3]),as.character(now.str[1,4]),e,t(c(now.data[now.uni ==foo.unique[e]], rep(NA, (ncol(data.array)-length(now.data[now.uni ==foo.unique[e]])))))))
  		
  	}
  	
  	}else if(sum(!is.na(now.data))==0){
  	
  	trimmed.array = rbind(trimmed.array, cbind(as.character(now.str[1,1]),as.character(now.str[1,2]),as.character(now.str[1,3]),as.character(now.str[1,4]),1,t(c(rep(NA, length(1:ncol(foo.subj)))))))
			
  	}  	
  }	
}

trimmed.array = data.frame(trimmed.array, row.names=NULL)  
for(a in foo.col:ncol(trimmed.array)){
	trimmed.array[,a] <- as.numeric(as.character(trimmed.array[,a]))	
}	

names(trimmed.array) <- c("Subject_ID", "Condition", "Trial", "Skeleton", "Walk",c(foo.col:ncol(data.array)))

trimmed.array$Trial <- do.call(paste, c(trimmed.array[c("Trial", "Walk")], sep = "-"))

	if(ncol(foo.str.frame)>1){
		trimmed.array = cbind(foo.str.frame, trimmed.array[,(foo.col-1):ncol(trimmed.array)])		
	}

	return(trimmed.array)
}

####
# Function process.dataframe.shorten2
####

process.dataframe.shorten2 <- function(data.array, keep.array, foo.col){
	
trimmed.array = c()
	
for(b in 1:nrow(data.array)){

	foo.array = data.array[b, foo.col:ncol(myData.chest)]
	foo.count = c(1:length(foo.array))
	foo.keep = keep.array[b, 1:ncol(keep.array)]

	foo.array[is.na(match(foo.count, foo.keep))] <- NA

	trimmed.array = rbind(trimmed.array, foo.array)

}	

trimmed.array = data.frame(trimmed.array, row.names=NULL)  
trimmed.array = cbind(data.array[,1:(foo.col-1)], trimmed.array)	
	
return(trimmed.array)

}


####
# Function process.dataframe.shorten.neeco2
####

process.dataframe.shorten.neeco2 <- function(data.array, keep.array, count.array, data.subj, foo.col){
browser()
trimmed.array = c()
trimmed.str = c()
for(b in 1:length(data.subj)){

	foo.subj = data.array[data.array $Subject_ID == data.subj[b],]
	foo.trials = unique(foo.subj$Trial)
	foo.keep = keep.array[data.array $Subject_ID == data.subj[b],]
	
	for(k in 1:length(foo.trials)){
	now.str = foo.subj[foo.subj$Trial== foo.trials[k],1:(n.col-1)] 
	now.data = as.numeric(foo.subj[foo.subj$Trial== foo.trials[k],n.col:ncol(data.array)])
	now.keep = as.numeric(foo.keep[foo.subj $Subject_ID==unique.subj[b] & foo.subj $Trial==foo.trials[k],])
	now.keep = now.keep[!is.na(now.keep)]
	now.uni = as.numeric(count.array[data.array$Subject_ID==unique.subj[b] & data.array $Trial==foo.trials[k],])
	now.uni = now.uni[!is.na(now.uni)]
	now.data = now.data[now.keep]
	
	if(sum(!is.na(now.data))>0){
    foo.unique = unique(now.uni)

  	for(e in 1: length(foo.unique)){
  		  		
	trimmed.array = rbind(trimmed.array, cbind(t(c(now.data[now.uni ==foo.unique[e]], rep(NA, (ncol(data.array)-length(now.data[now.uni ==foo.unique[e]])))))))

	trimmed.str = rbind(trimmed.str, cbind(now.str,e))
  		
  	}
  	
  	}else if(sum(!is.na(now.data))==0){
  	
  	trimmed.array = rbind(trimmed.array, cbind(t(c(rep(NA, length(1:ncol(foo.subj)))))))

	trimmed.str = rbind(trimmed.str, cbind(now.str,e=1))

			
  	}  	
  }	
}

trimmed.array = data.frame(trimmed.array, row.names=NULL)  
for(a in foo.col:ncol(trimmed.array)){
	trimmed.array[,a] <- as.numeric(as.character(trimmed.array[,a]))	
}	

#names(trimmed.array) <- c("Subject_ID", "Condition", "Trial", "Skeleton", "Walk",c(foo.col:ncol(data.array)))

#trimmed.array$Trial <- do.call(paste, c(trimmed.array[c("Trial", "Walk")], sep = "-"))

trimmed.array = cbind(trimmed.str, trimmed.array)

	return(trimmed.array)
}


####
# Function collaps.across.skels
####
# In case multiple skeleton colors were recorded for the movement, collapse.
collaps.across.skels <-function(mock.frame, first.nr){

	mock.frame = mock.frame[, first.nr:ncol(mock.frame)]
	# mock.frame = as.numeric(mock.frame)
	mock.frame[mock.frame ==0] <- NA
	mock.frame = data.frame(mock.frame)
	if(nrow(mock.frame) > 1){	
	mock.frame = apply(mock.frame, 2, mean, na.rm=T)
	}
	mock.frame[mock.frame =="NaN"] <- NA
	trimmed.row = mock.frame
	trimmed.row = as.numeric(trimmed.row)

return(trimmed.row)
}

####
# Function data.inside.procs
####
data.inside.procs <-function(foo.array, foo.start, foo.stop, foo.count.f, foo.control){

	foo.array[(foo.count.f[length(foo.count.f)]+1):length(foo.array)] <- NA
	foo.array[foo.control > foo.start |   foo.control < foo.stop] <- NA
	
	return(foo.array)

}

####
# Function left.right.crossed
####

left.right.crossed <-function(foo.array, foo.left, foo.right){
	updn <- c(0,diff(sign(foo.left-foo.right)))
	ix <- which(updn != 0)	
	if(isTRUE(ix>0)){
		foo.array[1:ix[1]] <- NA
	}
	
	return(foo.array)

}




interpol.eyes<-function(xcurve, interval){
  na.block=is.na(xcurve) & !is.na(c(NA, xcurve[-length(xcurve)]))
  na.block=cumsum(na.block)
  na.block[!is.na(xcurve)]=0
  if(is.na(xcurve[length(xcurve)])){na.block[na.block==max(na.block)]=0}
  na.block.len=table(na.block)[-1]
  na.block.to.interp=as.numeric(names(na.block.len)[na.block.len<=interval])
  if(length(na.block.to.interp)>0){
    for (block in 1:length(na.block.to.interp)){
      last=min((1:length(xcurve))[na.block==na.block.to.interp[block]])-1
      xnext=max((1:length(xcurve))[na.block==na.block.to.interp[block]])+1
      slope=(xcurve[xnext]-xcurve[last])/(xnext-last)
      interc=xcurve[last]-slope*last
      xcurve[na.block==na.block.to.interp[block]]=interc+slope*(1:length(xcurve))[na.block==na.block.to.interp[block]]
    }
  }
  return(xcurve)
}
rm(xcurve, interval, na.block, na.block.len, na.block.to.interp, last, xnext, interc, slope)


warp.by.median<-function(measures, times=NULL, n.bins){ 
 	if(length(times)==0){times=1:length(measures)} 
    keep=!is.na(measures)&!is.na(times) 
    measures=measures[keep] 
    times=times[keep] 
    bin.w=diff(range(times))/n.bins 
    new.times=(times-min(times))%/%bin.w 
    new.times=min(times)+bin.w/2+bin.w*new.times 
    needed=seq(from=min(times)+bin.w/2, to=max(times)-bin.w/2, by=bin.w) 
    new.times[new.times>max(times)]=max(needed) 
    res=tapply(X=measures, INDEX=new.times, FUN=median) 
    res=data.frame(mid.bin=as.numeric(names(res)), measure=as.vector(res), N=tapply(X=measures, INDEX=new.times, FUN=length)) 
    xx=unlist(lapply(needed, function(x){ 
        min(abs(x-res$mid.bin))>1.1*bin.w/2 
    })) 
    if(sum(xx)>0){ 
        needed=needed[xx] 
        xx=unlist(lapply(needed, function(x){ 
            last=max((1:nrow(res))[res$mid.bin<x]) 
            xnext=min((1:nrow(res))[res$mid.bin>x]) 
         res$measure[last]+(x-res$mid.bin[last])*(res$measure[xnext]-res$measure[last])/(res$mid.bin[xnext]-res$mid.bin[last]) 
        })) 
        #browser() 
        res=rbind(res, data.frame(mid.bin=needed, measure=xx, N=0)) 
        res=res[order(res$mid.bin),] 
    } 
    return(res) 
}

get.max.cont.data<-function(xcurve){
na.block=is.na(xcurve) & !is.na(c(NA, xcurve[-length(xcurve)]))
na.block=cumsum(na.block)
na.block[is.na(xcurve)]=NA
this.max = max(as.numeric(matrix(table(na.block))))
this.max[this.max =="Inf"] = NA
this.max[this.max =="-Inf"] = NA
if(is.na(this.max)){this.max<-0}
return(this.max)
}

####
# Function get.forward.seq
####

# Identify individual forward moving sequences.
# This is necessary if no live coding of the trials was done (to identify the frames with forward movement).
get.forward.seq <- function(unique.subj, myData.depth, min.frame.length, max.distance, min.distance, n.col){
# browser()
# Set containers.	
myData.depth2 = c()
myData.keep = c()
myData.keep.unique = c()
myData.str2 = c()
myData.str.short = c()
str.indi = c(1:(n.col-1))

# Loop through each subject.
for(b in 1:length(unique.subj)){

	foo.subj = myData.depth[myData.depth$Subject== unique.subj[b],]
	foo.trials = unique(foo.subj$Trial)
	
	# Loop through each trial for each subject.
	for(k in 1:length(foo.trials)){

		# String info:
		now.str = foo.subj[foo.subj$Trial== foo.trials[k],1:(n.col-1)] 
		# Corresponding depth info:
		now.depth = as.numeric(foo.subj[foo.subj$Trial== foo.trials[k],n.col:ncol(myData.depth)])
		now.depth[now.depth==0] <- NA
		# Numeric counter to identify each depth cell:
		now.count = c(1:length(now.depth))
		# Shorten both vectors to include only cells with data:
		now.count = now.count[!is.na(now.depth)]
		now.depth = now.depth[!is.na(now.depth)]

		# Identify individual forward movements.
    	cnt = 1
    	foo.cnt.array = rep(1,length(now.depth))
	
		for(co in 1:(length(now.depth)-1)){
			
			if(now.depth[co+1] > now.depth[co]){cnt = cnt+1} 
        	foo.cnt.array[co+1] <- cnt    	
		}    	
    
    	foo.cnt.array[length(foo.cnt.array)] = foo.cnt.array[length(foo.cnt.array)-1]
    	foo.cnt.array[1] = foo.cnt.array[2]
 
 		# Which forward sequences were at least min. nr. of frames in length?
 		# This deleted frames for movements that were less than min. nr. of frames in length. 
 		na.block.len=table(foo.cnt.array)
 		na.block.len = data.frame(na.block.len)
 		na.block.len = na.block.len[na.block.len$Freq < min.frame.length,]$foo.cnt.array
 		na.block.len =as.numeric(as.character(na.block.len))

		# Keep only data for those sequences.
 		for(co in 1:length(na.block.len)){
 			now.depth[foo.cnt.array == na.block.len[co]] <- NA
 			now.count[foo.cnt.array == na.block.len[co]] <- NA 		
 		}
 	
  		# Make sure that each walk starts before max.distance and ends after min.distance
  		# Again identify those walks with at least the specified min. nr of frames. This keeps the resepctive movements.
   		na.block.len=table(foo.cnt.array)
   		na.block.len = data.frame(na.block.len) # Changed 10.3.
 		#na.block.len = na.block.len[na.block.len>= min.frame.length] # Changed 10.3.
 		na.block.len = na.block.len[na.block.len$Freq >= min.frame.length,]$foo.cnt.array
 		na.block.len =as.numeric(as.character(na.block.len))

		# Keep only those forward moving sequences which started further than the max. number of frames and for which the min. nr. of frames was closer than the specified minimum. 
   		for(d in 1:length(na.block.len)){

			if(max(now.depth[foo.cnt.array == na.block.len[d]], na.rm=T) < max.distance || min(now.depth[foo.cnt.array == na.block.len[d]], na.rm=T) > min.distance){
		now.depth[foo.cnt.array == na.block.len[d]] <- NA
		now.count[foo.cnt.array == na.block.len[d]] <- NA
			}
			
 		}

		if(sum(!is.na(now.depth))>0){
			
			# Rerun to get new index of forward movements.
			now.count = now.count[!is.na(now.depth)]
			now.depth = now.depth[!is.na(now.depth)]
			cnt = 1
    		foo.cnt.array = rep(1,length(now.depth))
	
			for(co in 1:(length(now.depth)-1)){
		
				if(now.depth[co +1] > now.depth[co]){
            		cnt = cnt+1
        		} 
        	foo.cnt.array[co +1] = cnt    	
        
			}    
			foo.cnt.array[length(foo.cnt.array)] = foo.cnt.array[length(foo.cnt.array)-1]
    		foo.cnt.array[1] = foo.cnt.array[2]

    		foo.unique = unique(foo.cnt.array)

  			for(e in 1: length(foo.unique)){
  		
  				now.depth[foo.cnt.array==foo.unique[e]]
  		
  				## Create new data frame with the individual movements.
				
				myData.depth2 = rbind(myData.depth2, cbind(as.character(now.str[1,str.indi[1]]),as.character(now.str[1,str.indi[2]]),as.character(now.str[1,str.indi[3]]),as.character(now.str[1,str.indi[4]]),e,t(c(now.depth[foo.cnt.array==foo.unique[e]], rep(NA, (ncol(myData.depth)-length(now.depth[foo.cnt.array==foo.unique[e]])))))))
				
				myData.str2 = rbind(myData.str2, now.str[1,])
				
  				##
  			}
  	
  			# These two dataframes allow us to later index the other skeletal data frames.
  			myData.keep = rbind(myData.keep, c(now.count, rep(NA,(500-length(now.count)))))
			myData.keep.unique = rbind(myData.keep.unique, c(foo.cnt.array, rep(NA,(500-length(now.count)))))
  			myData.str.short = rbind(myData.str.short, cbind(now.str[1,], now.str[1,]$Trial))

  		}else if(sum(!is.na(now.depth))==0){
  			# Add empty rows if there were not forward movements for the respective sequence.
  			myData.depth2 = rbind(myData.depth2, cbind(as.character(now.str[1,str.indi[1]]),as.character(now.str[1,str.indi[2]]),as.character(now.str[1,str.indi[3]]),as.character(now.str[1,str.indi[4]]),1,t(c(rep(NA, length(1:ncol(foo.subj)))))))
	
			myData.keep = rbind(myData.keep, rep(NA,500))
			myData.keep.unique = rbind(myData.keep.unique, rep(NA,500))
			
			myData.str2 = rbind(myData.str2, now.str[1,])
  			myData.str.short = rbind(myData.str.short, cbind(now.str[1,], now.str[1,]$Trial))


  		}  	
  }
}    

myData.keep = data.frame(myData.keep, row.names=NULL)  
myData.keep.unique = data.frame(myData.keep.unique, row.names=NULL)  
myData.str2 = data.frame(myData.str2, row.names=NULL)  
myData.str.short = data.frame(myData.str.short, row.names=NULL)  

myData.depth2 = data.frame(myData.depth2, row.names=NULL)  
for(a in n.col:ncol(myData.depth2)){
	myData.depth2[,a] <- as.numeric(as.character(myData.depth2[,a]))	
}

res.list <- list("myData.keep" = myData.keep, "myData.keep.unique" = myData.keep.unique, "myData.depth2" = myData.depth2, "myData.str2" = myData.str2, "myData.str.short" = myData.str.short)


return(res.list)

}

####
# Function get.forward.seq.short
####

# Identify individual forward moving sequences.
# This is necessary if no live coding of the trials was done (to identify the frames with forward movement).
get.forward.seq.short <- function(foo.row.depth.f){

	if(sum(!is.na(foo.row.depth.f))>1){
	control.depth = foo.row.depth
	control.depth = c(1000,control.depth, -1000)
	counter = c(1:length(control.depth))
	counter = matrix(rbind(counter, control.depth), nrow=2)
	counter = counter[,!is.na(counter[2,])]
	next.check = rep(0, ncol(counter))
	prev.check = rep(0, ncol(counter))
	
	for(c in 2:(ncol(counter)-1)){

		if(counter[2,c] > counter[2,c-1]){prev.check[c] <- 1}
		if(counter[2,c] < counter[2,c+1]){next.check[c] <- 1}

	}
	
	counter[2, prev.check==1 & next.check==1] <- NA
		
	control.depth[counter[1,]] <- counter[2,]
	control.depth = control.depth[2:(length(control.depth)-1)]
	
	foo.row.depth.f[is.na(control.depth)] <- NA
	
	}else{
		foo.row.depth.f[1:length(foo.row.depth.f)] <- NA
	}

return(foo.row.depth.f)

}


####
# Function get.forward.seq2
####

# Identify individual forward moving sequences.
# This is necessary if no live coding of the trials was done (to identify the frames with forward movement).
get.forward.seq2 <- function(myData.depth.f, min.frame.length.f, max.distance.f, min.distance.f, n.col.f, foo.max.col.f, foo.max.mov.f, test.trials){
#browser()

# myData.depth.f <- myData.depth
# min.frame.length.f <- min.frame.length
# max.distance.f <- max.distance
# min.distance.f <- min.distance
# n.col.f <- n.col
# foo.max.col.f <- foo.max.col
# foo.max.mov.f <- foo.max.mov
# test.trials <- c("Baseline-2", "Test-1")

# Set containers.	
myData.depth.new = c()
myData.col.index = c()
myData.walk.freq = c()

# Loop through each subject.
for(b in 1:nrow(myData.depth.f)){
		
	# String info:
	now.str = myData.depth.f[b,1:(n.col.f-1)] 
	# Corresponding depth info:
	now.depth = as.numeric(myData.depth.f[b,n.col.f:ncol(myData.depth.f)])
	now.depth[now.depth==0] <- NA
	# Numeric counter to identify each depth cell:
	now.count = c(1:length(now.depth))
	# Shorten both vectors to include only cells with data:
	now.count = now.count[!is.na(now.depth)]
	now.depth = now.depth[!is.na(now.depth)]

	if(sum(!is.na(now.depth))>0){

	x = now.depth
	y = now.depth
	y = c(NA, y) 
	y = y[1:length(x)]
	diff = x-y
	diff[is.na(now.depth)] <- NA
	diff[diff>0] <- NA

	#par(mfrow=c(1,2))
	#plot(now.depth)
	#plot(diff)

	na.block=is.na(diff) & !is.na(c(NA, diff[-length(diff)]))
	na.block=cumsum(na.block)
	na.block[is.na(diff)]=NA

  	na.block.len=table(na.block)
  	na.block.len =as.numeric(names(na.block.len)[na.block.len>=min.frame.length.f])

  	now.depth[is.na(match(na.block, na.block.len))] <- NA
  	now.count[is.na(match(na.block, na.block.len))] <- NA
  	  	
  	# Keep only those forward moving sequences which started further than the max. number of frames and for which the min. nr. of frames was closer than the specified minimum. 
   	na.block.len.unique = unique(na.block.len)
   	
   	for(d in 1:length(na.block.len)){

		if(max(now.depth[na.block == na.block.len[d]], na.rm=T) < max.distance.f || min(now.depth[na.block == na.block.len[d]], na.rm=T) > min.distance.f){
			now.depth[na.block == na.block.len[d]] <- NA
			now.count[na.block == na.block.len[d]] <- NA
			na.block.len.unique[d] <- NA
		}	
 	}
  	
  	# Check whether the trial is part of the indexed trials in 'test.trials' in which case use last walk.
  	if(!is.na(match(now.str$Trial, test.trials))){
  		walk.indicator = na.block.len.unique[!is.na(na.block.len.unique)]
  		now.depth[na.block != walk.indicator[length(walk.indicator)]] <- NA
		now.count[na.block != walk.indicator[length(walk.indicator)]] <- NA
		rm("walk.indicator")
  	}
  	
  	na.block[is.na(now.depth)] <- NA
  	now.depth = now.depth[!is.na(now.depth)]
  	now.count = now.count[!is.na(now.count)]
  	
  	myData.depth.new = rbind(myData.depth.new,c(now.depth, rep(NA,(foo.max.col.f-length(now.depth)))))
  	myData.col.index = rbind(myData.col.index,c(now.count, rep(NA,(foo.max.col.f-length(now.count)))))

	foo.freq = data.frame(table(na.block))
	myData.walk.freq = rbind(myData.walk.freq, c(foo.freq$Freq, rep(NA,(foo.max.mov.f-length(foo.freq$Freq)))))

  	}else if(sum(!is.na(now.depth))==0){

  	myData.depth.new = rbind(myData.depth.new, rep(NA, foo.max.col.f))
  	myData.col.index = rbind(myData.col.index, rep(NA, foo.max.col.f))
  	myData.walk.freq = rbind(myData.walk.freq, rep(NA, foo.max.mov.f))
  	  	
  	}
}  	
  	
myData.depth.new = data.frame(myData.depth.new, row.names=NULL)  
myData.col.index = data.frame(myData.col.index, row.names=NULL)  
myData.walk.freq = data.frame(myData.walk.freq, row.names=NULL)  

res.list <- list("myData.depth.new" = myData.depth.new, "myData.col.index" = myData.col.index, "myData.walk.freq" = myData.walk.freq)

return(res.list)

}
