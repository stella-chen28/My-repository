# Read in files
rawdata<- read.csv("MERGED2016_17_PP.csv",stringsAsFactors = F)
dim(rawdata)
rankingdata<- read.csv("ForbesRank.csv")
dim(rankingdata)
variables<- c("UNITID","OPEID","OPEID6","INSTNM","CITY","STABBR","ZIP","INSTURL","LATITUDE",
              "LONGITUDE","ADM_RATE","SATVR25","SATVR75","SATMT25","SATMT75",
              "SATVRMID","SATMTMID","ACTCM25","ACTCM75","ACTEN25",
              "ACTEN75","ACTMT25","ACTMT75","ACTCMMID","ACTENMID",
              "ACTMTMID","DISTANCEONLY", "CURROPER", "SAT_AVG","PCIP01","PCIP03","PCIP04","PCIP05",
              "PCIP09","PCIP10","PCIP11","PCIP12","PCIP13","PCIP14"	,"PCIP15",
              "PCIP16","PCIP19","PCIP22","PCIP23","PCIP24","PCIP25","PCIP26","PCIP27",
              "PCIP29","PCIP30","PCIP31","PCIP38","PCIP39","PCIP40","PCIP41","PCIP42",
              "PCIP43","PCIP44","PCIP45","PCIP46","PCIP47","PCIP48","PCIP49","PCIP50",
              "PCIP51","PCIP52","PCIP54","COSTT4_A","UGDS_MEN","UGDS_WOMEN",
              "UGDS_WHITE", "UGDS_BLACK","UGDS_HISP", "UGDS_ASIAN","UGDS_AIAN","UGDS_NHPI",
              "UGDS","TUITIONFEE_IN","TUITIONFEE_OUT","CONTROL","LOCALE","HIGHDEG")
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
merged_cleaned<- na.omit(merged)
dim(merged_cleaned)
clean<- merged_cleaned

# Add Citytype, Schooltype, Highest degree
clean$Citytype<- NA
for (i in 1:nrow(clean)) {
  if (clean$LOCALE[i]==11 | clean$LOCALE[i]== 12 | clean$LOCALE[i]==13) {
    clean$Citytype[i]<-"City"
  }
  else if (clean$LOCALE[i]==21 | clean$LOCALE[i]== 22 | clean$LOCALE[i]==23) {
    clean$Citytype[i]<- "Suburb"
  }
  else if (clean$LOCALE[i]==31 | clean$LOCALE[i]== 32 | clean$LOCALE[i]==33) {
    clean$Citytype[i]<- "Town"
  }
  else if (clean$LOCALE[i]==41 | clean$LOCALE[i]== 42 | clean$LOCALE[i]==43){
    clean$Citytype[i]<- "Rural"
  }
}
clean$Schooltype<- NA
for (i in 1:nrow(clean)) {
  if (clean$CONTROL[i]==1){
    clean$Schooltype[i]<-"Public"}
  else if (clean$CONTROL[i]==2){
    clean$Schooltype[i]<- "Private for-profit"}
  else if (clean$CONTROL[i]==3){
    clean$Schooltype[i]<-"Private nonprofit"}
}

clean$Highestdegree<- NA
for (i in 1:nrow(clean)) {
  if (clean$HIGHDEG[i]==4){
    clean$Highestdegree[i]<- "Graduate degree"
  }
  else if (clean$HIGHDEG[i]==3){
    clean$Highestdegree[i]<- "Bachelor’s degree"
  }
  else if (clean$HIGHDEG[i]==2){
    clean$Highestdegree[i]<- "Associate’s  degree"
  }
  else if (clean$HIGHDEG[i]==1){
    clean$Highestdegree[i]<- "Certificate"
  }
}

###Complete the URLs
clean$url<- NA
for(i in 1:nrow(clean)){
  if (grepl('http',clean$INSTURL[i])==FALSE){
    clean$url[i]<- paste("https://",clean$INSTURL[i],sep="")
  }
  else{
    clean$url[i]<- clean$INSTURL[i]
  }
}

# Write out new csv file
write.csv(clean, file = "cleanedData.csv")

