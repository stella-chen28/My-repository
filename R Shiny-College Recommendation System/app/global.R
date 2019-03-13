#install.packages("shinyWidgets")
library(shinyWidgets)
library(shiny)
library(fmsb)
library(dplyr)
library(ggplot2)

#####app.r#####
#library(shiny)
library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
#library(dplyr)
#library(ggplot2)
library(plotly)
library(shinyjs)
library(formattable)
##########

library(maps)
library(mapproj)

data_use<-read.csv("../data/data_use.csv",row.names = 1,check.names = FALSE,stringsAsFactors = FALSE)

variables1<-c("Rank","Admission Rate","School Type","Highest Degree","Website",
              "State","City","City Size","Undergraduates",
              "Cost","Tuition(in-state)","Tuition(out-state)")

variables2<-c("UGDS_WHITE","UGDS_BLACK", "UGDS_HISP",
              "UGDS_ASIAN","UGDS_AIAN","UGDS_NHPI")

mydata<-read.csv("../data/mydata.csv")

color_chose<-c("skyblue3","orange2","seagreen3","gold1")

##########app.r
data<-read.csv("../output/cleanedData.csv")
data$COSTT4_A<- as.numeric(data$COSTT4_A)
data$Rank<- as.numeric(data$Rank)
data$UGDS_MEN<- as.numeric(data$UGDS_MEN)
data$UGDS_WOMEN<- as.numeric(data$UGDS_WOMEN)
data$SAT_AVG<- as.numeric(data$SAT_AVG)
data$ADM_RATE<- as.numeric(data$ADM_RATE)
data$ACTCMMID<- as.numeric(data$ACTCMMID)
data$Genderratio<- ifelse(data$UGDS_MEN>=0.5,"Men dominant","Women dominant")
data$newurl<- a(data$url,href=data$url)
universities <- as.character(data$INSTNM)
gender<- c("Gender")
ethnicity<- c("Ethnicity")
data$White<- data$UGDS_WHITE/(data$UGDS_WHITE+data$UGDS_BLACK+data$UGDS_ASIAN+data$UGDS_HISP+data$UGDS_NHPI+data$UGDS_AIAN)
data$Black<- data$UGDS_BLACK/(data$UGDS_WHITE+data$UGDS_BLACK+data$UGDS_ASIAN+data$UGDS_HISP+data$UGDS_NHPI+data$UGDS_AIAN)
data$Asian<- data$UGDS_ASIAN/(data$UGDS_WHITE+data$UGDS_BLACK+data$UGDS_ASIAN+data$UGDS_HISP+data$UGDS_NHPI+data$UGDS_AIAN)
data$Hispanic<- data$UGDS_HISP/(data$UGDS_WHITE+data$UGDS_BLACK+data$UGDS_ASIAN+data$UGDS_HISP+data$UGDS_NHPI+data$UGDS_AIAN)
data$Others<- (data$UGDS_NHPI+data$UGDS_AIAN)/(data$UGDS_WHITE+data$UGDS_BLACK+data$UGDS_ASIAN+data$UGDS_HISP+data$UGDS_NHPI+data$UGDS_AIAN)
livars<- c(
  "Annual Cost"="cost1",
  "Rank"="rank1",
  "Student Size"="population1")
livars2<- c(
  "School Type"="schooltype1",
  "City Type"="citytype1",
  "Highest Degree"="highestdegree1",
  "Sex Ratio"="sexratio1"
)
###########

employ <- read.csv("../data/employ.csv")
heat_index <- read.csv("../data/heat_index.csv")
table_final <- read.csv("../data/table_final.csv")

###########

data11<-read.csv('../data/cleanedData(1).csv', na.strings = "NULL")
data11[is.na(data11)]=0
data11[,c(10:18,31)][data11[,c(10:18,31)]<=200]=NA

