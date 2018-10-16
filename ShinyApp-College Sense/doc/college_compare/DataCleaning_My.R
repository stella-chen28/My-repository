library(dplyr)
# Read in files
rawdata<- read.csv("./data/MERGED2016_17_PP.csv",stringsAsFactors = F)
dim(rawdata)
rankingdata<- read.csv("./data/ForbesRank.csv")
dim(rankingdata)
variables<- c("OPEID","INSTNM","CONTROL","HIGHDEG","STABBR","CITY",
              "LOCALE","INSTURL","ADM_RATE","SATVRMID","SATMTMID","SAT_AVG",
              "ACTENMID","ACTMTMID", "ACTCMMID",
              "COSTT4_A", "TUITIONFEE_IN","TUITIONFEE_OUT",
              "UGDS","UGDS_MEN","UGDS_WOMEN",
              "UGDS_WHITE", "UGDS_BLACK","UGDS_HISP", "UGDS_ASIAN","UGDS_AIAN","UGDS_NHPI")
rawdata1<- rawdata[,variables]
dim(rawdata1)

# Merge with ranking data
merged<- merge(rawdata1,rankingdata,by.x = "INSTNM",by.y = "Name")
dim(merged)

# replace NULL with NA
for(i in 1:nrow(merged)){
  for (j in 1:ncol(merged)) {
    if(merged[i,j]=="NULL"){
      merged[i,j]=NA
    }
  }
}

# Remove NA values
clean<- na.omit(merged)

# Add Citytype, Schooltype, Highest degree


clean$LOCALE[clean$LOCALE==11|clean$LOCALE==12|clean$LOCALE==13]<-"City"
clean$LOCALE[clean$LOCALE==21|clean$LOCALE==22|clean$LOCALE==23]<-"Suburb"
clean$LOCALE[clean$LOCALE==31|clean$LOCALE==32|clean$LOCALE==33]<-"Town"
clean$LOCALE[clean$LOCALE==41|clean$LOCALE==42|clean$LOCALE==43]<-"Rural"

clean$CONTROL[clean$CONTROL==1]<-"Public"
clean$CONTROL[clean$CONTROL==2]<-"Private for-profit"
clean$CONTROL[clean$CONTROL==3]<-"Private nonprofit"

clean$HIGHDEG[clean$HIGHDEG==1]<-"Certificate"
clean$HIGHDEG[clean$HIGHDEG==2]<-"Associate degree"
clean$HIGHDEG[clean$HIGHDEG==3]<-"Bachelor degree"
clean$HIGHDEG[clean$HIGHDEG==4]<-"Graduate degree"

clean$url<- NA
for(i in 1:nrow(clean)){
  if (grepl('http',clean$INSTURL[i])==FALSE){
    clean$url[i]<- paste("https://",clean$INSTURL[i],sep="")
  }
  else{
    clean$url[i]<- clean$INSTURL[i]
  }
}

dont_want<-c("OPEID","STABBR","INSTURL")
clean <- clean[, ! names(clean) %in% dont_want, drop = F]
colnames(clean)<-c("INSTNM","School Type","Highest Degree","City","City Size",
                   "Admission Rate","SATVRMID","SATMTMID","SAT_AVG","ACTENMID",
                   "ACTMTMID","ACTCMMID","Cost","Tuition(in-state)","Tuition(out-state)",
                   "Undergraduates","UGDS_MEN","UGDS_WOMEN","UGDS_WHITE","UGDS_BLACK",
                   "UGDS_HISP","UGDS_ASIAN","UGDS_AIAN","UGDS_NHPI",
                   "Rank","State","Website")

data2017<-clean[order(clean$Rank),]
data_use<-t(data2017)
colnames(data_use)<-data2017$INSTNM

# Write out new csv file
write.csv(data_use, file = "./data/data_use.csv")
