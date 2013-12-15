classification<-function(csvFile="KD_test1W.csv"){
load("~/classify/core.RData")
setwd("~/classify")
Sys.setenv(HADOOP_CMD="/usr/local/hadoop/bin/hadoop")
Sys.setenv(HADOOP_STREAMING="/usr/local/hadoop/contrib/streaming/hadoop-streaming-1.1.2.jar")
library(rmr2)
library(rmmseg4j)
source('~/classify/classifier_mr.R')
rmr.options(backend="hadoop")

#把csv中的记录转化为keyval格式
text<-read.csv(file(paste("data/",csvFile,sep=""), encoding="GBK"), header=F, stringsAsFactors=F)$V5
inputText<-keyval(1:length(text),text)
#提取各短信关键词 #hdfs#

picked_words<-pick_words_mr(inputText)
unlisted_words<-unlist_keywords_mr(picked_words)
#各短信的关键词的idf表索引 #hdfs#
index<-index_mr(unlisted_words,idf)

#最后分类结果 #local#
result<-Rocchio_mr(index,center_words_index$val,idf,category)
sorted<-sort(result$key,index.return=T)$ix
result$key<-result$key[sorted]
result$val<-result$val[sorted]
resultFile<-paste("result/",unlist(strsplit(csvFile, "\\."))[1],"_result.csv",sep="")
write.csv(result,resultFile)
}