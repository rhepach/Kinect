
# Support function
trim.that<-function(mock.frame, first.nr){

	mock.frame = mock.frame[, first.nr:ncol(mock.frame)]
	mock.frame[mock.frame ==0] <- NA	
	mock.frame = apply(mock.frame, 2, mean, na.rm=T)
	mock.frame = as.numeric(mock.frame)
	mock.frame[mock.frame =="NaN"] <- NA
	trimmed.row = mock.frame

return(trimmed.row)
}

trim.that2<-function(mock.frame, first.nr){
		mock.frame[mock.frame ==0] <- NA	
		temp.num = apply(mock.frame[first.nr:ncol(mock.frame)], 2, mean, na.rm=T)		
		# trimmed.row2 = cbind(mock.frame[1,1:(n.col-1)], data.frame(t(temp.num)))
		mock.frame[mock.frame =="NaN"] <- NA
		trimmed.row2 = as.numeric(t(temp.num))
return(trimmed.row2)
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