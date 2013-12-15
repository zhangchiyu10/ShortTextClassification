rm(list=ls())
setwd("~/classify")
Sys.setenv(HADOOP_CMD="/usr/local/hadoop/bin/hadoop")
Sys.setenv(HADOOP_STREAMING="/usr/local/hadoop/contrib/streaming/hadoop-streaming-1.1.2.jar")
library(rmr2)
library(rmmseg4j)
source('~/classify/classifier_mr.R')
rmr.options(backend="hadoop")

textFile="data/KD_test1W.csv"
centerWordsFile="data/分类词库.csv"

cat<-length(category)
#把csv中的记录转化为keyval格式
text<-read.csv(file(textFile, encoding="GBK"), header=T, stringsAsFactors=F)$text
centerwords<-read.csv(file(centerWordsFile, encoding="GBK"), header=T, stringsAsFactors=F)$content
N<-length(text)+cat
inputText<-keyval(1:N,c(centerwords,text))

#提取各短信关键词 #hdfs#
picked_woreds<-pick_words_mr(inputText)
unlisted_words<-unlist_keywords_mr(picked_woreds)
#sorted<-sort(unlisted_words$key,index.return=T)$ix

#各关键词的idf #local#
idf<-idf_mr(unlisted_words,N)

#各短信的关键词的idf表索引 #local#
rmr.options(backend="local")
centerwords<-read.csv(file(centerWordsFile, encoding="GBK"), header=T, stringsAsFactors=F)$content
centerText<-keyval(1:length(centerwords),centerwords)
picked_centerwords<-pick_words_mr(centerText)
unlisted_centerwords<-unlist_keywords_mr(picked_centerwords)
center_words_index<-from.dfs(index_mr(unlisted_centerwords,idf))

category<-read.csv(file(centerWordsFile, encoding="GBK"), header=T, stringsAsFactors=F)$type
category<-category[center_words_index$key]
save(center_words_index,idf,category,file="~/classify/core.RData")

rm(list=ls())