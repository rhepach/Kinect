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
# Last changes March 2019 by RH
#
# Questions -> robert.hepach@uni-leipzig.de
############################################################################

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

