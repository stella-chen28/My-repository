library(shiny)
library(fmsb)
library(dplyr)
library(ggplot2)

data_use<-read.csv("./data/data_use.csv",row.names = 1,check.names = FALSE,stringsAsFactors = FALSE)

variables1<-c("Rank","Admission Rate","School Type","Highest Degree","Website",
              "State","City","City Size","Undergraduates",
              "Cost","Tuition(in-state)","Tuition(out-state)")

variables2<-c("UGDS_WHITE","UGDS_BLACK", "UGDS_HISP",
              "UGDS_ASIAN","UGDS_AIAN","UGDS_NHPI")

mydata<-read.csv("./data/mydata.csv")

color_chose<-c("skyblue3","orange2","seagreen3","gold1")

########################################server part########################################

shinyServer(function(input, output) {

  output$compare_table<-DT::renderDataTable(
    DT::datatable({
    school_chose<-c(input$`College 1`,input$`College 2`,input$`College 3`,input$`College 4`)
    school_chose<-school_chose[school_chose!="None"]
    data_use[variables1,school_chose]
    },
    options = list(pageLength = 12,scrollX=T)
    ))
  
   output$compare_radar<-renderPlot({
     name<-c(input$`College 1`,input$`College 2`,input$`College 3`,input$`College 4`)
     name<-name[name!="None"]
     
       data_radar=cbind(as.numeric(data_use["UGDS_WHITE",name])*100,
                        as.numeric(data_use["UGDS_BLACK",name])*100,
                        as.numeric(data_use["UGDS_HISP",name])*100,
                        as.numeric(data_use["UGDS_ASIAN",name])*100,
                        as.numeric(data_use["UGDS_AIAN",name])*100,
                        as.numeric(data_use["UGDS_NHPI",name])*100)
       
       colnames(data_radar)=c("White","Black", "Hispanic",
                             "Asian","American Indian/Alaska Native",
                             "Native Hawaiian/Pacific Islander")
       rownames(data_radar)=name
       data_radar=as.data.frame(rbind(rep(100,6) , rep(0,6) , data_radar))
       
       radarchart( data_radar, axistype=1, 
                   plwd=3,plty=1,
                   pcol=c("gold","orange","orange3","orange4") , 
                   cglcol="grey", cglty=1, 
                   axislabcol="grey", caxislabels=seq(0,100,20),
                   cglwd=0.8, vlcex=1.2,
                   title = "Race of Undergraduates (%)" )
       legend(x=-1.4, y=1.2, legend = name,
              bty = "n", pch=20, 
              col=c("gold","orange","orange3","orange4") ,
              text.col = "grey28", 
              cex=1.3, pt.cex=2)
     
        })
   
   output$compare_line_adm<-renderPlot({
     name<-c(input$`College 1`,input$`College 2`,input$`College 3`,input$`College 4`)
     name<-name[name!="None"]
     
     data_chose <- mydata %>% filter_(~INSTNM %in% name)
     ggplot(data=data_chose, aes(x=as.factor(Year), 
                                 y=as.numeric(as.character(ADM_RATE)),
                                 group = INSTNM, color = INSTNM)) +
       #scale_y_continuous(breaks=seq(0, 1, 0.2), limits = c(0, 1))+
       geom_point(size=1.6,alpha=0.7,shape=18)+
       geom_line(size=1,alpha=0.7)+
       scale_color_manual(values=c("lightpink3", "gold2", "steelblue3","forestgreen"))+
       labs(title="Admission Rate Trend",
            x="Year",y="Admission Rate (%)",
            col="College")+
       theme(plot.title = element_text(size=16, face="bold"))
      
   })
   
   output$compare_line_tuitionin<-renderPlot({
     name<-c(input$`College 1`,input$`College 2`,input$`College 3`,input$`College 4`)
     name<-name[name!="None"]
     
     data_chose <- mydata %>% filter_(~INSTNM %in% name)
     ggplot(data=data_chose, aes(x=as.factor(Year), 
                                 y=as.numeric(as.character(TUITIONFEE_IN)),
                                 group = INSTNM, color = INSTNM)) +
       #scale_y_continuous(breaks=seq(0, 55100, 5000), limits = c(0, 55100))+
       geom_point(size=1.6,alpha=0.7)+
       geom_line(size=1,alpha=0.7)+
       scale_color_manual(values = c("lightpink3", "gold2", "steelblue3","forestgreen"))+
       labs(title="In-State Tuition Trend",
            x="Year",y="In-State Tuition ($)",
            col="College")+
       theme(plot.title = element_text(size=16, face="bold"))
     
   })
   output$compare_line_tuitionout<-renderPlot({
     name<-c(input$`College 1`,input$`College 2`,input$`College 3`,input$`College 4`)
     name<-name[name!="None"]
   
     data_chose <- mydata %>% filter_(~INSTNM %in% name)
     ggplot(data=data_chose, aes(x=as.factor(Year), 
                                      y=as.numeric(as.character(TUITIONFEE_OUT)),
                                      group = INSTNM, color = INSTNM)) +
       #scale_y_continuous(breaks=seq(0, 55100, 5000), limits = c(0, 55100))+
       geom_point(size=1.6,alpha=0.7)+
       geom_line(size=1,alpha=0.7)+
       scale_color_manual(values = c("lightpink3", "gold2", "steelblue3","forestgreen"))+
       labs(title="Out-State Tuition Trend",
            x="Year",y="Out-State Tuition ($)",
            col="College")+
       theme(plot.title = element_text(size=16, face="bold"))
     
   })
})
