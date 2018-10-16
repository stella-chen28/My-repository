
source("./www/helpers.R")
source("./global.R")

########################################server part########################################

shinyServer(function(input, output, session) {

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

#######app.r##########
  
   observe({
     usedcolor<- "red"
     tuition<- as.numeric(input$tuition)
     liRank<- as.numeric(input$liRank)
     SAT<- as.numeric(input$SAT)
     adm<- as.numeric(input$adm)
     ACT<- as.numeric(input$ACT)
     lidata<- filter(data,COSTT4_A<tuition,Rank<liRank,SAT_AVG<SAT,ADM_RATE<adm,ACTCMMID<ACT)
     radius1<- lidata$Rank
     opacity<- 0.5

     if(input$size=="cost1"){
       radius1<- lidata$COSTT4_A
       opacity<- 0.5
     }else if(input$size=="rank1"){
       radius1<- 300000*(log(lidata$Rank)+1)^(-1)
       opacity<- 0.5
     }else if(input$size=="population1"){
       radius1<- lidata$UGDS*3
       opacity<- 0.5
     }
     #####below
     if(input$color=="schooltype1"){
       pal<- colorFactor(
         palette = c('red', 'blue'),
         domain = lidata$Schooltype
       )
       output$map<- renderLeaflet({
         leaflet(data=lidata) %>%
           addTiles(
             urlTemplate="//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
             attribution='Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
           ) %>% 
           setView(lng=-93.85,lat=37.45,zoom=4) %>%
           clearShapes() %>%
           addCircles(~LONGITUDE,~LATITUDE,radius=radius1,layerId=~UNITID,stroke=FALSE,fillOpacity=opacity,fillColor=~pal(Schooltype),label = ~as.character(INSTNM)) %>%
           addLegend(colors = c('red',"blue"),labels = c("Private for-profit","Public"))
       })

     }else if(input$color=="citytype1"){
       pal<- colorFactor(
         palette = c('brown','navy','yellow','green'),
         domain = lidata$Citytype
       )
       output$map<- renderLeaflet({
         leaflet(data=lidata) %>%
           addTiles(
             urlTemplate="//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
             attribution='Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
           ) %>% setView(lng=-93.85,lat=37.45,zoom=4) %>%
           clearShapes() %>%
           addCircles(~LONGITUDE,~LATITUDE,radius=radius1,layerId=~UNITID,stroke=FALSE,fillOpacity=opacity,fillColor=~pal(Citytype),label = ~as.character(INSTNM)) %>%
           addLegend(colors = c('brown',"navy","yellow","green"),labels = c("City","Rural","Surburb","Town"))
       })
     }else if(input$color=="highestdegree1"){
       pal<- colorFactor(
         palette = c('orange','purple'),
         domain = lidata$Highestdegree
       )
       output$map<- renderLeaflet({
         leaflet(data=lidata) %>%
           addTiles(
             urlTemplate="//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
             attribution='Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
           ) %>% setView(lng=-93.85,lat=37.45,zoom=4) %>%
           clearShapes() %>%
           addCircles(~LONGITUDE,~LATITUDE,radius=radius1,layerId=~UNITID,stroke=FALSE,fillOpacity=opacity,fillColor=~pal(Highestdegree),label = ~as.character(INSTNM)) %>%
           addLegend(colors = c('orange','purple'),labels = c("Bachelor's Degree","Graduate Degree"))
       })
     }else if(input$color=="sexratio1"){
       pal<- colorFactor(
         palette = c('blue','pink'),
         domain=lidata$Genderratio
       )
       output$map<- renderLeaflet({
         leaflet(data=lidata) %>%
           addTiles(
             urlTemplate="//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
             attribution='Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
           ) %>% setView(lng=-93.85,lat=37.45,zoom=4) %>%
           clearShapes() %>%
           addCircles(~LONGITUDE,~LATITUDE,radius=radius1,layerId=~UNITID,stroke=FALSE,fillOpacity=0.75,fillColor=~pal(Genderratio),label = ~as.character(INSTNM)) %>%
           addLegend(colors = c('blue','pink'),labels = c("Male > 50%","Female > 50%"))
       })
     }
#############above##
     output$race_bar<- renderPlotly({
       if (input$college==""){
         return(NULL)
       }
       sub<- data[data$INSTNM==input$college,]
       ethnicity<- ethnicity
       white<- sub$White
       black<- sub$Black
       asian<- sub$Asian
       hispanic<- sub$Hispanic
       other<- sub$Others
       race<- data.frame(ethnicity,white,black,asian,hispanic,other)
       plot_ly(
         race, x = ~other, y = ~ethnicity, type = 'bar', orientation = 'h', name = 'Other') %>%
         add_trace(x = ~hispanic, name = 'Hispanic') %>%
         add_trace(x = ~asian, name = 'Asian') %>%
         add_trace(x = ~black, name = 'Black') %>%
         add_trace(x = ~white, name = 'White') %>%
         layout(xaxis = list(title = 'Proportion'), yaxis = list(title =""), barmode = 'stack') %>%
         config(displayModeBar = F)
     })

     output$gender_bar<- renderPlotly({
       if(input$college==""){
         return(NULL)
       }
       sub<- data[data$INSTNM==input$college,]
       gender<- gender
       male<- sub$UGDS_MEN
       female<- sub$UGDS_WOMEN
       gen<- data.frame(gender,male,female)
       plot_ly(gen,x=~female,y=~gender,type='bar',orientation='h',name='Female') %>%
         add_trace(x=~male,name='Male') %>%
         layout(xaxis=list(title='Proportion'),yaxis=list(title=""),barmode='stack') %>%
         config(displayModeBar = F)
     })

     output$table <- renderTable({
       sub<- data[data$INSTNM==input$college,]
       Features<- c("School Type","City Type","In-State Tuition","Out-of-State Tuition","Annual Cost","Admission Rate","SAT Average","ACT Median")
       Value<- c(as.character(sub$Schooltype),as.character(sub$Citytype),sub$TUITIONFEE_IN,sub$TUITIONFEE_OUT,sub$COSTT4_A,percent(sub$ADM_RATE),sub$SAT_AVG,sub$ACTCMMID)
       data<-data.frame(cbind(Features, Value))
       data
     })
     


     showZipcodePopup<- function(x,lat,lng){
       lidata<- lidata[lidata$UNITID==x,]
       content<- as.character(tagList(
         tags$h4(tags$strong(lidata$INSTNM)),tags$br(),
         #        tags$strong(HTML(sprintf("Information"))),tags$br(),
         sprintf("Rank: %s",lidata$Rank),tags$br(),
         sprintf("Location: %s, %s %s",lidata$CITY,lidata$STABBR,lidata$ZIP),tags$br(),
         tags$a(lidata$url,href=lidata$url),tags$br()
       ))
       leafletProxy("map") %>% addPopups(lng,lat,content,layerId = x)
     }

     observe({
       leafletProxy("map") %>% clearPopups()
       event<- input$map_shape_click
       if (is.null(event)){
         return()
       }
       isolate({
         showZipcodePopup(event$id, event$lat, event$lng)
       })
     })

     observeEvent(input$map_shape_click, {

       shinyjs::show(id = "conditionalPanel")
       event <- input$map_shape_click
       x <- event$id
       name_uni <- lidata[lidata$UNITID==x,"INSTNM"]
       updateTextInput(session, "college", value=name_uni)

     })
     ####    
     #    observeEvent(input$map_click, {
     #     
     #      shinyjs::hide(id = "conditionalPanel")
     #      
     #    })
     ####    
     
   })

   output$map3 <- renderPlot({
     args <- switch(input$var,
                    "Heat index" = list(heat_index$index, "orange", "Heat index"),
                    "unemployment rate" = list(employ$Rate, "black", "unemployment rate")

     )
     args$min <- input$range[1]
     args$max <- input$range[2]

     do.call(percent_map, args)
   })

   ## four ###################################################
   ### ad rate & highest degree###

   observe({
     if (input$hd == "Graduate Degree"){
       data11=data11[which(data11[,88]=="Graduate degree"),]
     }else if (input$hd == "Doesn't Matter"){
       data11=data11
     }else{
       data11=data11[which(data11[,88] != "Graduate degree"),]
     }

     if (input$type == "Public"){
       data11=data11[which(data11[,"Schooltype"]=="Public"),]
     }else if (input$type == "Doesn't Matter"){
       data11=data11
     }else{
       data11=data11[which(data11[,"Schooltype"] != "Public"),]
     }



     ###sat & act part###
     data11=data11[order(data11[,'Rank']),]

     model=reactive({lm(data11[,input$y]~data11[,input$x])})
     InverseRank=1/data11[,'Rank']
     Rank=data11[,'Rank']
     ylim1=reactive({max(data11[,input$var])})
     ylim2=reactive({min(data11[,input$var])})
     x=reactive({input$ho$x})
     y=reactive({input$ho$y})
     data11$all25=data11$SATVR25+data11$SATMT25
     data11$all50=data11$SATVRMID+data11$SATMTMID
     data11$all75=data11$SATVR75+data11$SATMT75
     diff=reactive({abs(data11$SAT_AVG-ave())})
     df=reactive({data11[order(diff(),decreasing=F),][1:10,]})
     ave=reactive({input$vr+input$mt})
     act=reactive({input$act})
     diff2=reactive({abs(data11$ACTCMMID-act())})
     df2=reactive({data11[order(diff2(),decreasing=F),][1:10,]})
     score=function(x,y,x1,y1){return((x-x1)^2+(y-y1)^2)}
     ###
     name=reactive({as.character(data2$College)[which.min(score(x(),y(),data2[,input$x],data2[,input$y]))]})
     ###
     observeEvent(input$mt, {
       ave=reactive({input$vr+input$mt})
       data11$all25=data11$SATVR25+data11$SATMT25
       data11$all50=data11$SATVRMID+data11$SATMTMID
       data11$all75=data11$SATVR75+data11$SATMT75
       diff=reactive({abs(data11$SAT_AVG-ave())})
       df=reactive({data11[order(diff()),][1:10,]})
      output$cPlot <- renderPlot({
         # Render a barplot
         ggplot(data=df(), aes(x=factor(INSTNM),ymin=400,ymax=1600,lower=all25,middle=all50,upper=all75,fill=seq(400,1600,by = 130) ))+
           geom_boxplot(stat="identity")+
           theme(axis.text.x=element_text(angle = -90, hjust = 0))+
           ylab('SAT')+
           scale_fill_gradient(low="red", high="blue",limit=(c(400, 1600)))+
           ylim(400,1600)+
           labs(fill='SAT')+
           xlab('College Name')+
           geom_hline(aes(yintercept=ave()), colour="red")
       }
       )
     })

     observeEvent(input$act, {
       act=reactive({input$act})
       diff2=reactive({abs(data11$ACTCMMID-act())})
       df2=reactive({data11[order(diff2(),decreasing=F),][1:10,]})
       output$DPlot <- renderPlot({
         # Render a barplot
          ggplot(data=df2(), aes(x=factor(INSTNM),ymin=0,ymax=32,lower=ACTCM25,middle=ACTCMMID,upper=ACTCM75, fill=seq(0,36,length.out = 10)))+
          geom_boxplot(stat="identity")+
           theme(axis.text.x=element_text(angle = -90, hjust = 0))+
           ylab('ACT')+
           scale_fill_gradient(low="red", high="blue",limit=(c(0, 36)))+
           ylim(0,32)+
           labs(fill='ACT')+
           xlab('College Name')+
           geom_hline(aes(yintercept=act()),colour="red")

       })})
   }
   )

   #######################################################

   output$info_table<-DT::renderDataTable({
     DT::datatable(table_final
     )
   })
})

#######################


