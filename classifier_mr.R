Rocchio_mr<- function(index,centers,idf,category)
{
  centers_dist2<-rep(0,length(centers))
  for(i in 1:length(centers)){
    centers_dist2[i]<-sqrt(sum(idf$val[unlist(centers[i])]^2))
  }
  from.dfs(
  mapreduce(
    input=index,
    map=function(k,v){
      dist<-rep(0,length(centers))
      vv<-rep(0,length(v))
      for(i in 1:length(v)){
        for(j in 1:length(centers)){
          intersection<-intersect(unlist(v[i]),unlist(centers[j]))
          dist[j]<-sum(idf$val[intersection]^2)/(centers_dist2[j]*sqrt(sum(unlist(v[i])^2)))
        }
        r<-category[which(dist==max(dist))]
        if(length(r)==0){vv[i]="未知"}
        else{vv[i]=r}
          
      }
      keyval(k,vv)
        
    }))
}

index_mr<-function(unlisted_words,idf)
{
  mapreduce(
    input=unlisted_words,
    map=function(k,v){
      vv<-rep(0,length(v))
      for(i in 1:length(v)){
        r<-which(idf$key==v[i])
        if(length(r)==0){vv[i]=0}
        else{vv[i]<-r}
        
      }
      keyval(k,vv)
    },
    reduce=function(k,v){
      keyval(k,list(v))
    })
  
}
idf_mr<-function(unlisted_words,N)
{
  from.dfs(
  mapreduce(
    input=unlisted_words,
    map=function(k,v){
      keyval(v,k)
    },
    reduce=function(k,v){
     keyval(k,log(N/length(v))/log(2)) 
    }))
}

unlist_keywords_mr<-function(picked_keywords)
{
  
  mapreduce(
    input=picked_keywords,
    map=function(k,v){
      s<-strsplit(v," ")
      vv<-unlist(s)
      count<-rep(0,length(k))
      for(i in 1:length(k)){
        count[i]<-length(s[[i]])
      }
      kk<-rep(k,count)
      filter<-which(nchar(vv)>1)
      keyval(kk[filter],vv[filter])})
  
}

pick_words_mr<- function(inputText)
{
    mapreduce(
      input=to.dfs(inputText),
      map=function(k,v){
        v<- gsub("[0-9０１２３４５６７８９]","",v)#去除数字
        v<-mmseg4j(v,dicDir="/usr/local/lib/R/site-library/rmmseg4j/dic/")      
        keyval(k,v)
      })
}

