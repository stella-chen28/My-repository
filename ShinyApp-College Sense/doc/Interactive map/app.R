library(shiny)
library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)
library(ggplot2)
library(plotly)
library(shinyjs)
library(formattable)

# The following code should be moved to global.R
data<- read.csv("cleanedData.csv")
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

# The following code should be moved to ui.R
ui<- navbarPage(title="US Univeristies",id="nav", 
                tabPanel("College Information Map",
                         div(class="outer",
                             tags$head(
                               includeCSS("styles.css"), 
                               includeScript("gomap.js")
                             ),
                             leafletOutput("map",width="100%",height="100%"),
                             absolutePanel(id="controls",class="panel panel-default",fixed=TRUE,
                                           draggable=TRUE, top=60, left=22, right="auto", bottom="auto",
                                           width=300, height="auto",
                                           #h2("College"),
                                           sliderInput(inputId = "liRank",label = "Rank",min=1,max=660,value=660),
                                           sliderInput(inputId = "tuition", label = "Annual Cost", min=9000, max=71000, value=71000),
                                           sliderInput("adm","Admission Rate",min = 0,max=1,value = 1),
                                           sliderInput("SAT","SAT",min=900,max = 1600,value=1600),
                                           sliderInput("ACT","ACT",min=18,max = 36,value = 36),
                                           selectInput(inputId = "color",label = "Color by",livars2),
                                           selectInput(inputId = "size",label = "Size by",livars)
                             )
                         ),
                  
                         useShinyjs(), 
                         hidden( 
                           div(id = "conditionalPanel",
                               fluidRow(
                                 absolutePanel(id = "controls", class = "panel panel-default", style="overflow-y:scroll; margin-top: 20px; margin-bottom: 0px;", fixed = TRUE,
                                               draggable = TRUE, top = 150, right=0, bottom = 0, #250
                                               width = 325, #400
                                               
                                               h2("Detailed Information"),
                                               
                                               selectizeInput("college", 'University',
                                                              choices = c("",universities), selected=""),
                                               tableOutput("table"),
                                               plotlyOutput("gender_bar", height = 110),
                                               plotlyOutput("race_bar", height = 110),
                                               fluidRow(
                                                 
                                               )
                                 )
                               )
                           )
                         ),
                         tags$div(id="cite",
                                  'Data compiled from',tags$em('https://collegescorecard.ed.gov/'),'by Binglun, Huiyu, Shichao, Sizhu and Yanchen (Columbia University, 2018).')
                )
                
)


# The following code should be moved to server.R
server<- function(input, output, session){
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
          ) %>% setView(lng=-93.85,lat=37.45,zoom=4) %>%
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
}

shinyApp(ui = ui, server = server)


